# IGListDiffable and Equality

This guide details how to write a good `isEqual:` method. `IGListKit` requires that models implement the method `isEqualToDiffableObject:` which should perform the same type of check, but without impacting behavior in Objective-C containers like `NSDictionary` and `NSSet`.

## IGListDiffable bare minimum

The quickest way to get started with diffable models is use the _object itself_ as the identifier, and use the super `-[NSObject isEqual:]` implementation for equality:

```objc
- (id<NSObject>)diffIdentifier {
  return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
  return [self isEqual:object];
}
```

## Writing better Equality methods

Even though `IGListKit` uses the method `isEqualToDiffableObject:`, the concepts of writing a good equality check apply in general.

Here are the basics to writing good `-isEqual:` and `-hash` functions. Note this is all ObjC but translates well to Swift.

- If you override `-isEqual:` you **must** override `-hash`
  - Check out this [article by Mike Ash](https://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html) for details
- Always compare the pointer first
  - Saves a lot of wasteful `objc_msgSend(...)` and value comparisons if checking the same instance
- When comparing object values, always check for `nil` before `-isEqual:`
  - e.g. `[nil isEqual:nil]` returns `NO`
  - Instead do `left == right || [left isEqual:right]`
- Always compare the **cheapest values first**
  - Doing `[self.array isEqual:other.array] && self.intVal == other.array` is hella wasteful if the `intVal`s are different. Use lazy eval!

As an example, if I had a `User` model with the following interface:

```objc
@interface User : NSObject
@property NSInteger pk;
@property NSString *name;
@property NSArray *posts;
@end
```

You would implement its equality methods like so:

```objc
@implementation User

- (NSUInteger)hash {
  return self.pk;
}

- (BOOL)isEqual:(id)object {
  if (self == object) return YES;
  if (![object isKindOfClass:[User class]]) return NO;

  User *right = object;
  return self.pk == right.pk 
  && (self.name == right.name || [self.name isEqual:right.name])
  && (self.posts == right.posts || [self.posts isEqualToArray:right.posts]);
}

@end
```

## Using both IGListDiffable and isEqual

Making your objects work universally with Objective-C containers and `IGListKit` is really easy once you've implemented `isEqual:` and `hash`.

```objc
@interface User (IGListDiffable) <IGListDiffable>
@end

@implementation User (IGListDiffable)

- (id<NSObject>)diffIdentifier {
  return @(self.pk);
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
  return [self isEqual:object];
}

@end
```