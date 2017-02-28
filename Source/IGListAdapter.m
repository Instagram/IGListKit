/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListAdapterInternal.h"

#import <IGListKit/IGListAssert.h>
#import <IGListKit/IGListAdapterUpdater.h>
#import <IGListKit/IGListDisplayDelegate.h>
#import <IGListKit/IGListSupplementaryViewSource.h>

#import "IGListSectionControllerInternal.h"

@implementation IGListAdapter {
    NSMapTable<UICollectionReusableView *, IGListSectionController<IGListSectionType> *> *_viewSectionControllerMap;
    BOOL _isDequeuingCell;
    BOOL _isSendingWorkingRangeDisplayUpdates;
}

- (void)dealloc {
    // on iOS 9 setting the dataSource has side effects that can invalidate the layout and seg fault
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        // properties are assign for <iOS 9
        _collectionView.dataSource = nil;
        _collectionView.delegate = nil;
    }
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

        _displayHandler = [[IGListDisplayHandler alloc] init];
        _workingRangeHandler = [[IGListWorkingRangeHandler alloc] initWithWorkingRangeSize:workingRangeSize];

        _viewSectionControllerMap = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality | NSMapTableStrongMemory
                                                          valueOptions:NSMapTableStrongMemory];

        _updater = updater;
        _viewController = viewController;
    }
    return self;
}

- (IGListCollectionView *)collectionView {
    return (IGListCollectionView *)_collectionView;
}

- (void)setCollectionView:(IGListCollectionView *)collectionView {
    IGAssertMainThread();

    // if collection view has been used by a different list adapter, treat it as if we were using a new collection view
    // this happens when embedding a IGListCollectionView inside a UICollectionViewCell that is reused
    if (_collectionView != collectionView || _collectionView.dataSource != self) {
        // if the collection view was being used with another IGListAdapter (e.g. cell reuse)
        // destroy the previous association so the old adapter doesn't update the wrong collection view
        static NSMapTable<IGListCollectionView *, IGListAdapter *> *globalCollectionViewAdapterMap = nil;
        if (globalCollectionViewAdapterMap == nil) {
            globalCollectionViewAdapterMap = [NSMapTable weakToWeakObjectsMapTable];
        }
        [[globalCollectionViewAdapterMap objectForKey:collectionView] setCollectionView:nil];
        [globalCollectionViewAdapterMap setObject:self forKey:collectionView];

        // dump old registered section controllers in the case that we are changing collection views or setting for
        // the first time
        _registeredCellClasses = [NSMutableSet new];
        _registeredNibNames = [NSMutableSet new];
        _registeredSupplementaryViewIdentifiers = [NSMutableSet new];
        _registeredSupplementaryViewNibNames = [NSMutableSet new];

        _collectionView = collectionView;
        _collectionView.dataSource = self;

        [self updateCollectionViewDelegate];
        [self updateAfterPublicSettingsChange];
    }
}

- (void)setDataSource:(id<IGListAdapterDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self updateAfterPublicSettingsChange];
    }
}

// reset and configure the delegate proxy whenever this property is set
- (void)setCollectionViewDelegate:(id<UICollectionViewDelegate>)collectionViewDelegate {
    IGAssertMainThread();
    IGAssert(![collectionViewDelegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)],
             @"UICollectionViewDelegateFlowLayout conformance is automatically handled by IGListAdapter.");

    if (_collectionViewDelegate != collectionViewDelegate) {
        _collectionViewDelegate = collectionViewDelegate;
        [self createProxyAndUpdateCollectionViewDelegate];
    }
}

- (void)setScrollViewDelegate:(id<UIScrollViewDelegate>)scrollViewDelegate {
    IGAssertMainThread();

    if (_scrollViewDelegate != scrollViewDelegate) {
        _scrollViewDelegate = scrollViewDelegate;
        [self createProxyAndUpdateCollectionViewDelegate];
    }
}

- (void)updateAfterPublicSettingsChange {
    id<IGListAdapterDataSource> dataSource = _dataSource;
    if (_collectionView != nil && dataSource != nil) {
        [self updateObjects:[[dataSource objectsForListAdapter:self] copy] dataSource:dataSource];
    }
}

- (void)createProxyAndUpdateCollectionViewDelegate {
    // there is a known bug with accessibility and using an NSProxy as the delegate that will cause EXC_BAD_ACCESS
    // when voiceover is enabled. it will hold an unsafe ref to the delegate
    _collectionView.delegate = nil;

    self.delegateProxy = [[IGListAdapterProxy alloc] initWithCollectionViewTarget:_collectionViewDelegate
                                                                 scrollViewTarget:_scrollViewDelegate
                                                                      interceptor:self];
    [self updateCollectionViewDelegate];
}

- (void)updateCollectionViewDelegate {
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
    const NSInteger numberOfItems = [collectionView numberOfItemsInSection:section];
    if (numberOfItems == 0) {
        return;
    }

    // force layout before continuing
    // this method is typcially called before pushing a view controller
    // thus, before the layout process has actually happened
    [collectionView layoutIfNeeded];

    // collect the layout attributes for the cell and supplementary views for the first index
    // this will break if there are supplementary views beyond item 0
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    NSArray *attributes = [self layoutAttributesForIndexPath:indexPath supplementaryKinds:supplementaryKinds];

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
    const UIEdgeInsets contentInset = collectionView.contentInset;
    CGPoint contentOffset = collectionView.contentOffset;
    switch (scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:
            switch (scrollPosition) {
                case UICollectionViewScrollPositionRight:
                    contentOffset.x = offsetMax - collectionViewWidth - contentInset.left;
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
            break;
        case UICollectionViewScrollDirectionVertical:
            switch (scrollPosition) {
                case UICollectionViewScrollPositionBottom:
                    contentOffset.y = offsetMax - collectionViewHeight - contentInset.top;
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
            break;
    }

    [collectionView setContentOffset:contentOffset animated:animated];
}


#pragma mark - Editing

- (void)performUpdatesAnimated:(BOOL)animated completion:(IGListUpdaterCompletion)completion {
    IGAssertMainThread();

    id<IGListAdapterDataSource> dataSource = self.dataSource;
    UICollectionView *collectionView = self.collectionView;
    if (dataSource == nil || collectionView == nil) {
        if (completion) {
            completion(NO);
        }
        return;
    }

    NSArray *fromObjects = self.sectionMap.objects;
    NSArray *newObjects = [dataSource objectsForListAdapter:self];

    __weak __typeof__(self) weakSelf = self;
    [self.updater performUpdateWithCollectionView:collectionView
                                      fromObjects:fromObjects
                                        toObjects:newObjects
                                         animated:animated
                            objectTransitionBlock:^(NSArray *toObjects) {
                                // temporarily capture the item map that we are transitioning from in case
                                // there are any item deletes at the same
                                weakSelf.previousSectionMap = [weakSelf.sectionMap copy];

                                [weakSelf updateObjects:toObjects dataSource:dataSource];
                            } completion:^(BOOL finished) {
                                // release the previous items
                                weakSelf.previousSectionMap = nil;

                                if (completion) {
                                    completion(finished);
                                }
                            }];
}

- (void)reloadDataWithCompletion:(nullable IGListUpdaterCompletion)completion {
    IGAssertMainThread();

    id<IGListAdapterDataSource> dataSource = self.dataSource;
    UICollectionView *collectionView = self.collectionView;
    if (dataSource == nil || collectionView == nil) {
        if (completion) {
            completion(NO);
        }
        return;
    }

    NSArray *newItems = [[dataSource objectsForListAdapter:self] copy];

    __weak __typeof__(self) weakSelf = self;
    [self.updater reloadDataWithCollectionView:collectionView reloadUpdateBlock:^{
        // purge all section controllers from the item map so that they are regenerated
        [weakSelf.sectionMap reset];
        [weakSelf updateObjects:newItems dataSource:dataSource];
    } completion:completion];
}

- (void)reloadObjects:(NSArray *)objects {
    IGAssertMainThread();
    IGParameterAssert(objects);

    NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] init];

    // use the item map based on whether or not we're in an update block
    IGListSectionMap *map = [self sectionMapUsingPreviousIfInUpdateBlock:YES];

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


#pragma mark - List Items & Sections

- (nullable IGListSectionController <IGListSectionType> *)sectionControllerForSection:(NSInteger)section {
    IGAssertMainThread();
    
    return [self.sectionMap sectionControllerForSection:section];
}

- (NSInteger)sectionForSectionController:(IGListSectionController <IGListSectionType> *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);

    return [self.sectionMap sectionForSectionController:sectionController];
}

