# CHANGELOG

The changelog for `IGListKit`. Also see the [releases](https://github.com/instagram/IGListKit/releases) on GitHub.

2.1.0
-----

This release closes the [2.1.0 milestone](https://github.com/Instagram/IGListKit/milestone/2).

### Enhancements

- Added support for macOS. Note: this is *only* for the Diffing components. There is **no support** for `IGListAdapter`, `IGListSectionController`, and other components at this time. [Guilherme Rambo](https://github.com/insidegui) [(#235)](https://github.com/Instagram/IGListKit/pull/235)

- Added a [macOS example](https://github.com/Instagram/IGListKit/tree/master/Examples/Examples-macOS) project. [Guilherme Rambo](https://github.com/insidegui) [(#337)](https://github.com/Instagram/IGListKit/pull/337)

- Disables `prefetchEnabled` by default on `IGListCollectionView`. [Sven Bacia](https://github.com/svenbacia) [(#323)](https://github.com/Instagram/IGListKit/pull/323)

- Working ranges now work with `IGListStackedSectionController`. [Ryan Nystrom](https://github.com/rnystrom) [(#356)](https://github.com/Instagram/IGListKit/pull/356)

- Added CocoaPods subspec for diffing, `IGListKit/Diffing` and an [installation guide](https://instagram.github.io/IGListKit/installation.html). [Sherlouk](https://github.com/Sherlouk) [(#368)](https://github.com/Instagram/IGListKit/pull/368)

- Added `allowsBackgroundReloading` flag (default `YES`) to `IGListAdapterUpdater` so users can configure this behavior as needed. [Adlai-Holler](https://github.com/Adlai-Holler) [(#375)](https://github.com/Instagram/IGListKit/pull/375)

- `-[IGListAdapter updater]` is now public (read-only). [Adlai-Holler](https://github.com/Adlai-Holler) [(#379)](https://github.com/Instagram/IGListKit/pull/379)

### Fixes

- Avoid `UICollectionView` crashes when queueing a reload and insert/delete on the same item as well as reloading an item in a section that is animating. [Ryan Nystrom](https://github.com/rnystrom) [(#325)](https://github.com/Instagram/IGListKit/pull/325)

- Prevent adapter data source from deallocating after queueing an update. [Ryan Nystrom](https://github.com/rnystrom) [(4cc91a2)](https://github.com/Instagram/IGListKit/commit/4cc91a25c8b262953e4f2d8e5dc78ee15c6265b2)

- Fix out-of-bounds bug when child section controllers in a stack remove cells. [Ryan Nystrom](https://github.com/rnystrom) [(#358)](https://github.com/Instagram/IGListKit/pull/358)

- Fix a grid layout bug when item has full-width and iter-item spacing is not zero. [Bofei Zhu](https://github.com/zhubofei) [(#361)](https://github.com/Instagram/IGListKit/pull/361)

2.0.0
-----

This release closes the [2.0.0 milestone](https://github.com/Instagram/IGListKit/milestone/1?closed=1). We've increased test coverage to 97%. Thanks to the [27 contributors](https://github.com/Instagram/IGListKit/graphs/contributors) who helped with this release!

You can find a [migration guide here](https://instagram.github.io/IGListKit/migration.html) to assist with migrating between 1.0 and 2.0.

### Breaking Changes

- Diff result method on `IGListIndexPathResult` changed. `-resultWithUpdatedMovesAsDeleteInserts` was removed and replaced with `-resultForBatchUpdates` [(b5aa5e3)](https://github.com/Instagram/IGListKit/commit/b5aa5e39002854c947e777c11ae241f67f24d19c)

```
// OLD
- (IGListIndexPathResult *)resultWithUpdatedMovesAsDeleteInserts;

// NEW
- (IGListIndexPathResult *)resultForBatchUpdates;
```

- `IGListDiffable` equality method changed from `isEqual:` to `isEqualToDiffableObject:` [(ab890fc)](https://github.com/Instagram/IGListKit/commit/ab890fc6070f170a2db5a383a6296e62dcf75678)

- The default `NSObject<IGListDiffable>` category was removed and replaced with `NSString<IGListDiffable>` and `NSNumber<IGListDiffable>` categories. All other models will need to conform to `IGListDiffable`. [(3947600)](https://github.com/Instagram/IGListKit/commit/394760081c7c2daa5ae6c18e00cdeaf2b67e22c1)

- Added support for specifying an end position when scrolling. [Bofei Zhu](https://github.com/zhubofei) [(#196)](https://github.com/Instagram/IGListKit/pull/196). The `IGListAdapter` scrolling method changed:

```objc
// OLD
- (void)scrollToObject:(id)object
    supplementaryKinds:(nullable NSArray<NSString *> *)supplementaryKinds
       scrollDirection:(UICollectionViewScrollDirection)scrollDirection
              animated:(BOOL)animated;

// NEW
- (void)scrollToObject:(id)object
    supplementaryKinds:(nullable NSArray<NSString *> *)supplementaryKinds
       scrollDirection:(UICollectionViewScrollDirection)scrollDirection
        scrollPosition:(UICollectionViewScrollPosition)scrollPosition
              animated:(BOOL)animated;
```


- Changed `NSUInteger` to `NSInteger` in all public APIs. [Suraya Shivji](https://github.com/surayashivji) [(#200)](https://github.com/Instagram/IGListKit/issues/200)

### Enhancements

- Added support for supplementaryViews created from nibs. [Rawlinxx](https://github.com/rawlinxx) [(#90)](https://github.com/Instagram/IGListKit/pull/90)

- Added support for cells created from nibs. [Sven Bacia](https://github.com/svenbacia) [(#56)](https://github.com/Instagram/IGListKit/pull/56)

- Added an additional initializer for `IGListSingleSectionController` to be able to support single sections created from nibs. An example can be found [here](https://github.com/Instagram/IGListKit/tree/master/Examples/Examples-iOS/IGListKitExamples/ViewControllers/SingleSectionViewController.swift). [(#56)](https://github.com/Instagram/IGListKit/pull/56)

```objc
- (instancetype)initWithNibName:(NSString *)nibName
                         bundle:(nullable NSBundle *)bundle
                 configureBlock:(IGListSingleSectionCellConfigureBlock)configureBlock
                      sizeBlock:(IGListSingleSectionCellSizeBlock)sizeBlock;
```

- Added `-isFirstSection` and `-isLastSection` APIs to `IGListSectionController` [(316fbe2)](https://github.com/Instagram/IGListKit/commit/316fbe2b8b2508b58a0f38387c3a343b9c37e282)

- Added support for cells and supplementaryViews created from storyboard. There's a new required method on the `IGListCollectionContext` protocol to do this. [Bofei Zhu](https://github.com/zhubofei) [(#92)](https://github.com/Instagram/IGListKit/pull/92)

```objc
// IGListCollectionContext
- (__kindof UICollectionViewCell *)dequeueReusableCellFromStoryboardWithIdentifier:(NSString *)identifier
                                                              forSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                                                                           atIndex:(NSInteger)index;
```

- Added `tvOS` support. [Jesse Squires](https://github.com/jessesquires) [(#137)](https://github.com/Instagram/IGListKit/pull/137)

- Added `-[IGListAdapter visibleObjects]` API. [Ryan Nystrom](https://github.com/rnystrom) [(386ae07)](https://github.com/Instagram/IGListKit/commit/386ae0786445c06e1eabf074a4181614332f155f)

- Added `-[IGListAdapter objectForSectionController:]` API. [Ayush Saraswat](https://github.com/saraswatayu) [(#204)](https://github.com/Instagram/IGListKit/pull/204)

- Added `IGListGridCollectionViewLayout`, a section-based grid layout. [Bofei Zhu](https://github.com/zhubofei) [(#225)](https://github.com/Instagram/IGListKit/pull/225)

- Added support for scrolling to an index in a section controller from within that section controller. There's a new required method on the `IGListCollectionContext` protocol to do this. [Jesse Squires](https://github.com/jessesquires) [(e5afb5b)](https://github.com/Instagram/IGListKit/commit/e5afb5b4d0cfc70a2736b02279b6bc239ddf1e5d)

```objc
// IGListCollectionContext
- (void)scrollToSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                          atIndex:(NSInteger)index
                   scrollPosition:(UICollectionViewScrollPosition)scrollPosition
                         animated:(BOOL)animated;
```

### Fixes

- Fixed `-[IGListAdapter reloadDataWithCompletion:]` not returning early when `collectionView` or `dataSource` is `nil` and `completion` is `nil`. [Ben Asher](https://github.com/benasher44) [(#51)](https://github.com/Instagram/IGListKit/pull/51)

- Prevent `UICollectionView` bug when accessing a cell during working range updates. [Ryan Nystrom](https://github.com/rnystrom) [(#216)](https://github.com/Instagram/IGListKit/pull/216)

- Skip reloading for objects that are not found when calling `-[IGListAdapter reloadObjects:]`. [Ryan Nystrom](https://github.com/rnystrom) [(ca15e29)](https://github.com/Instagram/IGListKit/commit/ca15e29cf1dadc6c396fe8f14f16c27f6a38519c)

- Fixes a crash when a reload is queued for an object that is deleted in the same runloop turn. [Ryan Nystrom](https://github.com/rnystrom) [(7c3d499)](https://github.com/Instagram/IGListKit/commit/7c3d4999ebde36ee4666e5aee99716d1ed1fb2d8)

- Fixed a bug where `IGListStackSectionController` would only set its supplementary source once. [Ryan Nystrom](https://github.com/rnystrom) [(#286)](https://github.com/Instagram/IGListKit/pull/286)

- Fixed a bug where `IGListStackSectionController` passed the wrong section controller for will-drag scroll events. [Ryan Nystrom](https://github.com/rnystrom) [(#286)](https://github.com/Instagram/IGListKit/pull/286)

- Fixed a crash when deselecting a cell through a child section controller in an `IGListStackSectionController`. [Ryan Nystrom](https://github.com/rnystrom) [(#295)](https://github.com/Instagram/IGListKit/pull/295)

### Documentation

- We now have 100% documentation coverage. Docs been refined and clarified. [Jesse Squires](https://github.com/jessesquires) [(#207)](https://github.com/Instagram/IGListKit/pull/207)

- Added new Guides: [Getting Started](https://instagram.github.io/IGListKit/getting-started.html), [Migration](https://instagram.github.io/IGListKit/migration.html)

- Added examples for Today & iMessage extensions. [Sherlouk](https://github.com/Sherlouk) [(#112)](https://github.com/Instagram/IGListKit/pull/112)

- Added `tvOS` example pack. [Sherlouk](https://github.com/Sherlouk) [(#141)](https://github.com/Instagram/IGListKit/pull/141)

1.0.0
-----

Initial release. :tada:
