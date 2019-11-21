/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListAdapterInternal.h"

#import <IGListDiffKit/IGListAssert.h>
#import <IGListKit/IGListAdapterUpdater.h>
#import <IGListKit/IGListSupplementaryViewSource.h>

#import "IGListArrayUtilsInternal.h"
#import "IGListDebugger.h"
#import "IGListSectionControllerInternal.h"
#import "UICollectionViewLayout+InteractiveReordering.h"
#import "UIScrollView+IGListKit.h"

@implementation IGListAdapter {
    NSMapTable<UICollectionReusableView *, IGListSectionController *> *_viewSectionControllerMap;
    // An array of blocks to execute once batch updates are finished
    NSMutableArray<void (^)(void)> *_queuedCompletionBlocks;
    NSHashTable<id<IGListAdapterUpdateListener>> *_updateListeners;
}

- (void)dealloc {
    [self.sectionMap reset];
}


#pragma mark - Init

- (instancetype)initWithUpdater:(id <IGListUpdatingDelegate>)updater
                 viewController:(UIViewController *)viewController
               workingRangeSize:(NSInteger)workingRangeSize {
    IGAssertMainThread();
    IGParameterAssert(updater);

    if (self = [super init]) {
        NSPointerFunctions *keyFunctions = [updater objectLookupPointerFunctions];
        NSPointerFunctions *valueFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStrongMemory];
        NSMapTable *table = [[NSMapTable alloc] initWithKeyPointerFunctions:keyFunctions valuePointerFunctions:valueFunctions capacity:0];
        _sectionMap = [[IGListSectionMap alloc] initWithMapTable:table];

        _displayHandler = [IGListDisplayHandler new];
        _workingRangeHandler = [[IGListWorkingRangeHandler alloc] initWithWorkingRangeSize:workingRangeSize];
        _updateListeners = [NSHashTable weakObjectsHashTable];

        _viewSectionControllerMap = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality | NSMapTableStrongMemory
                                                          valueOptions:NSMapTableStrongMemory];

        _updater = updater;
        _viewController = viewController;

        [IGListDebugger trackAdapter:self];
    }
    return self;
}

- (instancetype)initWithUpdater:(id<IGListUpdatingDelegate>)updater
                 viewController:(UIViewController *)viewController {
    return [self initWithUpdater:updater
                  viewController:viewController
                workingRangeSize:0];
}

- (UICollectionView *)collectionView {
    return _collectionView;
}

- (void)setCollectionView:(UICollectionView *)collectionView {
    IGAssertMainThread();

    // if collection view has been used by a different list adapter, treat it as if we were using a new collection view
    // this happens when embedding a UICollectionView inside a UICollectionViewCell that is reused
    if (_collectionView != collectionView || _collectionView.dataSource != self) {
        // if the collection view was being used with another IGListAdapter (e.g. cell reuse)
        // destroy the previous association so the old adapter doesn't update the wrong collection view
        static NSMapTable<UICollectionView *, IGListAdapter *> *globalCollectionViewAdapterMap = nil;
        if (globalCollectionViewAdapterMap == nil) {
            globalCollectionViewAdapterMap = [NSMapTable weakToWeakObjectsMapTable];
        }
        [globalCollectionViewAdapterMap removeObjectForKey:_collectionView];
        [[globalCollectionViewAdapterMap objectForKey:collectionView] setCollectionView:nil];
        [globalCollectionViewAdapterMap setObject:self forKey:collectionView];

        // dump old registered section controllers in the case that we are changing collection views or setting for
        // the first time
        _registeredCellIdentifiers = [NSMutableSet new];
        _registeredNibNames = [NSMutableSet new];
        _registeredSupplementaryViewIdentifiers = [NSMutableSet new];
        _registeredSupplementaryViewNibNames = [NSMutableSet new];

        const BOOL settingFirstCollectionView = _collectionView == nil;

        _collectionView = collectionView;
        _collectionView.dataSource = self;

        if (@available(iOS 10.0, tvOS 10, *)) {
            _collectionView.prefetchingEnabled = NO;
        }

        [_collectionView.collectionViewLayout ig_hijackLayoutInteractiveReorderingMethodForAdapter:self];
        [_collectionView.collectionViewLayout invalidateLayout];

        [self _updateCollectionViewDelegate];

        // only construct
        if (!IGListExperimentEnabled(self.experiments, IGListExperimentGetCollectionViewAtUpdate)
            || settingFirstCollectionView) {
            [self _updateAfterPublicSettingsChange];
        }
    }
}

- (void)setDataSource:(id<IGListAdapterDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self _updateAfterPublicSettingsChange];
    }
}

// reset and configure the delegate proxy whenever this property is set
- (void)setCollectionViewDelegate:(id<UICollectionViewDelegate>)collectionViewDelegate {
    IGAssertMainThread();
    IGAssert(![collectionViewDelegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)],
             @"UICollectionViewDelegateFlowLayout conformance is automatically handled by IGListAdapter.");

    if (_collectionViewDelegate != collectionViewDelegate) {
        _collectionViewDelegate = collectionViewDelegate;
        [self _createProxyAndUpdateCollectionViewDelegate];
    }
}

- (void)setScrollViewDelegate:(id<UIScrollViewDelegate>)scrollViewDelegate {
    IGAssertMainThread();

    if (_scrollViewDelegate != scrollViewDelegate) {
        _scrollViewDelegate = scrollViewDelegate;
        [self _createProxyAndUpdateCollectionViewDelegate];
    }
}

- (void)_updateAfterPublicSettingsChange {
    id<IGListAdapterDataSource> dataSource = _dataSource;
    if (_collectionView != nil && dataSource != nil) {
        NSArray *uniqueObjects = objectsWithDuplicateIdentifiersRemoved([dataSource objectsForListAdapter:self]);
        [self _updateObjects:uniqueObjects dataSource:dataSource];
    }
}

- (void)_createProxyAndUpdateCollectionViewDelegate {
    // there is a known bug with accessibility and using an NSProxy as the delegate that will cause EXC_BAD_ACCESS
    // when voiceover is enabled. it will hold an unsafe ref to the delegate
    _collectionView.delegate = nil;

    self.delegateProxy = [[IGListAdapterProxy alloc] initWithCollectionViewTarget:_collectionViewDelegate
                                                                 scrollViewTarget:_scrollViewDelegate
                                                                      interceptor:self];
    [self _updateCollectionViewDelegate];
}

- (void)_updateCollectionViewDelegate {
    // set up the delegate to the proxy so the adapter can intercept events
    // default to the adapter simply being the delegate
    _collectionView.delegate = (id<UICollectionViewDelegate>)self.delegateProxy ?: self;
}


#pragma mark - Scrolling

- (void)scrollToObject:(id)object
    supplementaryKinds:(NSArray<NSString *> *)supplementaryKinds
       scrollDirection:(UICollectionViewScrollDirection)scrollDirection
        scrollPosition:(UICollectionViewScrollPosition)scrollPosition
              animated:(BOOL)animated {
    IGAssertMainThread();
    IGParameterAssert(object != nil);

    const NSInteger section = [self sectionForObject:object];
    if (section == NSNotFound) {
        return;
    }

    UICollectionView *collectionView = self.collectionView;
    const BOOL avoidLayout = IGListExperimentEnabled(self.experiments, IGListExperimentAvoidLayoutOnScrollToObject);

    // Experiment with skipping the forced layout to avoid creating off-screen cells.
    // Calling [collectionView layoutIfNeeded] creates the current visible cells that will no longer be visible after the scroll.
    // We can avoid that by asking the UICollectionView (not the layout object) for the attributes. So if the attributes are not
    // ready, the UICollectionView will call -prepareLayout, return the attributes, but doesn't generate the cells just yet.
    if (!avoidLayout) {
        [collectionView setNeedsLayout];
        [collectionView layoutIfNeeded];
    }

    NSIndexPath *indexPathFirstElement = [NSIndexPath indexPathForItem:0 inSection:section];

    // collect the layout attributes for the cell and supplementary views for the first index
    // this will break if there are supplementary views beyond item 0
    NSMutableArray<UICollectionViewLayoutAttributes *> *attributes = nil;

    const NSInteger numberOfItems = [collectionView numberOfItemsInSection:section];
    if (numberOfItems > 0) {
        attributes = [self _layoutAttributesForItemAndSupplementaryViewAtIndexPath:indexPathFirstElement
                                                                supplementaryKinds:supplementaryKinds].mutableCopy;

        if (numberOfItems > 1) {
            NSIndexPath *indexPathLastElement = [NSIndexPath indexPathForItem:(numberOfItems - 1) inSection:section];
            UICollectionViewLayoutAttributes *lastElementattributes = [self _layoutAttributesForItemAndSupplementaryViewAtIndexPath:indexPathLastElement
                                                                                                                 supplementaryKinds:supplementaryKinds].firstObject;
            if (lastElementattributes != nil) {
                [attributes addObject:lastElementattributes];
            }
        }
    } else {
        NSMutableArray *supplementaryAttributes = [NSMutableArray new];
        for (NSString* supplementaryKind in supplementaryKinds) {
            UICollectionViewLayoutAttributes *supplementaryAttribute = [self _layoutAttributesForSupplementaryViewOfKind:supplementaryKind atIndexPath:indexPathFirstElement];
            if (supplementaryAttribute != nil) {
                [supplementaryAttributes addObject: supplementaryAttribute];
            }
        }
        attributes = supplementaryAttributes;
    }

    CGFloat offsetMin = 0.0;
    CGFloat offsetMax = 0.0;
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        const CGRect frame = attribute.frame;
        CGFloat originMin;
        CGFloat endMax;
        switch (scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal:
                originMin = CGRectGetMinX(frame);
                endMax = CGRectGetMaxX(frame);
                break;
            case UICollectionViewScrollDirectionVertical:
                originMin = CGRectGetMinY(frame);
                endMax = CGRectGetMaxY(frame);
                break;
        }

        // find the minimum origin value of all the layout attributes
        if (attribute == attributes.firstObject || originMin < offsetMin) {
            offsetMin = originMin;
        }
        // find the maximum end value of all the layout attributes
        if (attribute == attributes.firstObject || endMax > offsetMax) {
            offsetMax = endMax;
        }
    }

    const CGFloat offsetMid = (offsetMin + offsetMax) / 2.0;
    const CGFloat collectionViewWidth = collectionView.bounds.size.width;
    const CGFloat collectionViewHeight = collectionView.bounds.size.height;
    const UIEdgeInsets contentInset = collectionView.ig_contentInset;
    CGPoint contentOffset = collectionView.contentOffset;
    switch (scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: {
            switch (scrollPosition) {
                case UICollectionViewScrollPositionRight:
                    contentOffset.x = offsetMax - collectionViewWidth + contentInset.right;
                    break;
                case UICollectionViewScrollPositionCenteredHorizontally: {
                    const CGFloat insets = (contentInset.left - contentInset.right) / 2.0;
                    contentOffset.x = offsetMid - collectionViewWidth / 2.0 - insets;
                    break;
                }
                case UICollectionViewScrollPositionLeft:
                case UICollectionViewScrollPositionNone:
                case UICollectionViewScrollPositionTop:
                case UICollectionViewScrollPositionBottom:
                case UICollectionViewScrollPositionCenteredVertically:
                    contentOffset.x = offsetMin - contentInset.left;
                    break;
            }
            const CGFloat maxOffsetX = collectionView.contentSize.width - collectionView.frame.size.width + contentInset.right;
            const CGFloat minOffsetX = -contentInset.left;
            contentOffset.x = MIN(contentOffset.x, maxOffsetX);
            contentOffset.x = MAX(contentOffset.x, minOffsetX);
            break;
        }
        case UICollectionViewScrollDirectionVertical: {
            switch (scrollPosition) {
                case UICollectionViewScrollPositionBottom:
                    contentOffset.y = offsetMax - collectionViewHeight + contentInset.bottom;
                    break;
                case UICollectionViewScrollPositionCenteredVertically: {
                    const CGFloat insets = (contentInset.top - contentInset.bottom) / 2.0;
                    contentOffset.y = offsetMid - collectionViewHeight / 2.0 - insets;
                    break;
                }
                case UICollectionViewScrollPositionTop:
                case UICollectionViewScrollPositionNone:
                case UICollectionViewScrollPositionLeft:
                case UICollectionViewScrollPositionRight:
                case UICollectionViewScrollPositionCenteredHorizontally:
                    contentOffset.y = offsetMin - contentInset.top;
                    break;
            }
            CGFloat maxHeight;
            if (avoidLayout) {
                // If we don't call [collectionView layoutIfNeeded], the collectionView.contentSize does not get updated.
                // So lets use the layout object, since it should have been updated by now.
                maxHeight = collectionView.collectionViewLayout.collectionViewContentSize.height;
            } else {
                maxHeight = collectionView.contentSize.height;
            }
            const CGFloat maxOffsetY = maxHeight - collectionView.frame.size.height + contentInset.bottom;
            const CGFloat minOffsetY = -contentInset.top;
            contentOffset.y = MIN(contentOffset.y, maxOffsetY);
            contentOffset.y = MAX(contentOffset.y, minOffsetY);
            break;
        }
    }

    [collectionView setContentOffset:contentOffset animated:animated];
}

