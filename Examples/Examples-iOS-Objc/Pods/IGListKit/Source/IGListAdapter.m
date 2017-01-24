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
    NSMapTable<UICollectionViewCell *, IGListSectionController<IGListSectionType> *> *_cellSectionControllerMap;
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

- (instancetype)initWithUpdater:(id <IGListUpdatingDelegate>)updatingDelegate
                 viewController:(UIViewController *)viewController
               workingRangeSize:(NSInteger)workingRangeSize {
    IGAssertMainThread();
    IGParameterAssert(updatingDelegate);

    if (self = [super init]) {
        NSPointerFunctions *keyFunctions = [updatingDelegate objectLookupPointerFunctions];
        NSPointerFunctions *valueFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStrongMemory];
        NSMapTable *table = [[NSMapTable alloc] initWithKeyPointerFunctions:keyFunctions valuePointerFunctions:valueFunctions capacity:0];
        _sectionMap = [[IGListSectionMap alloc] initWithMapTable:table];

        _displayHandler = [[IGListDisplayHandler alloc] init];
        _workingRangeHandler = [[IGListWorkingRangeHandler alloc] initWithWorkingRangeSize:workingRangeSize];

        _cellSectionControllerMap = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality | NSMapTableStrongMemory
                                                          valueOptions:NSMapTableStrongMemory];

        _updatingDelegate = updatingDelegate;
        _viewController = viewController;
    }
    return self;
}

- (IGListCollectionView *)collectionView {
    return (IGListCollectionView *)_collectionView;
}

- (void)setCollectionView:(IGListCollectionView *)collectionView {
    IGAssertMainThread();
    IGParameterAssert([collectionView isKindOfClass:[IGListCollectionView class]]);

    // if collection view has been used by a different list adapter, treat it as if we were using a new collection view
    // this happens when embedding a IGListCollectionView inside a UICollectionViewCell that is reused
    if (_collectionView != collectionView || _collectionView.dataSource != self) {
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
    if (_collectionView != nil && _dataSource != nil) {
        [self updateObjects:[[_dataSource objectsForListAdapter:self] copy]];
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

    const NSUInteger section = [self sectionForObject:object];
    if (section == NSNotFound) {
        return;
    }

    UICollectionView *collectionView = self.collectionView;
    const NSUInteger numberOfItems = [collectionView numberOfItemsInSection:section];
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
                case UICollectionViewScrollPositionCenteredHorizontally:
                    contentOffset.x = offsetMid - collectionViewWidth / 2.0 - contentInset.left;
                    break;
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
                case UICollectionViewScrollPositionCenteredVertically:
                    contentOffset.y = offsetMid - collectionViewHeight / 2.0 - contentInset.top;
                    break;
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

    NSArray *fromObjects = [self.sectionMap.objects copy];
    NSArray *newItems = [[dataSource objectsForListAdapter:self] copy];

    __weak __typeof__(self) weakSelf = self;
    [self.updatingDelegate performUpdateWithCollectionView:collectionView
                                               fromObjects:fromObjects
                                                 toObjects:newItems
                                                  animated:animated
                                     objectTransitionBlock:^(NSArray *toObjects) {
                                         // temporarily capture the item map that we are transitioning from in case
                                         // there are any item deletes at the same
                                         weakSelf.previoussectionMap = [weakSelf.sectionMap copy];

                                         [weakSelf updateObjects:toObjects];
                                     } completion:^(BOOL finished) {
                                         // release the previous items
                                         weakSelf.previoussectionMap = nil;

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
    [self.updatingDelegate reloadDataWithCollectionView:collectionView reloadUpdateBlock:^{
        // purge all section controllers from the item map so that they are regenerated
        [weakSelf.sectionMap reset];
        [weakSelf updateObjects:newItems];
    } completion:completion];
}

- (void)reloadObjects:(NSArray *)objects {
    IGAssertMainThread();
    IGParameterAssert(objects);

    NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] init];

    // use the item map based on whether or not we're in an update block
    IGListSectionMap *map = [self sectionMapAdjustForUpdateBlock:YES];

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

    [self.updatingDelegate reloadCollectionView:collectionView sections:sections];
}


#pragma mark - List Items & Sections

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
    
    const NSUInteger section = [self.sectionMap sectionForSectionController:sectionController];
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

    return [self.sectionMap.objects copy];
}

- (id<IGListSupplementaryViewSource>)supplementaryViewSourceAtIndexPath:(NSIndexPath *)indexPath {
    IGListSectionController<IGListSectionType> *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
    return [sectionController supplementaryViewSource];
}

- (NSArray<IGListSectionController<IGListSectionType> *> *)visibleSectionControllers {
    IGAssertMainThread();
    NSArray<UICollectionViewCell *> *visibleCells = [self.collectionView visibleCells];
    NSMutableSet *visibleSectionControllers = [NSMutableSet new];
    for (UICollectionViewCell *cell in visibleCells) {
        IGListSectionController *sectionController = [self sectionControllerForCell:cell];
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
        IGListSectionController<IGListSectionType> *sectionController = [self sectionControllerForCell:cell];
        IGAssert(sectionController != nil, @"Section controller nil for cell %@", cell);
        if (sectionController != nil) {
            const NSUInteger section = [self sectionForSectionController:sectionController];
            id object = [self objectAtSection:section];
            IGAssert(object != nil, @"Object not found for section controller %@ at section %zi", sectionController, section);
            if (object != nil) {
                [visibleObjects addObject:object];
            }
        }
    }
    return [visibleObjects allObjects];
}


#pragma mark - Layout

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGAssertMainThread();

    IGListSectionController <IGListSectionType> *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
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
- (void)updateObjects:(NSArray *)objects {
#if DEBUG
    for (id object in objects) {
        IGAssert([object isEqual:object], @"Object instance %@ not equal to itself. This will break infra map tables.", object);
    }
#endif

    NSMutableArray<IGListSectionController <IGListSectionType> *> *sectionControllers = [[NSMutableArray alloc] init];
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
            sectionController = [self.dataSource listAdapter:self sectionControllerForObject:object];
        }

        IGAssert(sectionController != nil, @"Data source <%@> cannot return a nil section controller.", self.dataSource);
        if (sectionController == nil) {
            continue;
        }

        // in case the section controller was created outside of -listAdapter:sectionControllerForObject:
        sectionController.collectionContext = self;
        sectionController.viewController = self.viewController;
        sectionController.isFirstSection = (object == firstObject);
        sectionController.isLastSection = (object == lastObject);

        // check if the item has changed instances or is new
        const NSUInteger oldSection = [map sectionForObject:object];
        if (oldSection == NSNotFound || [map objectForSection:oldSection] != object) {
            [updatedObjects addObject:object];
        }

        [sectionControllers addObject:sectionController];
    }

    // clear the view controller and collection context
    IGListSectionControllerPopThread();

    [map updateWithObjects:objects sectionControllers:[sectionControllers copy]];

    // now that the maps have been created and contexts are assigned, we consider the section controller "fully loaded"
    for (id object in updatedObjects) {
        [[map sectionControllerForObject:object] didUpdateToObject:object];
    }

    NSUInteger itemCount = 0;
    for (IGListSectionController<IGListSectionType> *sectionController in sectionControllers) {
        itemCount += [sectionController numberOfItems];
    }

    [self updateBackgroundViewWithItemCount:itemCount];
}

- (void)updateBackgroundViewWithItemCount:(NSUInteger)itemCount {
    UIView *backgroundView = [self.dataSource emptyViewForListAdapter:self];
    // don't do anything if the client is using the same view
    if (backgroundView != _collectionView.backgroundView) {
        // collection view will just stack the background views underneath each other if we do not remove the previous
        // one first. also fine if it is nil
        [_collectionView.backgroundView removeFromSuperview];
        _collectionView.backgroundView = backgroundView;
    }
    _collectionView.backgroundView.hidden = itemCount > 0;
}