- (id <IGListSectionType>)sectionControllerForObject:(id)object {
    IGAssertMainThread();
    IGParameterAssert(object != nil);

    return [self.sectionMap sectionControllerForObject:object];
}

- (id)objectForSectionController:(IGListSectionController <IGListSectionType> *)sectionController {
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

- (id<IGListSupplementaryViewSource>)supplementaryViewSourceAtIndexPath:(NSIndexPath *)indexPath {
    IGListSectionController<IGListSectionType> *sectionController = [self sectionControllerForSection:indexPath.section];
    return [sectionController supplementaryViewSource];
}

- (NSArray<IGListSectionController<IGListSectionType> *> *)visibleSectionControllers {
    IGAssertMainThread();
    NSArray<UICollectionViewCell *> *visibleCells = [self.collectionView visibleCells];
    NSMutableSet *visibleSectionControllers = [NSMutableSet new];
    for (UICollectionViewCell *cell in visibleCells) {
        IGListSectionController *sectionController = [self sectionControllerForView:cell];
        IGAssert(sectionController != nil, @"Section controller nil for cell %@", cell);
        if (sectionController) {
            [visibleSectionControllers addObject:sectionController];
        }
    }
    return [visibleSectionControllers allObjects];
}

- (NSArray *)visibleObjects {
    IGAssertMainThread();
    NSArray<UICollectionViewCell *> *visibleCells = [self.collectionView visibleCells];
    NSMutableSet *visibleObjects = [NSMutableSet new];
    for (UICollectionViewCell *cell in visibleCells) {
        IGListSectionController<IGListSectionType> *sectionController = [self sectionControllerForView:cell];
        IGAssert(sectionController != nil, @"Section controller nil for cell %@", cell);
        if (sectionController != nil) {
            const NSInteger section = [self sectionForSectionController:sectionController];
            id object = [self objectAtSection:section];
            IGAssert(object != nil, @"Object not found for section controller %@ at section %zi", sectionController, section);
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

    IGListSectionController <IGListSectionType> *sectionController = [self sectionControllerForSection:indexPath.section];
    return [sectionController sizeForItemAtIndex:indexPath.item];
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    IGAssertMainThread();
    id <IGListSupplementaryViewSource> supplementaryViewSource = [self supplementaryViewSourceAtIndexPath:indexPath];
    if ([[supplementaryViewSource supportedElementKinds] containsObject:elementKind]) {
        return [supplementaryViewSource sizeForSupplementaryViewOfKind:elementKind atIndex:indexPath.item];
    }
    return CGSizeZero;
}


#pragma mark - Private API

// this method is what updates the "source of truth"
// this should only be called just before the collection view is updated
- (void)updateObjects:(NSArray *)objects dataSource:(id<IGListAdapterDataSource>)dataSource {
    IGParameterAssert(dataSource != nil);

#if DEBUG
    for (id object in objects) {
        IGAssert([object isEqualToDiffableObject:object], @"Object instance %@ not equal to itself. This will break infra map tables.", object);
    }
#endif

    NSMutableArray<IGListSectionController <IGListSectionType> *> *sectionControllers = [NSMutableArray new];
    NSMutableArray *validObjects = [NSMutableArray new];

    IGListSectionMap *map = self.sectionMap;

    // collect items that have changed since the last update
    NSMutableSet *updatedObjects = [NSMutableSet new];

    // push the view controller and collection context into a local thread container so they are available on init
    // for IGListSectionController subclasses after calling [super init]
    IGListSectionControllerPushThread(self.viewController, self);

    id firstObject = objects.firstObject;
    id lastObject = objects.lastObject;

    for (id object in objects) {
        // infra checks to see if a controller exists
        IGListSectionController <IGListSectionType> *sectionController = [map sectionControllerForObject:object];

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
        sectionController.isFirstSection = (object == firstObject);
        sectionController.isLastSection = (object == lastObject);

        // check if the item has changed instances or is new
        const NSInteger oldSection = [map sectionForObject:object];
        if (oldSection == NSNotFound || [map objectForSection:oldSection] != object) {
            [updatedObjects addObject:object];
        }

        [sectionControllers addObject:sectionController];
        [validObjects addObject:object];
    }

    // clear the view controller and collection context
    IGListSectionControllerPopThread();

    [map updateWithObjects:validObjects sectionControllers:sectionControllers];

    // now that the maps have been created and contexts are assigned, we consider the section controller "fully loaded"
    for (id object in updatedObjects) {
        [[map sectionControllerForObject:object] didUpdateToObject:object];
    }

    NSInteger itemCount = 0;
    for (IGListSectionController<IGListSectionType> *sectionController in sectionControllers) {
        itemCount += [sectionController numberOfItems];
    }

    [self updateBackgroundViewShouldHide:itemCount > 0];
}

- (void)updateBackgroundViewShouldHide:(BOOL)shouldHide {
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

- (BOOL)itemCountIsZero {
    __block BOOL isZero = YES;
    [self.sectionMap enumerateUsingBlock:^(id  _Nonnull object, IGListSectionController<IGListSectionType> * _Nonnull sectionController, NSInteger section, BOOL * _Nonnull stop) {
        if (sectionController.numberOfItems > 0) {
            isZero = NO;
            *stop = YES;
        }
    }];
    return isZero;
}

- (IGListSectionMap *)sectionMapUsingPreviousIfInUpdateBlock:(BOOL)usePreviousMapIfInUpdateBlock {
    // if we are inside an update block, we may have to use the /previous/ item map for some operations
    IGListSectionMap *previousSectionMap = self.previousSectionMap;
    if (usePreviousMapIfInUpdateBlock && self.isInUpdateBlock && previousSectionMap != nil) {
        return previousSectionMap;
    } else {
        return self.sectionMap;
    }
}

- (NSArray<NSIndexPath *> *)indexPathsFromSectionController:(IGListSectionController <IGListSectionType> *)sectionController
                                                    indexes:(NSIndexSet *)indexes
                                 usePreviousIfInUpdateBlock:(BOOL)usePreviousIfInUpdateBlock {
    NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];

    IGListSectionMap *map = [self sectionMapUsingPreviousIfInUpdateBlock:usePreviousIfInUpdateBlock];
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
    IGListSectionMap *map = [self sectionMapUsingPreviousIfInUpdateBlock:usePreviousIfInUpdateBlock];
    const NSInteger section = [map sectionForSectionController:controller];
    if (section == NSNotFound) {
        return nil;
    } else {
        return [NSIndexPath indexPathForItem:index inSection:section];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForIndexPath:(NSIndexPath *)indexPath
                                                           supplementaryKinds:(NSArray<NSString *> *)supplementaryKinds {
    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
    NSMutableArray<UICollectionViewLayoutAttributes *> *attributes = [[NSMutableArray alloc] init];

    UICollectionViewLayoutAttributes *cellAttributes = [layout layoutAttributesForItemAtIndexPath:indexPath];
    if (cellAttributes) {
        [attributes addObject:cellAttributes];
    }

    for (NSString *kind in supplementaryKinds) {
        UICollectionViewLayoutAttributes *supplementaryAttributes = [layout layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
        if (supplementaryAttributes) {
            [attributes addObject:supplementaryAttributes];
        }
    }

    return attributes;
}

- (void)mapView:(UICollectionReusableView *)view toSectionController:(IGListSectionController<IGListSectionType> *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(view != nil);
    IGParameterAssert(sectionController != nil);
    [_viewSectionControllerMap setObject:sectionController forKey:view];
}

- (nullable IGListSectionController<IGListSectionType> *)sectionControllerForView:(UICollectionReusableView *)view {
    IGAssertMainThread();
    return [_viewSectionControllerMap objectForKey:view];
}

- (void)removeMapForView:(UICollectionReusableView *)view {
    IGAssertMainThread();
    [_viewSectionControllerMap removeObjectForKey:view];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionMap.objects.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    IGListSectionController <IGListSectionType> * sectionController = [self sectionControllerForSection:section];
    IGAssert(sectionController != nil, @"Nil section controller for section %zi for item %@. Check your -diffIdentifier and -isEqual: implementations.",
             section, [self.sectionMap objectForSection:section]);
    const NSInteger numberOfItems = [sectionController numberOfItems];
    IGAssert(numberOfItems >= 0, @"Cannot return negative number of items %zi for section controller %@.", numberOfItems, sectionController);
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGListSectionController<IGListSectionType> *sectionController = [self sectionControllerForSection:indexPath.section];

    // flag that a cell is being dequeued in case it tries to access a cell in the process
    _isDequeuingCell = YES;
    UICollectionViewCell *cell = [sectionController cellForItemAtIndex:indexPath.item];
    _isDequeuingCell = NO;

    IGAssert(cell != nil, @"Returned a nil cell at indexPath <%@> from section controller: <%@>", indexPath, sectionController);

    // associate the section controller with the cell so that we know which section controller is using it
    [self mapView:cell toSectionController:sectionController];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    IGListSectionController<IGListSectionType> *sectionController = [self sectionControllerForSection:indexPath.section];
    id <IGListSupplementaryViewSource> supplementarySource = [sectionController supplementaryViewSource];
    UICollectionReusableView *view = [supplementarySource viewForSupplementaryElementOfKind:kind atIndex:indexPath.item];
    IGAssert(view != nil, @"Returned a nil supplementary view at indexPath <%@> from section controller: <%@>, supplementary source: <%@>", indexPath, sectionController, supplementarySource);

    // associate the section controller with the cell so that we know which section controller is using it
    [self mapView:view toSectionController:sectionController];

    return view;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }

    IGListSectionController <IGListSectionType> * sectionController = [self sectionControllerForSection:indexPath.section];
    [sectionController didSelectItemAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }

    IGListSectionController <IGListSectionType> *sectionController = [self sectionControllerForView:cell];
    // if the section controller relationship was destroyed, reconnect it
    // this happens with iOS 10 UICollectionView display range changes
    if (sectionController == nil) {
        sectionController = [self sectionControllerForSection:indexPath.section];
        [self mapView:cell toSectionController:sectionController];
    }

    id object = [self.sectionMap objectForSection:indexPath.section];
    [self.displayHandler willDisplayCell:cell forListAdapter:self sectionController:sectionController object:object indexPath:indexPath];

    _isSendingWorkingRangeDisplayUpdates = YES;
    [self.workingRangeHandler willDisplayItemAtIndexPath:indexPath forListAdapter:self];
    _isSendingWorkingRangeDisplayUpdates = NO;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }

    IGListSectionController <IGListSectionType> *sectionController = [self sectionControllerForView:cell];
    [self.displayHandler didEndDisplayingCell:cell forListAdapter:self sectionController:sectionController indexPath:indexPath];
    [self.workingRangeHandler didEndDisplayingItemAtIndexPath:indexPath forListAdapter:self];

    // break the association between the cell and the section controller
    [self removeMapForView:cell];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:willDisplaySupplementaryView:forElementKind:atIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
    }

    IGListSectionController <IGListSectionType> *sectionController = [self sectionControllerForView:view];
    // if the section controller relationship was destroyed, reconnect it
    // this happens with iOS 10 UICollectionView display range changes
    if (sectionController == nil) {
        sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
        [self mapView:view toSectionController:sectionController];
    }

    id object = [self.sectionMap objectForSection:indexPath.section];
    [self.displayHandler willDisplaySupplementaryView:view forListAdapter:self sectionController:sectionController object:object indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
    }

    IGListSectionController <IGListSectionType> *sectionController = [self sectionControllerForView:view];
    [self.displayHandler didEndDisplayingSupplementaryView:view forListAdapter:self sectionController:sectionController indexPath:indexPath];

    [self removeMapForView:view];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollViewDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [scrollViewDelegate scrollViewDidScroll:scrollView];
    }
    NSArray<IGListSectionController<IGListSectionType> *> *visibleSectionControllers = [self visibleSectionControllers];
    for (IGListSectionController<IGListSectionType> *sectionController in visibleSectionControllers) {
        [[sectionController scrollDelegate] listAdapter:self didScrollSectionController:sectionController];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollViewDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [scrollViewDelegate scrollViewWillBeginDragging:scrollView];
    }
    NSArray<IGListSectionController<IGListSectionType> *> *visibleSectionControllers = [self visibleSectionControllers];
    for (IGListSectionController<IGListSectionType> *sectionController in visibleSectionControllers) {
        [[sectionController scrollDelegate] listAdapter:self willBeginDraggingSectionController:sectionController];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollViewDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [scrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    NSArray<IGListSectionController<IGListSectionType> *> *visibleSectionControllers = [self visibleSectionControllers];
    for (IGListSectionController<IGListSectionType> *sectionController in visibleSectionControllers) {
        [[sectionController scrollDelegate] listAdapter:self didEndDraggingSectionController:sectionController willDecelerate:decelerate];
    }
}


#pragma mark - IGListCollectionContext

- (CGSize)containerSize {
    return UIEdgeInsetsInsetRect(self.collectionView.bounds, self.collectionView.contentInset).size;
}

- (NSInteger)indexForCell:(UICollectionViewCell *)cell sectionController:(nonnull IGListSectionController<IGListSectionType> *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(cell != nil);
    IGParameterAssert(sectionController != nil);
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    IGAssert(indexPath.section == [self sectionForSectionController:sectionController],
             @"Requesting a cell from another section controller is not allowed.");
    return indexPath != nil ? indexPath.item : NSNotFound;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
                                    sectionController:(IGListSectionController <IGListSectionType> *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);

    // if this is accessed while a cell is being dequeued or displaying working range elements, just return nil
    if (_isDequeuingCell || _isSendingWorkingRangeDisplayUpdates) {
        return nil;
    }

    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
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

- (NSArray<UICollectionViewCell *> *)visibleCellsForSectionController:(IGListSectionController<IGListSectionType> *)sectionController {
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

- (NSArray<NSIndexPath *> *)visibleIndexPathsForSectionController:(IGListSectionController<IGListSectionType> *) sectionController {
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
          sectionController:(IGListSectionController<IGListSectionType> *)sectionController
                   animated:(BOOL)animated {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass
                                         forSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                                                      atIndex:(NSInteger)index {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(cellClass != nil);
    IGParameterAssert(index >= 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Dequeueing cell of class %@ from section controller %@ without a collection view at index %zi", NSStringFromClass(cellClass), sectionController, index);
    NSString *identifier = IGListReusableViewIdentifier(cellClass, nil, nil);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    if (![self.registeredCellClasses containsObject:cellClass]) {
        [self.registeredCellClasses addObject:cellClass];
        [collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellFromStoryboardWithIdentifier:(NSString *)identifier
                                                              forSectionController:(IGListSectionController <IGListSectionType> *)sectionController
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
                                    forSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                                                 atIndex:(NSInteger)index {
    IGAssertMainThread();
    IGParameterAssert([nibName length] > 0);
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(index >= 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Dequeueing cell with nib name %@ and bundle %@ from section controller %@ without a collection view at index %zi.", nibName, bundle, sectionController, index);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    if (![self.registeredNibNames containsObject:nibName]) {
        [self.registeredNibNames addObject:nibName];
        UINib *nib = [UINib nibWithNibName:nibName bundle:bundle];
        [collectionView registerNib:nib forCellWithReuseIdentifier:nibName];
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:nibName forIndexPath:indexPath];
}

- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                         forSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                                                                        class:(Class)viewClass
                                                                      atIndex:(NSInteger)index {
    IGAssertMainThread();
    IGParameterAssert(elementKind.length > 0);
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(viewClass != nil);
    IGParameterAssert(index >= 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Dequeueing cell of class %@ from section controller %@ without a collection view at index %zi with supplementary view %@", NSStringFromClass(viewClass), sectionController, index, elementKind);
    NSString *identifier = IGListReusableViewIdentifier(viewClass, nil, elementKind);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    if (![self.registeredSupplementaryViewIdentifiers containsObject:identifier]) {
        [self.registeredSupplementaryViewIdentifiers addObject:identifier];
        [collectionView registerClass:viewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
    }
    return [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier forIndexPath:indexPath];
}

- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewFromStoryboardOfKind:(NSString *)elementKind
                                                                             withIdentifier:(NSString *)identifier
                                                                       forSectionController:(IGListSectionController <IGListSectionType> *)sectionController
                                                                                    atIndex:(NSInteger)index {
    IGAssertMainThread();
    IGParameterAssert(elementKind.length > 0);
    IGParameterAssert(identifier.length > 0);
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(index >= 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Dequeueing Supplementary View from storyboard of kind %@ with identifier %@ for section controller %@ without a collection view at index %zi", elementKind, identifier, sectionController, index);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    return [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier forIndexPath:indexPath];
}

- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                         forSectionController:(IGListSectionController<IGListSectionType> *)sectionController
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

- (void)reloadInSectionController:(IGListSectionController<IGListSectionType> *)sectionController atIndexes:(NSIndexSet *)indexes {
    IGAssertMainThread();
    IGParameterAssert(indexes != nil);
    IGParameterAssert(sectionController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Tried to reload the adapter from %@ without a collection view at indexes %@.", sectionController, indexes);

    if (indexes.count == 0) {
        return;
    }

    if (self.isInUpdateBlock) {
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
        [self deleteInSectionController:sectionController atIndexes:indexes];
        [self insertInSectionController:sectionController atIndexes:indexes];
    } else {
        NSArray *indexPaths = [self indexPathsFromSectionController:sectionController indexes:indexes usePreviousIfInUpdateBlock:YES];
        [self.updater reloadItemsInCollectionView:collectionView indexPaths:indexPaths];
        [self updateBackgroundViewShouldHide:![self itemCountIsZero]];
    }
}

- (void)insertInSectionController:(IGListSectionController<IGListSectionType> *)sectionController atIndexes:(NSIndexSet *)indexes {
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
    [self updateBackgroundViewShouldHide:![self itemCountIsZero]];
}

- (void)deleteInSectionController:(IGListSectionController<IGListSectionType> *)sectionController atIndexes:(NSIndexSet *)indexes {
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
    [self updateBackgroundViewShouldHide:![self itemCountIsZero]];
}

- (void)moveInSectionController:(IGListSectionController<IGListSectionType> *)sectionController fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    IGParameterAssert(fromIndex >= 0);
    IGParameterAssert(toIndex >= 0);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Moving items from %@ without a collection view from index %zi to index %zi.",
             sectionController, fromIndex, toIndex);

    NSIndexPath *fromIndexPath = [self indexPathForSectionController:sectionController index:fromIndex usePreviousIfInUpdateBlock:YES];
    NSIndexPath *toIndexPath = [self indexPathForSectionController:sectionController index:toIndex usePreviousIfInUpdateBlock:NO];

    if (fromIndexPath == nil || toIndexPath == nil) {
        return;
    }

    [self.updater moveItemInCollectionView:collectionView fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)reloadSectionController:(IGListSectionController <IGListSectionType> *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Reloading items from %@ without a collection view.", sectionController);

    IGListSectionMap *map = [self sectionMapUsingPreviousIfInUpdateBlock:YES];
    const NSInteger section = [map sectionForSectionController:sectionController];
    if (section == NSNotFound) {
        return;
    }

    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section];
    [self.updater reloadCollectionView:collectionView sections:sections];
    [self updateBackgroundViewShouldHide:![self itemCountIsZero]];
}

- (void)performBatchAnimated:(BOOL)animated updates:(void (^)())updates completion:(void (^)(BOOL))completion {
    IGAssertMainThread();
    IGParameterAssert(updates != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Performing batch updates without a collection view.");

    __weak __typeof__(self) weakSelf = self;
    [self.updater performUpdateWithCollectionView:collectionView animated:animated itemUpdates:^{
        weakSelf.isInUpdateBlock = YES;
        updates();
        weakSelf.isInUpdateBlock = NO;
    } completion: ^(BOOL finished) {
        [weakSelf updateBackgroundViewShouldHide:![weakSelf itemCountIsZero]];
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)scrollToSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                          atIndex:(NSInteger)index
                   scrollPosition:(UICollectionViewScrollPosition)scrollPosition
                         animated:(BOOL)animated {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);

    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index usePreviousIfInUpdateBlock:NO];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)invalidateLayoutForSectionController:(IGListSectionController<IGListSectionType> *)sectionController
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

    void (^block)() = ^{
        [layout invalidateLayoutWithContext:context];
    };

    [_collectionView performBatchUpdates:block completion:completion];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [self sizeForItemAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self sectionControllerForSection:section] inset];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self sectionControllerForSection:section] minimumLineSpacing];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self sectionControllerForSection:section] minimumInteritemSpacing];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    return [self sizeForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    return [self sizeForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];
}

@end