#pragma mark - Editing

- (void)performUpdatesAnimated:(BOOL)animated completion:(IGListUpdaterCompletion)completion {
    IGAssertMainThread();

    id<IGListAdapterDataSource> dataSource = self.dataSource;
    UICollectionView *collectionView = self.collectionView;
    if (dataSource == nil || collectionView == nil) {
        IGLKLog(@"Warning: Your call to %s is ignored as dataSource or collectionView haven't been set.", __PRETTY_FUNCTION__);
        if (completion) {
            completion(NO);
        }
        return;
    }

    NSArray *fromObjects = self.sectionMap.objects;

    IGListToObjectBlock toObjectsBlock;
    __weak __typeof__(self) weakSelf = self;
    if (IGListExperimentEnabled(self.experiments, IGListExperimentDeferredToObjectCreation)) {
        toObjectsBlock = ^NSArray *{
            __typeof__(self) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return nil;
            }
            return [dataSource objectsForListAdapter:strongSelf];
        };
    } else {
        NSArray *newObjects = [dataSource objectsForListAdapter:self];
        toObjectsBlock = ^NSArray *{
            return newObjects;
        };
    }

    [self _enterBatchUpdates];
    [self.updater performUpdateWithCollectionViewBlock:[self _collectionViewBlock]
                                           fromObjects:fromObjects
                                        toObjectsBlock:toObjectsBlock
                                              animated:animated
                                 objectTransitionBlock:^(NSArray *toObjects) {
                                     // temporarily capture the item map that we are transitioning from in case
                                     // there are any item deletes at the same
                                     weakSelf.previousSectionMap = [weakSelf.sectionMap copy];

                                     [weakSelf _updateObjects:toObjects dataSource:dataSource];
                                 } completion:^(BOOL finished) {
                                     // release the previous items
                                     weakSelf.previousSectionMap = nil;

                                     [weakSelf _notifyDidUpdate:IGListAdapterUpdateTypePerformUpdates animated:animated];
                                     if (completion) {
                                         completion(finished);
                                     }
                                     [weakSelf _exitBatchUpdates];
                                 }];
}

- (void)reloadDataWithCompletion:(nullable IGListUpdaterCompletion)completion {
    IGAssertMainThread();

    id<IGListAdapterDataSource> dataSource = self.dataSource;
    UICollectionView *collectionView = self.collectionView;
    if (dataSource == nil || collectionView == nil) {
        IGLKLog(@"Warning: Your call to %s is ignored as dataSource or collectionView haven't been set.", __PRETTY_FUNCTION__);
        if (completion) {
            completion(NO);
        }
        return;
    }

    NSArray *uniqueObjects = objectsWithDuplicateIdentifiersRemoved([dataSource objectsForListAdapter:self]);

    __weak __typeof__(self) weakSelf = self;
    [self.updater reloadDataWithCollectionViewBlock:[self _collectionViewBlock]
                                  reloadUpdateBlock:^{
                                      // purge all section controllers from the item map so that they are regenerated
                                      [weakSelf.sectionMap reset];
                                      [weakSelf _updateObjects:uniqueObjects dataSource:dataSource];
                                  } completion:^(BOOL finished) {
                                      [weakSelf _notifyDidUpdate:IGListAdapterUpdateTypeReloadData animated:NO];
                                      if (completion) {
                                          completion(finished);
                                      }
                                  }];
}

- (void)reloadObjects:(NSArray *)objects {
    IGAssertMainThread();
    IGParameterAssert(objects);

    NSMutableIndexSet *sections = [NSMutableIndexSet new];

    // use the item map based on whether or not we're in an update block
    IGListSectionMap *map = [self _sectionMapUsingPreviousIfInUpdateBlock:YES];

    for (id object in objects) {
        // look up the item using the map's lookup function. might not be the same item
        const NSInteger section = [map sectionForObject:object];
        const BOOL notFound = section == NSNotFound;
        if (notFound) {
            continue;
        }
        [sections addIndex:section];

        // reverse lookup the item using the section. if the pointer has changed the trigger update events and swap items
        if (object != [map objectForSection:section]) {
            [map updateObject:object];
            [[map sectionControllerForSection:section] didUpdateToObject:object];
        }
    }

    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Tried to reload the adapter without a collection view");

    [self.updater reloadCollectionView:collectionView sections:sections];
}

- (void)addUpdateListener:(id<IGListAdapterUpdateListener>)updateListener {
    IGAssertMainThread();
    IGParameterAssert(updateListener != nil);

    [_updateListeners addObject:updateListener];
}

- (void)removeUpdateListener:(id<IGListAdapterUpdateListener>)updateListener {
    IGAssertMainThread();
    IGParameterAssert(updateListener != nil);

    [_updateListeners removeObject:updateListener];
}

- (void)_notifyDidUpdate:(IGListAdapterUpdateType)update animated:(BOOL)animated {
    for (id<IGListAdapterUpdateListener> listener in _updateListeners) {
        [listener listAdapter:self didFinishUpdate:update animated:animated];
    }
}


#pragma mark - List Items & Sections

- (nullable IGListSectionController *)sectionControllerForSection:(NSInteger)section {
    IGAssertMainThread();

    return [self.sectionMap sectionControllerForSection:section];
}

- (NSInteger)sectionForSectionController:(IGListSectionController *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);

    return [self.sectionMap sectionForSectionController:sectionController];
}

- (IGListSectionController *)sectionControllerForObject:(id)object {
    IGAssertMainThread();
    IGParameterAssert(object != nil);

    return [self.sectionMap sectionControllerForObject:object];
}

- (id)objectForSectionController:(IGListSectionController *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);

    const NSInteger section = [self.sectionMap sectionForSectionController:sectionController];
    return [self.sectionMap objectForSection:section];
}

- (id)objectAtSection:(NSInteger)section {
    IGAssertMainThread();

    return [self.sectionMap objectForSection:section];
}

- (NSInteger)sectionForObject:(id)item {
    IGAssertMainThread();
    IGParameterAssert(item != nil);

    return [self.sectionMap sectionForObject:item];
}

- (NSArray *)objects {
    IGAssertMainThread();

    return self.sectionMap.objects;
}

- (id<IGListSupplementaryViewSource>)_supplementaryViewSourceAtIndexPath:(NSIndexPath *)indexPath {
    IGListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];
    return [sectionController supplementaryViewSource];
}

- (NSArray<IGListSectionController *> *)visibleSectionControllers {
    IGAssertMainThread();
    return [[self.displayHandler visibleListSections] allObjects];
}

- (NSArray *)visibleObjects {
    IGAssertMainThread();
    NSArray<UICollectionViewCell *> *visibleCells = [self.collectionView visibleCells];
    NSMutableSet *visibleObjects = [NSMutableSet new];
    for (UICollectionViewCell *cell in visibleCells) {
        IGListSectionController *sectionController = [self sectionControllerForView:cell];
        IGAssert(sectionController != nil, @"Section controller nil for cell %@", cell);
        if (sectionController != nil) {
            const NSInteger section = [self sectionForSectionController:sectionController];
            id object = [self objectAtSection:section];
            IGAssert(object != nil, @"Object not found for section controller %@ at section %li", sectionController, (long)section);
            if (object != nil) {
                [visibleObjects addObject:object];
            }
        }
    }
    return [visibleObjects allObjects];
}

- (NSArray<UICollectionViewCell *> *)visibleCellsForObject:(id)object {
    IGAssertMainThread();
    IGParameterAssert(object != nil);

    const NSInteger section = [self.sectionMap sectionForObject:object];
    if (section == NSNotFound) {
        return [NSArray new];
    }

    NSArray<UICollectionViewCell *> *visibleCells = [self.collectionView visibleCells];
    UICollectionView *collectionView = self.collectionView;
    NSPredicate *controllerPredicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewCell* cell, NSDictionary* bindings) {
        NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
        return indexPath.section == section;
    }];

    return [visibleCells filteredArrayUsingPredicate:controllerPredicate];
}


#pragma mark - Layout

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGAssertMainThread();
    id<IGListAdapterPerformanceDelegate> performanceDelegate = self.performanceDelegate;
    [performanceDelegate listAdapterWillCallSize:self];

    IGListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];
    const CGSize size = [sectionController sizeForItemAtIndex:indexPath.item];
    const CGSize positiveSize = CGSizeMake(MAX(size.width, 0.0), MAX(size.height, 0.0));

    [performanceDelegate listAdapter:self didCallSizeOnSectionController:sectionController atIndex:indexPath.item];
    return positiveSize;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    IGAssertMainThread();
    id <IGListSupplementaryViewSource> supplementaryViewSource = [self _supplementaryViewSourceAtIndexPath:indexPath];
    if ([[supplementaryViewSource supportedElementKinds] containsObject:elementKind]) {
        const CGSize size = [supplementaryViewSource sizeForSupplementaryViewOfKind:elementKind atIndex:indexPath.item];
        return CGSizeMake(MAX(size.width, 0.0), MAX(size.height, 0.0));
    }
    return CGSizeZero;
}


#pragma mark - Private API

- (IGListCollectionViewBlock)_collectionViewBlock {
    if (IGListExperimentEnabled(self.experiments, IGListExperimentGetCollectionViewAtUpdate)) {
        __weak __typeof__(self) weakSelf = self;
        return ^UICollectionView *{ return weakSelf.collectionView; };
    } else {
        __weak UICollectionView *collectionView = _collectionView;
        return ^UICollectionView *{ return collectionView; };
    }
}

// this method is what updates the "source of truth"
// this should only be called just before the collection view is updated
- (void)_updateObjects:(NSArray *)objects dataSource:(id<IGListAdapterDataSource>)dataSource {
    IGParameterAssert(dataSource != nil);

#if DEBUG
    for (id object in objects) {
        IGAssert([object isEqualToDiffableObject:object], @"Object instance %@ not equal to itself. This will break infra map tables.", object);
    }
#endif

    NSMutableArray<IGListSectionController *> *sectionControllers = [NSMutableArray new];
    NSMutableArray *validObjects = [NSMutableArray new];

    IGListSectionMap *map = self.sectionMap;

    // collect items that have changed since the last update
    NSMutableSet *updatedObjects = [NSMutableSet new];

    // push the view controller and collection context into a local thread container so they are available on init
    // for IGListSectionController subclasses after calling [super init]
    IGListSectionControllerPushThread(self.viewController, self);

    for (id object in objects) {
        // infra checks to see if a controller exists
        IGListSectionController *sectionController = [map sectionControllerForObject:object];

        // if not, query the data source for a new one
        if (sectionController == nil) {
            sectionController = [dataSource listAdapter:self sectionControllerForObject:object];
        }

        if (sectionController == nil) {
            IGLKLog(@"WARNING: Ignoring nil section controller returned by data source %@ for object %@.",
                    dataSource, object);
            continue;
        }

        // in case the section controller was created outside of -listAdapter:sectionControllerForObject:
        sectionController.collectionContext = self;
        sectionController.viewController = self.viewController;

        // check if the item has changed instances or is new
        const NSInteger oldSection = [map sectionForObject:object];
        if (oldSection == NSNotFound || [map objectForSection:oldSection] != object) {
            [updatedObjects addObject:object];
        }

        [sectionControllers addObject:sectionController];
        [validObjects addObject:object];
    }

#if DEBUG
    IGAssert([NSSet setWithArray:sectionControllers].count == sectionControllers.count,
             @"Section controllers array is not filled with unique objects; section controllers are being reused");
#endif

    // clear the view controller and collection context
    IGListSectionControllerPopThread();

    [map updateWithObjects:validObjects sectionControllers:sectionControllers];

    // now that the maps have been created and contexts are assigned, we consider the section controller "fully loaded"
    for (id object in updatedObjects) {
        [[map sectionControllerForObject:object] didUpdateToObject:object];
    }

    NSInteger itemCount = 0;
    for (IGListSectionController *sectionController in sectionControllers) {
        itemCount += [sectionController numberOfItems];
    }

    [self _updateBackgroundViewShouldHide:itemCount > 0];
}

- (void)_updateBackgroundViewShouldHide:(BOOL)shouldHide {
    if (self.isInUpdateBlock) {
        return; // will be called again when update block completes
    }
    UIView *backgroundView = [self.dataSource emptyViewForListAdapter:self];
    // don't do anything if the client is using the same view
    if (backgroundView != _collectionView.backgroundView) {
        // collection view will just stack the background views underneath each other if we do not remove the previous
        // one first. also fine if it is nil
        [_collectionView.backgroundView removeFromSuperview];
        _collectionView.backgroundView = backgroundView;
    }
    _collectionView.backgroundView.hidden = shouldHide;
}

- (BOOL)_itemCountIsZero {
    __block BOOL isZero = YES;
    [self.sectionMap enumerateUsingBlock:^(id  _Nonnull object, IGListSectionController * _Nonnull sectionController, NSInteger section, BOOL * _Nonnull stop) {
        if (sectionController.numberOfItems > 0) {
            isZero = NO;
            *stop = YES;
        }
    }];
    return isZero;
}

- (IGListSectionMap *)_sectionMapUsingPreviousIfInUpdateBlock:(BOOL)usePreviousMapIfInUpdateBlock {
    // if we are inside an update block, we may have to use the /previous/ item map for some operations
    IGListSectionMap *previousSectionMap = self.previousSectionMap;
    if (usePreviousMapIfInUpdateBlock && self.isInUpdateBlock && previousSectionMap != nil) {
        return previousSectionMap;
    } else {
        return self.sectionMap;
    }
}

- (NSArray<NSIndexPath *> *)indexPathsFromSectionController:(IGListSectionController *)sectionController
                                                    indexes:(NSIndexSet *)indexes
                                 usePreviousIfInUpdateBlock:(BOOL)usePreviousIfInUpdateBlock {
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray new];

    IGListSectionMap *map = [self _sectionMapUsingPreviousIfInUpdateBlock:usePreviousIfInUpdateBlock];
    const NSInteger section = [map sectionForSectionController:sectionController];
    if (section != NSNotFound) {
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
        }];
    }
    return indexPaths;
}