- (IGListSectionMap *)sectionMapAdjustForUpdateBlock:(BOOL)adjustForUpdateBlock {
    // if we are inside an update block, we may have to use the /previous/ item map for some operations
    if (adjustForUpdateBlock && self.isInUpdateBlock && self.previoussectionMap != nil) {
        return self.previoussectionMap;
    } else {
        return self.sectionMap;
    }
}

- (NSArray<NSIndexPath *> *)indexPathsFromSectionController:(IGListSectionController <IGListSectionType> *)sectionController
                                                    indexes:(NSIndexSet *)indexes
                                       adjustForUpdateBlock:(BOOL)adjustForUpdateBlock {
    NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];

    IGListSectionMap *map = [self sectionMapAdjustForUpdateBlock:adjustForUpdateBlock];

    const NSUInteger section = [map sectionForSectionController:sectionController];
    if (section != NSNotFound) {
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
        }];
    }
    return [indexPaths copy];
}

- (NSIndexPath *)indexPathForSectionController:(IGListSectionController *)controller index:(NSInteger)index {
    const NSUInteger section = [self.sectionMap sectionForSectionController:controller];
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

    return [attributes copy];
}

- (void)mapCell:(UICollectionViewCell *)cell toSectionController:(IGListSectionController<IGListSectionType> *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(cell != nil);
    IGParameterAssert(sectionController != nil);
    [_cellSectionControllerMap setObject:sectionController forKey:cell];
}

- (nullable IGListSectionController<IGListSectionType> *)sectionControllerForCell:(UICollectionViewCell *)cell {
    IGAssertMainThread();
    return [_cellSectionControllerMap objectForKey:cell];
}

- (void)removeMapForCell:(UICollectionViewCell *)cell {
    IGAssertMainThread();
    [_cellSectionControllerMap removeObjectForKey:cell];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionMap.objects.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    IGListSectionController <IGListSectionType> * sectionController = [self.sectionMap sectionControllerForSection:section];
    IGAssert(sectionController != nil, @"Nil section controller for section %zi for item %@. Check your -diffIdentifier and -isEqual: implementations.",
             section, [self.sectionMap objectForSection:section]);
    const NSInteger numberOfItems = [sectionController numberOfItems];
    IGAssert(numberOfItems >= 0, @"Cannot return negative number of items %zi for section controller %@.", numberOfItems, sectionController);
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGListSectionController<IGListSectionType> *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];

    // flag that a cell is being dequeued in case it tries to access a cell in the process
    _isDequeuingCell = YES;
    UICollectionViewCell *cell = [sectionController cellForItemAtIndex:indexPath.item];
    _isDequeuingCell = NO;

    IGAssert(cell != nil, @"Returned a nil cell at indexPath <%@> from section controller: <%@>", indexPath, sectionController);

    // associate the section controller with the cell so that we know which section controller is using it
    [self mapCell:cell toSectionController:sectionController];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    IGListSectionController<IGListSectionType> *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
    id <IGListSupplementaryViewSource> supplementarySource = [sectionController supplementaryViewSource];
    UICollectionReusableView *view = [supplementarySource viewForSupplementaryElementOfKind:kind atIndex:indexPath.item];
    IGAssert(view != nil, @"Returned a nil supplementary view at indexPath <%@> from section controller: <%@>, supplementary source: <%@>", indexPath, sectionController, supplementarySource);
    return view;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }

    IGListSectionController <IGListSectionType> * sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
    [sectionController didSelectItemAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }

    IGListSectionController <IGListSectionType> *sectionController = [self sectionControllerForCell:cell];
    // if the section controller relationship was destroyed, reconnect it
    // this happens with iOS 10 UICollectionView display range changes
    if (sectionController == nil) {
        sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
        [self mapCell:cell toSectionController:sectionController];
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

    IGListSectionController <IGListSectionType> *sectionController = [self sectionControllerForCell:cell];
    [self.displayHandler didEndDisplayingCell:cell forListAdapter:self sectionController:sectionController indexPath:indexPath];
    [self.workingRangeHandler didEndDisplayingItemAtIndexPath:indexPath forListAdapter:self];

    // break the association between the cell and the section controller
    [self removeMapForCell:cell];
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

    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index];
    // prevent querying the collection view if it isn't fully reloaded yet for the current data set
    if (indexPath != nil
        && indexPath.section < [self.collectionView numberOfSections]) {
        // only return a cell if it belongs to the section controller
        // this association is created in -collectionView:cellForItemAtIndexPath:
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if ([self sectionControllerForCell:cell] == sectionController) {
            return cell;
        }
    }
    return nil;
}

