# CHANGELOG

The changelog for `IGListKit`. Also see the [releases](https://github.com/instagram/IGListKit/releases) on GitHub.

3.1.0 (**upcoming release**)
-----

### Fixes

- Prevent a crash when update queued immediately after item batch update. [Ryan Nystrom](https://github.com/rnystrom) (tbd)

### Enhancements

- Added `-[IGListSectionController didDeselectItemAtIndex:]` API to support default `UICollectionView` cell deselection. [Ryan Nystrom](https://github.com/rnystrom) (tbd)

3.0.0
-----

This release closes the [3.0.0 milestone](https://github.com/Instagram/IGListKit/milestone/3).

### Breaking Changes

- Added Swift annotation names which remove `IG` prefixes from class names, C functions, and other APIs. Note, this only affects Swift clients. [Robert Payne](https://github.com/robertjpayne) [(#593)](https://github.com/Instagram/IGListKit/pull/593)

Example:

```swift
// OLD
class MySectionController : IGListSectionController { ... }

// NEW
class MySectionController : ListSectionController { ... }

// OLD
IGListDiff([], [], .equality)

// NEW
ListDiff(oldArray: [], newArray: [], .equality)

```

- Updated `didSelect` delegate call in `IGListSingleSectionControllerDelegate` to include object. [Sherlouk](https://github.com/Sherlouk) [(#397)](https://github.com/Instagram/IGListKit/pull/397)

```objc
// OLD
- (void)didSelectSingleSectionController:(IGListSingleSectionController *)sectionController;

// NEW
- (void)didSelectSectionController:(IGListSingleSectionController *)sectionController
                        withObject:(id)object;
```

- `IGListUpdatingDelegate` now conforms to `NSObject`, bringing it in line with other framework protocols. [Adlai Holler](https://github.com/Adlai-Holler) [(#435)](https://github.com/Instagram/IGListKit/pull/435)

- Changed `hasChanges` methods in `IGListIndexPathResult` and `IGListIndexSetResult` to read-only properties. [Bofei Zhu](https://github.com/zhubofei) [(#453)](https://github.com/Instagram/IGListKit/pull/453)

- Replaced `IGListGridCollectionViewLayout` with `IGListCollectionViewLayout`. [Ryan Nystrom](https://github.com/rnystrom) ([#482](https://github.com/Instagram/IGListKit/pull/482), [#450](https://github.com/Instagram/IGListKit/pull/450))

- Renamed `IGListAdapterUpdaterDelegate` method to `listAdapterUpdater:didPerformBatchUpdates:collectionView:`. [Vincent Peng](https://github.com/vincent-peng) [(#491)](https://github.com/Instagram/IGListKit/pull/491)

- Moved section controller mutations to `IGListBatchContext`, provided as a parameter when calling `-performBatchAnimated:updates:completion` on a section controller's `collectionContext`. All updates (insert, delete, reload item/section controller) must now be done inside a batch update block. [Ryan Nystrom](https://github.com/rnystrom) [(a15ea08)](https://github.com/Instagram/IGListKit/commit/a15ea0861492c8476bc9b1b92b0d9835814091c7)

```objc
// OLD
[self.collectionContext performBatchAnimated:YES updates:^{
  self.expanded = YES;
  [self.collectionContext insertInSectionController:self atIndexes:[NSIndexSet indexSetWithIndex:1]];
} completion:nil];

// NEW
[self.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
  self.expanded = YES;
  [batchContext insertInSectionController:self atIndexes:[NSIndexSet indexSetWithIndex:1]];
} completion:nil];

// OLD
[self.collectionContext reloadSectionController:self];

// NEW
[self.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext> batchContext) {
  [batchContext reloadSectionController:self];
} completion:nil];
```

- `-[IGListCollectionContext containerSize]` no longer accounts for the content inset of the collection view when returning a size. If you require that behavior, you can now use `-[IGListCollectionContext insetContainerSize]`. [Ryan Nystrom](https://github.com/rnystrom) [(623ff2a)](https://github.com/Instagram/IGListKit/commit/623ff2a8a85e0e2e8d0331ae3250d67985cd06b6)

- `IGListCollectionView` has been **completely removed** in favor of using plain old `UICollectionView`. See discussion at [#409](https://github.com/Instagram/IGListKit/issues/409) for details. [Jesse Squires](https://github.com/jessesquires) [(2284ce3)](https://github.com/Instagram/IGListKit/commit/2284ce389708f62d99f48ff2ec15644f1ec59537)

- `IGListBatchUpdateData` replaced its `NSSet` properties with `NSArray` instead. [Ryan Nystrom](https://github.com/rnystrom) [(#616)](https://github.com/Instagram/IGListKit/pull/616)

- `IGListUpdatingDelegate` now requires method `-reloadItemInCollectionView:fromIndexPath:toIndexPath:` to handle reloading cells between index paths. [Ryan Nystrom](https://github.com/rnystrom) [(#657)](https://github.com/Instagram/IGListKit/pull/657)

- `-[IGListCollectionContext sectionForSectionController:]` has been removed and replaced with the `NSInteger sectionIndex` property on `IGListSectionController`. [Andrew Monshizadeh](https://github.com/amonshiz) [#671](http://github.com/Instagram/IGListKit/pull/671)

### Enhancements

- Added an initializer on `IGListAdapter` that does not take a `workingRangeSize` and defaults it to 0. [BasThomas](https://github.com/BasThomas) [(#686)](https://github.com/Instagram/IGListKit/pull/686)

- Added `-[IGListAdapter visibleCellsForObject:]` API. [Sherlouk](https://github.com/Sherlouk) [(#442)](https://github.com/Instagram/IGListKit/pull/442)

- Added `-[IGListAdapter sectionControllerForSection:]` API. [Adlai-Holler](https://github.com/Adlai-Holler) [(#477)](https://github.com/Instagram/IGListKit/pull/477)

- You can now manually move items (cells) within a section controller, ex: `[self.collectionContext moveInSectionController:self fromIndex:0 toIndex:1]`. [Ryan Nystrom](https://github.com/rnystrom) [(#418)](https://github.com/Instagram/IGListKit/pull/418)

- Invalidate the layout of a section controller and control the transition with `UIView` animation APIs. [Ryan Nystrom](https://github.com/rnystrom) [(#499)](https://github.com/Instagram/IGListKit/pull/499)

- Added `-[IGListAdapter visibleIndexPathsForSectionController:]` API. [Malecks](https://github.com/Malecks) [(#465)](https://github.com/Instagram/IGListKit/pull/465)

- Added `IGListBindingSectionController` which automatically binds view models to cells and animates updates at the cell level. [Ryan Nystrom](https://github.com/rnystrom) [(#494)](https://github.com/Instagram/IGListKit/pull/494)

- Added `IGListGenericSectionController` to take advantage of Objective-C (and Swift) generics and automatically store strongly-typed references to the object powering your section controller. [Ryan Nystrom](https://github.com/rnystrom) ([301f147](https://github.com/Instagram/IGListKit/commit/301f1471c9a7a802320e07890f5e98f15ada4e2e))

- Added a debug option for IGListKit that you can print to lldb via `po [IGListDebugger dump]`. [Ryan Nystrom](https://github.com/rnystrom) [(#617)](https://github.com/Instagram/IGListKit/pull/617)

### Fixes

- Gracefully handle a `nil` section controller returned by an `IGListAdapterDataSource`. [Ryan Nystrom](https://github.com/rnystrom) [(#488)](https://github.com/Instagram/IGListKit/pull/488)

- Fix bug where emptyView's hidden status is not updated after the number of items is changed with `insertInSectionController:atIndexes:` or related methods. [Peter Edmonston](https://github.com/edmonston) [(#395)](https://github.com/Instagram/IGListKit/pull/395)

- Fix bug where `IGListStackedSectionController`'s children need to know `numberOrItems` before didUpdate is called. [(#348)](https://github.com/Instagram/IGListKit/pull/390)

- Fix bug where `-[UICollectionViewCell ig_setStackedSectionControllerIndex:]` should use `OBJC_ASSOCIATION_COPY_NONATOMIC` for NSNumber. [PhilCai](https://github.com/PhilCai1993) [(#424)](https://github.com/Instagram/IGListKit/pull/426)

- Fix potential bug with suppressing animations (by passing `NO`) during `-[IGListAdapter performUpdatesAnimated: completion:]` where user would see UI glitches/flashing. [Jesse Squires](https://github.com/jessesquires) [(019c990)](https://github.com/Instagram/IGListKit/commit/019c990312eea4203c7388a83b50685d426aa372)

- Fix bug where scroll position would be incorrect in call to `-[IGListAdapter scrollToObject:supplementaryKinds:scrollDirection:scrollPosition:animated:` with scrollDirection/scrollPosition of UICollectionViewScrollDirectionVertical/UICollectionViewScrollPositionCenteredVertically or UICollectionViewScrollDirectionHorizontal/UICollectionViewScrollPositionCenteredHorizontally and with a collection view with nonzero contentInset. [David Yamnitsky](https://github.com/nitsky) [(5cc0fcd)](https://github.com/Instagram/IGListKit/commit/5cc0fcd1d77d6296f57ce1c298301b9881cb4d4a)

- Fix a crash when reusing collection views between embedded `IGListAdapter`s. [Ryan Nystrom](https://github.com/rnystrom) [(#517)](https://github.com/Instagram/IGListKit/pull/517)

- Only collect batch updates when explicitly inside the batch update block, execute them otherwise. Fixes dropped updates. [Ryan Nystrom](https://github.com/rnystrom) [(#494)](https://github.com/Instagram/IGListKit/pull/494)

- Remove objects that return `nil` diff identifiers before updating. [Ryan Nystrom](https://github.com/rnystrom) [(af984ca)](https://github.com/Instagram/IGListKit/commit/af984ca81d4d8c4ba3012be1a45f69670a832ccf)

- Fix a potential crash when a section is moved and deleted at the same time. [Ryan Nystrom](https://github.com/rnystrom) [(#577)](https://github.com/Instagram/IGListKit/pull/577)

- Prevent section controllers and supplementary sources from returning negative sizes that crash `UICollectionViewFlowLayout`. [Ryan Nystrom](https://github.com/rnystrom) [(#583)](https://github.com/Instagram/IGListKit/pull/583)

- Add nullability annotations to a few more headers. [Adlai Holler](https://github.com/Adlai-Holler) [(#626)](https://github.com/Instagram/IGListKit/pull/626)

- Fix a crash when inserting or deleting from the same index within the same batch-update application. [Ryan Nystrom](https://github.com/rnystrom) [(#616)](https://github.com/Instagram/IGListKit/pull/616)

- `IGListSectionType` protocol was removed and its methods were absorted into the `IGListSectionController` base class with default implementations. [Ryan Nystrom](https://github.com/rnystrom) ([3102852](https://github.com/Instagram/IGListKit/commit/3102852ce258274e8727f9094695a9c331e1abf3))

- When setting the collection view on `IGListAdapter`, its layout is now properly invalidated. [Jesse Squires](https://github.com/jessesquires) [(#677)](https://github.com/Instagram/IGListKit/pull/677)

- Fixes a bug when reusing `UICollectionView`s with multiple `IGListAdapter`s in an embedded environment that would accidentally `nil` the `collectionView` property of another adapter. [Ryan Nystrom](https://github.com/rnystrom) [(#721)](https://github.com/Instagram/IGListKit/pull/721)

- Fixes a bug where maintaining a reference to a section controller but not the list adapter in an async block could lead to calling `-[IGListAdapter sectionForSectionController:]` (or checking `-[IGListSectionController sectionIndex]`) and receiving an incorrect value. With the adapter check the value would be 0 because the adapter was `nil` and for the section controller property the value would be the last set index value. [Andrew Monshizadeh](https://github.com/amonshiz) [(#709)](https://github.com/Instagram/IGListKit/issues/709)

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

### Fixes

- Consider supplementary views with display and end-display events. [Ryan Nystrom](https://github.com/rnystrom) [(#470)](https://github.com/Instagram/IGListKit/pull/470)


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