- (NSIndexPath *)indexPathForSectionController:(IGListSectionController *)controller
                                         index:(NSInteger)index
                    usePreviousIfInUpdateBlock:(BOOL)usePreviousIfInUpdateBlock {
    IGListSectionMap *map = [self _sectionMapUsingPreviousIfInUpdateBlock:usePreviousIfInUpdateBlock];
    const NSInteger section = [map sectionForSectionController:controller];
    if (section == NSNotFound) {
        return nil;
    } else {
        return [NSIndexPath indexPathForItem:index inSection:section];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)_layoutAttributesForItemAndSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath
                                                                                      supplementaryKinds:(NSArray<NSString *> *)supplementaryKinds {
    NSMutableArray<UICollectionViewLayoutAttributes *> *attributes = [NSMutableArray new];

    UICollectionViewLayoutAttributes *cellAttributes = [self _layoutAttributesForItemAtIndexPath:indexPath];
    if (cellAttributes) {
        [attributes addObject:cellAttributes];
    }

    for (NSString *kind in supplementaryKinds) {
        UICollectionViewLayoutAttributes *supplementaryAttributes = [self _layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
        if (supplementaryAttributes) {
            [attributes addObject:supplementaryAttributes];
        }
    }

    return attributes;
}

- (nullable UICollectionViewLayoutAttributes *)_layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (IGListExperimentEnabled(self.experiments, IGListExperimentAvoidLayoutOnScrollToObject)) {
        return [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    } else {
        return [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    }
}

- (nullable UICollectionViewLayoutAttributes *)_layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind
                                                                               atIndexPath:(NSIndexPath *)indexPath {
    if (IGListExperimentEnabled(self.experiments, IGListExperimentAvoidLayoutOnScrollToObject)) {
        return [self.collectionView layoutAttributesForSupplementaryElementOfKind:elementKind atIndexPath:indexPath];
    } else {
        return [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
    }
}

- (void)mapView:(UICollectionReusableView *)view toSectionController:(IGListSectionController *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(view != nil);
    IGParameterAssert(sectionController != nil);
    [_viewSectionControllerMap setObject:sectionController forKey:view];
}

- (nullable IGListSectionController *)sectionControllerForView:(UICollectionReusableView *)view {
    IGAssertMainThread();
    return [_viewSectionControllerMap objectForKey:view];
}

- (void)removeMapForView:(UICollectionReusableView *)view {
    IGAssertMainThread();
    [_viewSectionControllerMap removeObjectForKey:view];
}

- (void)_deferBlockBetweenBatchUpdates:(void (^)(void))block {
    IGAssertMainThread();
    if (_queuedCompletionBlocks == nil) {
        block();
    } else {
        [_queuedCompletionBlocks addObject:block];
    }
}

- (void)_enterBatchUpdates {
    _queuedCompletionBlocks = [NSMutableArray new];
}

- (void)_exitBatchUpdates {
    NSArray *blocks = [_queuedCompletionBlocks copy];
    _queuedCompletionBlocks = nil;
    for (void (^block)(void) in blocks) {
        block();
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    id<IGListAdapterPerformanceDelegate> performanceDelegate = self.performanceDelegate;
    [performanceDelegate listAdapterWillCallScroll:self];

    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollViewDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [scrollViewDelegate scrollViewDidScroll:scrollView];
    }
    NSArray<IGListSectionController *> *visibleSectionControllers = [self visibleSectionControllers];
    for (IGListSectionController *sectionController in visibleSectionControllers) {
        [[sectionController scrollDelegate] listAdapter:self didScrollSectionController:sectionController];
    }

    [performanceDelegate listAdapter:self didCallScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollViewDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [scrollViewDelegate scrollViewWillBeginDragging:scrollView];
    }
    NSArray<IGListSectionController *> *visibleSectionControllers = [self visibleSectionControllers];
    for (IGListSectionController *sectionController in visibleSectionControllers) {
        [[sectionController scrollDelegate] listAdapter:self willBeginDraggingSectionController:sectionController];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollViewDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [scrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    NSArray<IGListSectionController *> *visibleSectionControllers = [self visibleSectionControllers];
    for (IGListSectionController *sectionController in visibleSectionControllers) {
        [[sectionController scrollDelegate] listAdapter:self didEndDraggingSectionController:sectionController willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollViewDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [scrollViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
    NSArray<IGListSectionController *> *visibleSectionControllers = [self visibleSectionControllers];
    for (IGListSectionController *sectionController in visibleSectionControllers) {
        id<IGListScrollDelegate> scrollDelegate = [sectionController scrollDelegate];
        if ([scrollDelegate respondsToSelector:@selector(listAdapter:didEndDeceleratingSectionController:)]) {
            [scrollDelegate listAdapter:self didEndDeceleratingSectionController:sectionController];
        }
    }
}

#pragma mark - IGListCollectionContext

- (CGSize)containerSize {
    return self.collectionView.bounds.size;
}

- (UIEdgeInsets)containerInset {
    return self.collectionView.contentInset;
}

- (UIEdgeInsets)adjustedContainerInset {
    return self.collectionView.ig_contentInset;
}

- (CGSize)insetContainerSize {
    UICollectionView *collectionView = self.collectionView;
    return UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.ig_contentInset).size;
}

- (IGListCollectionScrollingTraits)scrollingTraits {
    UICollectionView *collectionView = self.collectionView;
    return (IGListCollectionScrollingTraits) {
        .isTracking = collectionView.isTracking,
        .isDragging = collectionView.isDragging,
        .isDecelerating = collectionView.isDecelerating,
    };
}

- (CGSize)containerSizeForSectionController:(IGListSectionController *)sectionController {
    const UIEdgeInsets inset = sectionController.inset;
    return CGSizeMake(self.containerSize.width - inset.left - inset.right,
                      self.containerSize.height - inset.top - inset.bottom);
}

- (NSInteger)indexForCell:(UICollectionViewCell *)cell sectionController:(nonnull IGListSectionController *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(cell != nil);
    IGParameterAssert(sectionController != nil);
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    IGAssert(indexPath == nil
             || indexPath.section == [self sectionForSectionController:sectionController],
             @"Requesting a cell from another section controller is not allowed.");
    return indexPath != nil ? indexPath.item : NSNotFound;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
                                    sectionController:(IGListSectionController *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);

    // if this is accessed while a cell is being dequeued or displaying working range elements, just return nil
    if (_isDequeuingCell || _isSendingWorkingRangeDisplayUpdates) {
        return nil;
    }

    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:YES];
    // prevent querying the collection view if it isn't fully reloaded yet for the current data set
    if (indexPath != nil
        && indexPath.section < [self.collectionView numberOfSections]) {
        // only return a cell if it belongs to the section controller
        // this association is created in -collectionView:cellForItemAtIndexPath:
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if ([self sectionControllerForView:cell] == sectionController) {
            return cell;
        }
    }
    return nil;
}

- (NSArray<UICollectionViewCell *> *)visibleCellsForSectionController:(IGListSectionController *)sectionController {
    NSMutableArray *cells = [NSMutableArray new];
    UICollectionView *collectionView = self.collectionView;
    NSArray *visibleCells = [collectionView visibleCells];
    const NSInteger section = [self sectionForSectionController:sectionController];
    for (UICollectionViewCell *cell in visibleCells) {
        if ([collectionView indexPathForCell:cell].section == section) {
            [cells addObject:cell];
        }
    }
    return cells;
}

- (NSArray<NSIndexPath *> *)visibleIndexPathsForSectionController:(IGListSectionController *) sectionController {
    NSMutableArray *paths = [NSMutableArray new];
    UICollectionView *collectionView = self.collectionView;
    NSArray *visiblePaths = [collectionView indexPathsForVisibleItems];
    const NSInteger section = [self sectionForSectionController:sectionController];
    for (NSIndexPath *path in visiblePaths) {
        if (path.section == section) {
            [paths addObject:path];
        }
    }
    return paths;
}

- (void)deselectItemAtIndex:(NSInteger)index
          sectionController:(IGListSectionController *)sectionController
                   animated:(BOOL)animated {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
}

- (void)selectItemAtIndex:(NSInteger)index
        sectionController:(IGListSectionController *)sectionController
                 animated:(BOOL)animated
           scrollPosition:(UICollectionViewScrollPosition)scrollPosition {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    [self.collectionView selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass
                                          withReuseIdentifier:(NSString *)reuseIdentifier
                                         forSectionController:(IGListSectionController *)sectionController
                                                      atIndex:(NSInteger)index {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(cellClass != nil);
    IGParameterAssert(index >= 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Dequeueing cell of class %@ with reuseIdentifier %@ from section controller %@ without a collection view at index %li", NSStringFromClass(cellClass), reuseIdentifier, sectionController, (long)index);
    NSString *identifier = IGListReusableViewIdentifier(cellClass, nil, reuseIdentifier);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    if (![self.registeredCellIdentifiers containsObject:identifier]) {
        [self.registeredCellIdentifiers addObject:identifier];
        [collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass
                                         forSectionController:(IGListSectionController *)sectionController
                                                      atIndex:(NSInteger)index {
    return [self dequeueReusableCellOfClass:cellClass withReuseIdentifier:nil forSectionController:sectionController atIndex:index];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellFromStoryboardWithIdentifier:(NSString *)identifier
                                                              forSectionController:(IGListSectionController *)sectionController
                                                                           atIndex:(NSInteger)index {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(identifier.length > 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Reloading adapter without a collection view.");
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    return [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (UICollectionViewCell *)dequeueReusableCellWithNibName:(NSString *)nibName
                                                  bundle:(NSBundle *)bundle
                                    forSectionController:(IGListSectionController *)sectionController
                                                 atIndex:(NSInteger)index {
    IGAssertMainThread();
    IGParameterAssert([nibName length] > 0);
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(index >= 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Dequeueing cell with nib name %@ and bundle %@ from section controller %@ without a collection view at index %li.", nibName, bundle, sectionController, (long)index);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    if (![self.registeredNibNames containsObject:nibName]) {
        [self.registeredNibNames addObject:nibName];
        UINib *nib = [UINib nibWithNibName:nibName bundle:bundle];
        [collectionView registerNib:nib forCellWithReuseIdentifier:nibName];
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:nibName forIndexPath:indexPath];
}

- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                         forSectionController:(IGListSectionController *)sectionController
                                                                        class:(Class)viewClass
                                                                      atIndex:(NSInteger)index {
    IGAssertMainThread();
    IGParameterAssert(elementKind.length > 0);
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(viewClass != nil);
    IGParameterAssert(index >= 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Dequeueing cell of class %@ from section controller %@ without a collection view at index %li with supplementary view %@", NSStringFromClass(viewClass), sectionController, (long)index, elementKind);
    NSString *identifier = IGListReusableViewIdentifier(viewClass, elementKind, nil);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    if (![self.registeredSupplementaryViewIdentifiers containsObject:identifier]) {
        [self.registeredSupplementaryViewIdentifiers addObject:identifier];
        [collectionView registerClass:viewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
    }
    return [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier forIndexPath:indexPath];
}

- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewFromStoryboardOfKind:(NSString *)elementKind
                                                                             withIdentifier:(NSString *)identifier
                                                                       forSectionController:(IGListSectionController *)sectionController
                                                                                    atIndex:(NSInteger)index {
    IGAssertMainThread();
    IGParameterAssert(elementKind.length > 0);
    IGParameterAssert(identifier.length > 0);
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(index >= 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Dequeueing Supplementary View from storyboard of kind %@ with identifier %@ for section controller %@ without a collection view at index %li", elementKind, identifier, sectionController, (long)index);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    return [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier forIndexPath:indexPath];
}

- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                         forSectionController:(IGListSectionController *)sectionController
                                                                      nibName:(NSString *)nibName
                                                                       bundle:(NSBundle *)bundle
                                                                      atIndex:(NSInteger)index {
    IGAssertMainThread();
    IGParameterAssert([nibName length] > 0);
    IGParameterAssert([elementKind length] > 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Reloading adapter without a collection view.");
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    if (![self.registeredSupplementaryViewNibNames containsObject:nibName]) {
        [self.registeredSupplementaryViewNibNames addObject:nibName];
        UINib *nib = [UINib nibWithNibName:nibName bundle:bundle];
        [collectionView registerNib:nib forSupplementaryViewOfKind:elementKind withReuseIdentifier:nibName];
    }
    return [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:nibName forIndexPath:indexPath];
}

- (void)performBatchAnimated:(BOOL)animated updates:(void (^)(id<IGListBatchContext>))updates completion:(void (^)(BOOL))completion {
    IGAssertMainThread();
    IGParameterAssert(updates != nil);
    IGAssert(self.collectionView != nil, @"Performing batch updates without a collection view.");

    [self _enterBatchUpdates];
    __weak __typeof__(self) weakSelf = self;
    [self.updater performUpdateWithCollectionViewBlock:[self _collectionViewBlock] animated:animated itemUpdates:^{
        weakSelf.isInUpdateBlock = YES;
        // the adapter acts as the batch context with its API stripped to just the IGListBatchContext protocol
        updates(weakSelf);
        weakSelf.isInUpdateBlock = NO;
    } completion: ^(BOOL finished) {
        [weakSelf _updateBackgroundViewShouldHide:![weakSelf _itemCountIsZero]];
        [weakSelf _notifyDidUpdate:IGListAdapterUpdateTypeItemUpdates animated:animated];
        if (completion) {
            completion(finished);
        }
        [weakSelf _exitBatchUpdates];
    }];
}

- (void)scrollToSectionController:(IGListSectionController *)sectionController
                          atIndex:(NSInteger)index
                   scrollPosition:(UICollectionViewScrollPosition)scrollPosition
                         animated:(BOOL)animated {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);

    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)invalidateLayoutForSectionController:(IGListSectionController *)sectionController
                                  completion:(void (^)(BOOL finished))completion{
    const NSInteger section = [self sectionForSectionController:sectionController];
    const NSInteger items = [_collectionView numberOfItemsInSection:section];

    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray new];
    for (NSInteger item = 0; item < items; item++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:item inSection:section]];
    }

    UICollectionViewLayout *layout = _collectionView.collectionViewLayout;
    UICollectionViewLayoutInvalidationContext *context = [[[layout.class invalidationContextClass] alloc] init];
    [context invalidateItemsAtIndexPaths:indexPaths];

    __weak __typeof__(_collectionView) weakCollectionView = _collectionView;

    // do not call -[UICollectionView performBatchUpdates:completion:] while already updating. defer it until completed.
    [self _deferBlockBetweenBatchUpdates:^{
        [weakCollectionView performBatchUpdates:^{
            [layout invalidateLayoutWithContext:context];
        } completion:completion];
    }];
}

#pragma mark - IGListBatchContext

- (void)reloadInSectionController:(IGListSectionController *)sectionController atIndexes:(NSIndexSet *)indexes {
    IGAssertMainThread();
    IGParameterAssert(indexes != nil);
    IGParameterAssert(sectionController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Tried to reload the adapter from %@ without a collection view at indexes %@.", sectionController, indexes);

    if (indexes.count == 0) {
        return;
    }

    /**
     UICollectionView is not designed to support -reloadSections: or -reloadItemsAtIndexPaths: during batch updates.
     Internally it appears to convert these operations to a delete+insert. However the transformation is too simple
     in that it doesn't account for the item's section being moved (naturally or explicitly) and can queue animation
     collisions.

     If you have an object at section 2 with 4 items and attempt to reload item at index 1, you would create an
     NSIndexPath at section: 2, item: 1. Within -performBatchUpdates:, UICollectionView converts this to a delete
     and insert at the same NSIndexPath.

     If a section were inserted at position 2, the original section 2 has naturally shifted to section 3. However,
     the insert NSIndexPath is section: 2, item: 1. Now the UICollectionView has a section animation at section 2,
     as well as an item insert animation at section: 2, item: 1, and it will throw an exception.

     IGListAdapter tracks the before/after mapping of section controllers to make precise NSIndexPath conversions.
     */
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        NSIndexPath *fromIndexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:YES];
        NSIndexPath *toIndexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
        // index paths could be nil if a section controller is prematurely reloading or a reload was batched with
        // the section controller being deleted
        if (fromIndexPath != nil && toIndexPath != nil) {
            [self.updater reloadItemInCollectionView:collectionView fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
        }
    }];
}

- (void)insertInSectionController:(IGListSectionController *)sectionController atIndexes:(NSIndexSet *)indexes {
    IGAssertMainThread();
    IGParameterAssert(indexes != nil);
    IGParameterAssert(sectionController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Inserting items from %@ without a collection view at indexes %@.", sectionController, indexes);

    if (indexes.count == 0) {
        return;
    }

    NSArray *indexPaths = [self indexPathsFromSectionController:sectionController indexes:indexes usePreviousIfInUpdateBlock:NO];
    [self.updater insertItemsIntoCollectionView:collectionView indexPaths:indexPaths];
    [self _updateBackgroundViewShouldHide:![self _itemCountIsZero]];
}

- (void)deleteInSectionController:(IGListSectionController *)sectionController atIndexes:(NSIndexSet *)indexes {
    IGAssertMainThread();
    IGParameterAssert(indexes != nil);
    IGParameterAssert(sectionController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Deleting items from %@ without a collection view at indexes %@.", sectionController, indexes);

    if (indexes.count == 0) {
        return;
    }

    NSArray *indexPaths = [self indexPathsFromSectionController:sectionController indexes:indexes usePreviousIfInUpdateBlock:YES];
    [self.updater deleteItemsFromCollectionView:collectionView indexPaths:indexPaths];
    [self _updateBackgroundViewShouldHide:![self _itemCountIsZero]];
}

- (void)invalidateLayoutInSectionController:(IGListSectionController *)sectionController atIndexes:(NSIndexSet *)indexes {
    IGAssertMainThread();
    IGParameterAssert(indexes != nil);
    IGParameterAssert(sectionController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Invalidating items from %@ without a collection view at indexes %@.", sectionController, indexes);

    if (indexes.count == 0) {
        return;
    }

    NSArray *indexPaths = [self indexPathsFromSectionController:sectionController indexes:indexes usePreviousIfInUpdateBlock:NO];
    UICollectionViewLayout *layout = collectionView.collectionViewLayout;
    UICollectionViewLayoutInvalidationContext *context = [[[layout.class invalidationContextClass] alloc] init];
    [context invalidateItemsAtIndexPaths:indexPaths];
    [layout invalidateLayoutWithContext:context];
}

- (void)moveInSectionController:(IGListSectionController *)sectionController fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(fromIndex >= 0);
    IGParameterAssert(toIndex >= 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Moving items from %@ without a collection view from index %li to index %li.",
             sectionController, (long)fromIndex, (long)toIndex);

    NSIndexPath *fromIndexPath = [self indexPathForSectionController:sectionController index:fromIndex usePreviousIfInUpdateBlock:YES];
    NSIndexPath *toIndexPath = [self indexPathForSectionController:sectionController index:toIndex usePreviousIfInUpdateBlock:NO];

    if (fromIndexPath == nil || toIndexPath == nil) {
        return;
    }

    [self.updater moveItemInCollectionView:collectionView fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)reloadSectionController:(IGListSectionController *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Reloading items from %@ without a collection view.", sectionController);

    IGListSectionMap *map = [self _sectionMapUsingPreviousIfInUpdateBlock:YES];
    const NSInteger section = [map sectionForSectionController:sectionController];
    if (section == NSNotFound) {
        return;
    }

    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section];
    [self.updater reloadCollectionView:collectionView sections:sections];
    [self _updateBackgroundViewShouldHide:![self _itemCountIsZero]];
}

- (void)moveSectionControllerInteractive:(IGListSectionController *)sectionController
                               fromIndex:(NSInteger)fromIndex
                                 toIndex:(NSInteger)toIndex NS_AVAILABLE_IOS(9_0) {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(fromIndex >= 0);
    IGParameterAssert(toIndex >= 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Moving section %@ without a collection view from index %li to index %li.",
             sectionController, (long)fromIndex, (long)toIndex);
    IGAssert(self.moveDelegate != nil, @"Moving section %@ without a moveDelegate set", sectionController);

    if (fromIndex != toIndex) {
        id<IGListAdapterDataSource> dataSource = self.dataSource;

        NSArray *previousObjects = [self.sectionMap objects];

        if (self.isLastInteractiveMoveToLastSectionIndex) {
            self.isLastInteractiveMoveToLastSectionIndex = NO;
        }
        else if (fromIndex < toIndex) {
            toIndex -= 1;
        }

        NSMutableArray *mutObjects = [previousObjects mutableCopy];
        id object = [previousObjects objectAtIndex:fromIndex];
        [mutObjects removeObjectAtIndex:fromIndex];
        [mutObjects insertObject:object atIndex:toIndex];

        NSArray *objects = [mutObjects copy];

        // inform the data source to update its model
        [self.moveDelegate listAdapter:self moveObject:object from:previousObjects to:objects];

        // update our model based on that provided by the data source
        NSArray<id<IGListDiffable>> *updatedObjects = [dataSource objectsForListAdapter:self];
        [self _updateObjects:updatedObjects dataSource:dataSource];
    }

    // even if from and to index are equal, we need to perform the "move"
    // iOS interactively moves items, not sections, so we might have actually moved the item
    // to the end of the preceeding section or beginning of the following section
    [self.updater moveSectionInCollectionView:collectionView fromIndex:fromIndex toIndex:toIndex];
}

- (void)moveInSectionControllerInteractive:(IGListSectionController *)sectionController
                                 fromIndex:(NSInteger)fromIndex
                                   toIndex:(NSInteger)toIndex NS_AVAILABLE_IOS(9_0) {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(fromIndex >= 0);
    IGParameterAssert(toIndex >= 0);

    [sectionController moveObjectFromIndex:fromIndex toIndex:toIndex];
}

- (void)revertInvalidInteractiveMoveFromIndexPath:(NSIndexPath *)sourceIndexPath
                                      toIndexPath:(NSIndexPath *)destinationIndexPath NS_AVAILABLE_IOS(9_0) {
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Reverting move without a collection view from %@ to %@.",
             sourceIndexPath, destinationIndexPath);

    // revert by moving back in the opposite direction
    [collectionView moveItemAtIndexPath:destinationIndexPath toIndexPath:sourceIndexPath];
}

@end