- (NSArray<UICollectionViewCell *> *)visibleCellsForSectionController:(IGListSectionController<IGListSectionType> *)sectionController {
    NSMutableArray *cells = [NSMutableArray new];
    UICollectionView *collectionView = self.collectionView;
    NSArray *visibleCells = [collectionView visibleCells];
    const NSUInteger section = [self sectionForSectionController:sectionController];
    for (UICollectionViewCell *cell in visibleCells) {
        if ([collectionView indexPathForCell:cell].section == section) {
            [cells addObject:cell];
        }
    }
    return [cells copy];
}

- (void)deselectItemAtIndex:(NSInteger)index
          sectionController:(IGListSectionController<IGListSectionType> *)sectionController
                   animated:(BOOL)animated {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index];
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
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index];
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
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index];
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
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index];
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
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index];
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
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index];
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
    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index];
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

    NSArray *indexPaths = [self indexPathsFromSectionController:sectionController indexes:indexes adjustForUpdateBlock:YES];
    [self.updatingDelegate reloadItemsInCollectionView:collectionView indexPaths:indexPaths];
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

    NSArray *indexPaths = [self indexPathsFromSectionController:sectionController indexes:indexes adjustForUpdateBlock:NO];
    [self.updatingDelegate insertItemsIntoCollectionView:collectionView indexPaths:indexPaths];
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

    NSArray *indexPaths = [self indexPathsFromSectionController:sectionController indexes:indexes adjustForUpdateBlock:YES];
    [self.updatingDelegate deleteItemsFromCollectionView:collectionView indexPaths:indexPaths];
}

- (void)reloadSectionController:(IGListSectionController <IGListSectionType> *)sectionController {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Reloading items from %@ without a collection view.", sectionController);

    IGListSectionMap *map = [self sectionMapAdjustForUpdateBlock:YES];
    const NSInteger section = [map sectionForSectionController:sectionController];
    if (section == NSNotFound) {
        return;
    }

    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section];
    [self.updatingDelegate reloadCollectionView:collectionView sections:sections];
}

- (void)performBatchAnimated:(BOOL)animated updates:(void (^)())updates completion:(void (^)(BOOL))completion {
    IGAssertMainThread();
    IGParameterAssert(updates != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Performing batch updates without a collection view.");

    __weak __typeof__(self) weakSelf = self;
    [self.updatingDelegate performUpdateWithCollectionView:collectionView animated:animated itemUpdates:^{
        weakSelf.isInUpdateBlock = YES;
        updates();
        weakSelf.isInUpdateBlock = NO;
    } completion:completion];
}

- (void)scrollToSectionController:(IGListSectionController<IGListSectionType> *)sectionController
                          atIndex:(NSInteger)index
                   scrollPosition:(UICollectionViewScrollPosition)scrollPosition
                         animated:(BOOL)animated {
    IGAssertMainThread();
    IGParameterAssert(sectionController != nil);

    NSIndexPath *indexPath = [self indexPathForSectionController:sectionController index:index];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [self sizeForItemAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self.sectionMap sectionControllerForSection:section] inset];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self.sectionMap sectionControllerForSection:section] minimumLineSpacing];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self.sectionMap sectionControllerForSection:section] minimumInteritemSpacing];
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
