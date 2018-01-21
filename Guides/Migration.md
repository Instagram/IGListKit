# Migration

This guide provides details for how to migrate between major versions of `IGListKit`.

## From 2.x to 3.x

For details on all changes in IGListKit 3.0.0, please see the [release notes](https://github.com/Instagram/IGListKit/releases/tag/3.0.0). 

> **NOTE:** This release contains *a lot* of improvements and source-breaking API changes, especially for Swift clients. These are all noted in the full [release notes](https://github.com/Instagram/IGListKit/releases/tag/3.0.0).

### "IG" prefix removed for Swift

We have improved how `IGListKit` APIs get imported into Swift. The `IG` prefix has been removed for Swift clients. For example, `IGListSectionController` becomes `ListSectionController` instead. Along with other interoperability improvements, this makes `IGListKit` more readable in Swift.

To migrate, use Xcode's Find navigator (command-3), search for `IGList`, and replace with `List`.

### `IGListSectionType` removed

In order to make building section controllers even easier, we removed the protocol and absorbed all of the methods into `IGListSectionController` with default implementations.

- `numberOfItems` returns 1 item
- `didUpdateToObject:` and `didSelectItemAtIndex:` do nothing
- `sizeForItemAtIndex:` returns `CGSizeZero`
- `cellForItemAtIndex:` asserts (you must override this method)

In Objective-C, all you need to do is find & remove all uses of `IGListSectionType`. This includes `IGListSectionController` and `IGListAdapterDataSource` implementations.

In Swift, you will also need to add `override` keywords to all methods.

The compiler should catch all instances that need fixed.

### `IGListBindingSectionController`

If you were using `IGListDiff(...)` _inside_ a section controller to compute diffs for cells, we recommend that you start using `IGListBindingSectionController` which wraps this behavior in an elegant and tested API.

### Removed `IGListCollectionView`

You can simply find regex `IGListCollectionView([ |\*|\(])` and replace with regex `UICollectionView$1` in your project to fix this.

![Replace IGListCollectionView](https://raw.githubusercontent.com/Instagram/IGListKit/master/Resources/replace-iglistcollectionview.png)

### Removed `IGListGridCollectionViewLayout`

Start using `IGListCollectionViewLayout` instead of `IGListGridCollectionViewLayout`.

- `scrollDirection` is not yet supported. If you need horizontal scrolling, please use `UICollectionViewFlowLayout` or file an issue.
- Set `minimumLineSpacing` on your [section controllers](https://github.com/Instagram/IGListKit/blob/master/Source/IGListSectionController.h#L59-L64) instead of the layout
- Set `minimumInteritemSpacing` on your [section controllers](https://github.com/Instagram/IGListKit/blob/master/Source/IGListSectionController.h#L66-L71) instead of the layout
- Return the size of your cells in [sizeForItemAtIndex:](https://github.com/Instagram/IGListKit/blob/master/Source/IGListSectionController.h#L48) instead of setting it on the layout.

### Item mutations must be wrapped in `-[IGListCollectionContext performBatchAnimated:completion:]`

To fix some rare crashes, all item mutations must now be performed inside a batch block and done on the `IGListBatchContext` object instead.

**Objective-C**

```objc
// OLD
self.expanded = YES;
[self.collectionContext insertInSectionController:self atIndexes:[NSIndexSet indexSetWithIndex:]];

// NEW
[self.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
  self.expanded = YES;
  [batchContext insertInSectionController:self atIndexes:[NSIndexSet indexSetWithIndex:1]];
} completion:nil];
```

**Swift**

```swift
// OLD
expanded = true
collectionContext?.insert(in: self, at: [0])

// NEW
collectionContext?.performBatch(animated: true, updates: { (batchContext) in
  self.expanded = true
  batchContext.insert(in: self, at: [0])
})
```

Make sure that your model changes occur **inside the update block**, alongside the context methods.

## From 1.x to 2.x

For details on all changes in `IGListKit` 2.0.0, please see the [release notes](https://github.com/Instagram/IGListKit/releases/tag/2.0.0).

### `IGListDiffable` Conformance

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

extension MyModel: ListDiffable {
  func diffIdentifier() -> NSObjectProtocol {
    return self
  }
  
  func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    return isEqual(object)
  }
}
```

However we recommend writing more thorough identity and equality checks. Check out our guide to [IGListDiffable and Equality](https://instagram.github.io/IGListKit/iglistdiffable-and-equality.html) for more info.
