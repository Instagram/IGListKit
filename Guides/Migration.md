# Migration

This guide provides details for how to migration between major versions of `IGListKit`.

## From 2.x to 3.x

For details on all changes in IGListKit 2.0.0, please see the [release notes](https://github.com/Instagram/IGListKit/releases/tag/3.0.0).

### IGListBindingSectionController

If you were using `IGListDiff(...)` _inside_ a section controller to compute diffs for cells, we recommend that you start using `IGListBindingSectionController` which wraps this behavior in an elegant and tested API.

### IGListCollectionView removed

You can simply Find & Replace `IGListCollectionView` with `UICollectionView` in your project to fix this.

![Replace IGListCollectionView](https://raw.githubusercontent.com/Instagram/IGListKit/master/Resources/replace-iglistcollectionview.png)

### IGListGridCollectionViewLayout removed

Start using `IGListCollectionViewLayout` instead of `IGListGridCollectionViewLayout`.

- `scrollDirection` is not yet supported. If you need horizontal scrolling, please use `UICollectionViewFlowLayout` or file an issue.
- Set `minimumLineSpacing` on your [section controllers](https://github.com/Instagram/IGListKit/blob/master/Source/IGListSectionController.h#L59-L64) instead of the layout
- Set `minimumInteritemSpacing` on your [section controllers](https://github.com/Instagram/IGListKit/blob/master/Source/IGListSectionController.h#L66-L71) instead of the layout
- Return the size of your cells in [sizeForItemAtIndex:](https://github.com/Instagram/IGListKit/blob/master/Source/IGListSectionType.h#L43-L54) instead of setting it on the layout.

### Item mutations must be wrapped in -[IGListCollectionContext performBatchAnimated:completion:]

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
expanded = true
collectionContext?.insert(in: self, at: [0])

collectionContext?.performBatch(animated: true, updates: { (batchContext) in
  self.exanded = true
  batchContext.insert(in: self, at: [0])
})
```

Make sure that your model changes occur **inside the update block**, alongside the context methods.

## From 1.x to 2.x

For details on all changes in IGListKit 2.0.0, please see the [release notes](https://github.com/Instagram/IGListKit/releases/tag/2.0.0).

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
