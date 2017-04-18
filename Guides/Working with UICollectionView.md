# Working with `UICollectionView`

This guide provides details on how to work with [`UICollectionView`](https://developer.apple.com/reference/uikit/uicollectionview) and `IGListKit`.

## Background

Early versions of `IGListKit` (2.x and prior) shipped with a subclass of `UICollectionView` called [`IGListCollectionView`](https://github.com/Instagram/IGListKit/blob/2.1.0/Source/IGListCollectionView.h). The class contained *no* special functionality and was merely used to enforce compile-time restrictions to prevent users from calling certain methods directly on `UICollectionView`. Beginning with 3.0, `IGListCollectionView` [was removed](https://github.com/Instagram/IGListKit/commit/2284ce389708f62d99f48ff2ec15644f1ec59537) for a number of reasons.

For further discussion see [#240](https://github.com/Instagram/IGListKit/issues/240) and [#409](https://github.com/Instagram/IGListKit/issues/409).

## Methods to avoid

One of the primary purposes of `IGListKit` is to perform optimal batch updates for `UICollectionView`. Thus, clients **should never** call any APIs on `UICollectionView` that involved reloading, inserting, deleting, or otherwise updating cells and index paths. Instead, use the APIs provided by [`IGListAdapter`](https://instagram.github.io/IGListKit/Classes/IGListAdapter.html). You should also avoid setting the [`delegate`](https://developer.apple.com/reference/uikit/uicollectionview/1618033-delegate) and [`dataSource`](https://developer.apple.com/reference/uikit/uicollectionview/1618091-datasource) of the collection view, as this is also the responsibility of `IGListAdapter`.

Avoid calling the following methods:

```objc
- (void)performBatchUpdates:(void (^)(void))updates
                 completion:(void (^)(BOOL))completion;

- (void)reloadData;

- (void)reloadSections:(NSIndexSet *)sections;

- (void)insertSections:(NSIndexSet *)sections;

- (void)deleteSections:(NSIndexSet *)sections;

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate;

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource;

- (void)setBackgroundView:(UIView *)backgroundView;
```

## Performance

In iOS 10, a new [cell prefetching API](https://developer.apple.com/reference/uikit/uicollectionviewdatasourceprefetching) was introduced. At Instagram, enabling this feature substantially degraded scrolling performance. We recommend setting [`isPrefetchingEnabled`](https://developer.apple.com/reference/uikit/uicollectionview/1771771-isprefetchingenabled) to `NO` (`false` in Swift). Note that the default value is `true`.

You can set this globally using `UIAppearance`:

```objc
if ([[UICollectionView class] instancesRespondToSelector:@selector(setPrefetchingEnabled:)]) {
    [[UICollectionView appearance] setPrefetchingEnabled:NO];
}
```

```swift
if #available(iOS 10, *) {
    UICollectionView.appearance().isPrefetchingEnabled = false
}
```
