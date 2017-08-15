# IGListDiffable and Equality

This guide explains the `IGListDiffable` protocol and how to write good `-isEqual:` methods. 

## Background

The [`IGListDiffable` protocol](https://instagram.github.io/IGListKit/Protocols/IGListDiffable.html) requires clients to implement two methods, `-diffIdentifier` and `-isEqualToDiffableObject:`.

The method `-isEqualToDiffableObject:` should perform the same type of check as `-isEqual:`, but without impacting performance characteristics, like in Objective-C containers such as `NSDictionary` and `NSSet`.

Why are both of these methods required for diffing? The point of having the two methods has to do with **identity** and **equality**, where the diff identifier uniquely identifies data (common scenario is primary key in databases). Equality comes into play when comparing the values of two uniquely identical objects (driving reloading).

See also: [#509](https://github.com/Instagram/IGListKit/issues/509)

## `IGListDiffable` bare minimum

The quickest way to get started with diffable models is use the _object itself_ as the identifier, and use the superclass's `-[NSObject isEqual:]` implementation for equality:

```objc
- (id<NSObject>)diffIdentifier {
  return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
  return [self isEqual:object];
}
```

## Writing better Equality methods

Even though `IGListKit` uses the method `-isEqualToDiffableObject:`, the concepts of writing a good equality check apply in general. Here are the basics to writing good `-isEqual:` and `-hash` functions. Note this is all Objective-C but applies to Swift also.

- If you override `-isEqual:` you **must** override `-hash`. Check out this [article by Mike Ash](https://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html) for details.
- Always compare the pointer first. This saves a lot of wasteful `objc_msgSend(...)` calls and value comparisons if checking the same instance.
- When comparing object values, always check for `nil` before `-isEqual:`. For example, `[nil isEqual:nil]` counterintuitively returns `NO`. Instead, do `left == right || [left isEqual:right]`.
- Always compare the **cheapest values first**. For example, doing `[self.array isEqual:other.array] && self.intVal == other.intVal` is extremely wasteful if the `intVal` values are different. Use lazy evaluation!

As an example, if I had a `User` model with the following interface:

```objc
@interface User : NSObject

@property NSInteger identifier;
@property NSString *name;
@property NSArray *posts;

@end
```

You would implement its equality methods like so:

```objc
@implementation User

- (NSUInteger)hash {
  return self.identifier;
}

- (BOOL)isEqual:(id)object {
  if (self == object) { 
      return YES;
  }
  
  if (![object isKindOfClass:[User class]]) {
      return NO;
  }

  User *right = object;
  return self.identifier == right.identifier 
      && (self.name == right.name || [self.name isEqual:right.name])
      && (self.posts == right.posts || [self.posts isEqualToArray:right.posts]);
}

@end
```

## Using both `IGListDiffable` and `-isEqual:`

Making your objects work universally with Objective-C containers and `IGListKit` is easy once you've implemented `-isEqual:` and `-hash`.

```objc
@interface User <IGListDiffable>

// properties...

@end

@implementation User

- (id<NSObject>)diffIdentifier {
    return @(self.identifier);
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return [self isEqual:object];
}

@end
```
