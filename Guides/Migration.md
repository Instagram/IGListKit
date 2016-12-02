# Migration

This guide provides details for how to migration between major versions of `IGListKit`.

## From 1.x to 2.x

### IGListDiffable Conformance

If you relied on the default `NSObject<IGListDiffable>` category, you will need to add `IGListDiffable` conformance to each of your models. To get things working as they did in 1.0, simply add the following to each of your models:

**Objective-C**
```objc
#import <IGListKit/IGListDiffable.h>

// Header
@interface MyModel <IGListDiffable>

// Implementation
- (id<NSObject>)diffIdentifier {
  return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
  return [self isEqual:object];
}
```

**Swift**
```swift
import IGListKit

extension MyModel: IGListDiffable {
  func diffIdentifier() -> NSObjectProtocol {
    return self
  }
  
  func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
    return isEqual(object)
  }
}
```

However we recommend writing more thorough identity and equality checks. Check out our guide to [IGListDiffable and Equality](https://instagram.github.io/IGListKit/iglistdiffable-and-equality.html) for more info.