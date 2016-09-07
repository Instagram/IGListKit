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

#import "IGListItemControllerInternal.h"
#import "NSIndexSet+PrettyDescription.h"

@implementation IGListAdapter {
    NSMapTable<UICollectionViewCell *, IGListItemController<IGListItemType> *> *_cellItemControllerMap;
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

- (instancetype)initWithUpdatingDelegate:(id <IGListUpdatingDelegate>)updatingDelegate
                          viewController:(UIViewController *)viewController
                        workingRangeSize:(NSUInteger)workingRangeSize {
    IGAssertMainThread();
    IGParameterAssert(updatingDelegate);

    if (self = [super init]) {
        NSPointerFunctions *keyFunctions = [updatingDelegate itemLookupPointerFunctions];
        NSPointerFunctions *valueFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStrongMemory];
        NSMapTable *table = [[NSMapTable alloc] initWithKeyPointerFunctions:keyFunctions valuePointerFunctions:valueFunctions capacity:0];
        _itemMap = [[IGListItemMap alloc] initWithMapTable:table];

        _displayHandler = [[IGListDisplayHandler alloc] init];
        _workingRangeHandler = [[IGListWorkingRangeHandler alloc] initWithWorkingRangeSize:workingRangeSize];

        _cellItemControllerMap = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality | NSMapTableStrongMemory
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

    if (_collectionView != collectionView) {
        // dump old registered item controllers in the case that we are changing collection views or setting for
        // the first time
        _registeredCellClasses = [NSMutableSet new];
        _registeredSupplementaryViewClasses = [NSMutableSet new];

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
        [self updateItems:[_dataSource itemsForListAdapter:self]];

        if (IGListExperimentEnabled(self.experiments, IGListExperimentUICVReloadedInSetter)) {
            [_collectionView reloadData];
        }
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

- (void)scrollToItem:(id)item
  supplementaryKinds:(NSArray<NSString *> *)supplementaryKinds
     scrollDirection:(UICollectionViewScrollDirection)scrollDirection
            animated:(BOOL)animated {
    IGAssertMainThread();
    IGParameterAssert(item != nil);

    const NSUInteger section = [self sectionForItem:item];
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

    CGFloat offset = 0.0;
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        const CGRect frame = attribute.frame;
        CGFloat origin;
        switch (scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal:
                origin = CGRectGetMinX(frame);
                break;
            case UICollectionViewScrollDirectionVertical:
                origin = CGRectGetMinY(frame);
                break;
        }

        // find the minimum origin value of all the layout attributes
        if (attribute == attributes.firstObject || origin < offset) {
            offset = origin;
        }
    }

    const UIEdgeInsets contentInset = collectionView.contentInset;
    CGPoint contentOffset = collectionView.contentOffset;
    switch (scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:
            contentOffset.x = offset - contentInset.left;
            break;
        case UICollectionViewScrollDirectionVertical:
            contentOffset.y = offset - contentInset.top;
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

    NSArray *fromItems = [self.itemMap.items copy];
    NSArray *newItems = [dataSource itemsForListAdapter:self];

    __weak __typeof__(self) weakSelf = self;
    [self.updatingDelegate performUpdateWithCollectionView:collectionView
                                                 fromItems:fromItems
                                                   toItems:newItems
                                                  animated:animated
                                       itemTransitionBlock:^(NSArray *toItems) {
                                           // temporarily capture the item map that we are transitioning from in case
                                           // there are any item deletes at the same
                                           weakSelf.previousItemMap = [weakSelf.itemMap copy];

                                           [weakSelf updateItems:toItems];
                                       } completion:^(BOOL finished) {
                                           // release the previous items
                                           weakSelf.previousItemMap = nil;

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
            return;
        }
    }

    NSArray *newItems = [dataSource itemsForListAdapter:self];

    __weak __typeof__(self) weakSelf = self;
    [self.updatingDelegate reloadDataWithCollectionView:collectionView itemUpdateBlock:^{
        // purge all item controllers from the item map so that they are regenerated
        [weakSelf.itemMap reset];
        [weakSelf updateItems:newItems];
    } completion:completion];
}

- (void)reloadItems:(NSArray *)items {
    IGAssertMainThread();
    IGParameterAssert(items);

    NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] init];

    // use the item map based on whether or not we're in an update block
    IGListItemMap *map = [self itemMapAdjustForUpdateBlock:YES];

    for (id item in items) {
        // look up the item using the map's lookup function. might not be the same item
        NSUInteger section = [map sectionForItem:item];
        IGAssert(section != NSNotFound, @"Did not find a section for item %@",item);
        [sections addIndex:section];

        // reverse lookup the item using the section. if the pointer has changed the trigger update events and swap items
        if (item != [map itemForSection:section]) {
            [map updateItem:item];
            [[map itemControllerForSection:section] didUpdateToItem:item];
        }
    }

    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Reloading adapter without a collection view");

    [self.updatingDelegate reloadCollectionView:collectionView sections:sections];
}


#pragma mark - List Items & Sections

- (NSUInteger)sectionForItemController:(IGListItemController <IGListItemType> *)itemController {
    IGAssertMainThread();
    IGParameterAssert(itemController != nil);

    return [self.itemMap sectionForItemController:itemController];
}

- (id <IGListItemType>)itemControllerForItem:(id)item {
    IGAssertMainThread();
    IGParameterAssert(item != nil);

    return [self.itemMap itemControllerForItem:item];
}

- (id)itemAtSection:(NSUInteger)section {
    IGAssertMainThread();

    return [self.itemMap itemForSection:section];
}

- (NSUInteger)sectionForItem:(id)item {
    IGAssertMainThread();
    IGParameterAssert(item != nil);

    return [self.itemMap sectionForItem:item];
}

- (NSArray *)items {
    IGAssertMainThread();

    return [self.itemMap.items copy];
}

- (id<IGListSupplementaryViewSource>)supplementaryViewSourceAtIndexPath:(NSIndexPath *)indexPath {
    IGListItemController<IGListItemType> *itemController = [self.itemMap itemControllerForSection:indexPath.section];
    return [itemController supplementaryViewSource];
}

- (NSArray<IGListItemController<IGListItemType> *> *)visibleItemControllers {
    IGAssertMainThread();
    NSArray<UICollectionViewCell *> *visibleCells = [self.collectionView visibleCells];
    NSMutableSet *visibleItemControllers = [NSMutableSet new];
    for (UICollectionViewCell *cell in visibleCells) {
        IGListItemController *itemController = [self itemControllerForCell:cell];
        IGAssert(itemController != nil, @"Item controller nil for cell %@", cell);
        if (itemController) {
            [visibleItemControllers addObject:itemController];
        }
    }
    return [visibleItemControllers allObjects];
}


#pragma mark - Layout

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGAssertMainThread();

    IGListItemController <IGListItemType> *itemController = [self.itemMap itemControllerForSection:indexPath.section];
    return [itemController sizeForItemAtIndex:indexPath.item];
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
- (void)updateItems:(NSArray *)items {
#if DEBUG
    for (id item in items) {
        IGAssert([item isEqual:item], @"Object instance %@ not equal to itself. This will break infra map tables.", item);
    }
#endif

    NSMutableArray<IGListItemController <IGListItemType> *> *itemControllers = [[NSMutableArray alloc] init];
    IGListItemMap *map = self.itemMap;

    // collect items that have changed since the last update
    NSMutableSet *updatedItems = [NSMutableSet new];

    // push the view controller and collection context into a local thread container so they are available on init
    // for IGListItemController subclasses after calling [super init]
    IGListItemControllerPushThread(self.viewController, self);

    for (id item in items) {
        // infra checks to see if a controller exists
        IGListItemController <IGListItemType> *itemController = [map itemControllerForItem:item];

        // if not, query the data source for a new one
        if (itemController == nil) {
            itemController = [self.dataSource listAdapter:self itemControllerForItem:item];
        }

        IGAssert(itemController != nil, @"Data source <%@> cannot return a nil item controller.", self.dataSource);
        if (itemController == nil) {
            break;
        }

        // in case the item controller was created outside of -listAdapter:itemControllerForItem:
        itemController.collectionContext = self;
        itemController.viewController = self.viewController;

        // check if the item has changed instances or is new
        const NSUInteger oldSection = [map sectionForItem:item];
        if (oldSection == NSNotFound || [map itemForSection:oldSection] != item) {
            [updatedItems addObject:item];
        }

        [itemControllers addObject:itemController];
    }

    // clear the view controller and collection context
    IGListItemControllerPopThread();

    [map updateWithItems:items itemControllers:itemControllers];

    // now that the maps have been created and contexts are assigned, we consider the item controller "fully loaded"
    for (id item in updatedItems) {
        [[map itemControllerForItem:item] didUpdateToItem:item];
    }

    NSUInteger itemCount = 0;
    for (IGListItemController<IGListItemType> *itemController in itemControllers) {
        itemCount += [itemController numberOfItems];
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

// use the string representation of a reusable view class when registering with a UICollectionView
- (NSString *)reusableViewIdentifierForClass:(Class)viewClass {
    return NSStringFromClass(viewClass);
}

- (IGListItemMap *)itemMapAdjustForUpdateBlock:(BOOL)adjustForUpdateBlock {
    // if we are inside an update block, we may have to use the /previous/ item map for some operations
    if (adjustForUpdateBlock && self.isInUpdateBlock && self.previousItemMap != nil) {
        return self.previousItemMap;
    } else {
        return self.itemMap;
    }
}

- (NSArray<NSIndexPath *> *)indexPathsFromItemController:(IGListItemController <IGListItemType> *)itemController
                                                 indexes:(NSIndexSet *)indexes
                                    adjustForUpdateBlock:(BOOL)adjustForUpdateBlock {
    NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];

    IGListItemMap *map = [self itemMapAdjustForUpdateBlock:adjustForUpdateBlock];

    const NSUInteger section = [map sectionForItemController:itemController];
    if (section != NSNotFound) {
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
        }];
    }
    return [indexPaths copy];
}

- (NSIndexPath *)indexPathForItemController:(IGListItemController *)controller index:(NSInteger)index {
    const NSUInteger section = [self.itemMap sectionForItemController:controller];
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

- (void)mapCell:(UICollectionViewCell *)cell toItemController:(IGListItemController<IGListItemType> *)itemController {
    IGAssertMainThread();
    IGParameterAssert(cell != nil);
    IGParameterAssert(itemController != nil);
    [_cellItemControllerMap setObject:itemController forKey:cell];
}

- (nullable IGListItemController<IGListItemType> *)itemControllerForCell:(UICollectionViewCell *)cell {
    IGAssertMainThread();
    return [_cellItemControllerMap objectForKey:cell];
}

- (void)removeMapForCell:(UICollectionViewCell *)cell {
    IGAssertMainThread();
    [_cellItemControllerMap removeObjectForKey:cell];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.itemMap.items.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    IGListItemController <IGListItemType> * itemController = [self.itemMap itemControllerForSection:section];
    IGAssert(itemController != nil, @"Nil item controller for section %zi for item %@. Check your -diffIdentifier and -isEqual: implementations.",
             section, [self.itemMap itemForSection:section]);
    const NSInteger numberOfItems = [itemController numberOfItems];
    IGAssert(numberOfItems >= 0, @"Cannot return negative number of items %zi for item controller %@.", numberOfItems, itemController);
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGListItemController<IGListItemType> *itemController = [self.itemMap itemControllerForSection:indexPath.section];
    UICollectionViewCell *cell = [itemController cellForItemAtIndex:indexPath.item];
    IGAssert(cell != nil, @"Returned a nil cell at indexPath <%@> from item controller: <%@>", indexPath, itemController);

    // associate the item controller with the cell so that we know which item controller is using it
    [self mapCell:cell toItemController:itemController];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    IGListItemController<IGListItemType> *itemController = [self.itemMap itemControllerForSection:indexPath.section];
    id <IGListSupplementaryViewSource> supplementarySource = [itemController supplementaryViewSource];
    UICollectionReusableView *view = [supplementarySource viewForSupplementaryElementOfKind:kind atIndex:indexPath.item];
    IGAssert(view != nil, @"Returned a nil supplementary view at indexPath <%@> from item controller: <%@>, supplementary source: <%@>", indexPath, itemController, supplementarySource);
    return view;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }

    IGListItemController <IGListItemType> * itemController = [self.itemMap itemControllerForSection:indexPath.section];
    [itemController didSelectItemAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:didDeselectItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }

    IGListItemController <IGListItemType> * itemController = [self.itemMap itemControllerForSection:indexPath.section];
    [itemController didDeselectItemAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }

    IGListItemController <IGListItemType> *itemController = [self itemControllerForCell:cell];
    // if the item controller relationship was destroyed, reconnect it
    // this happens with iOS 10 UICollectionView display range changes
    if (itemController == nil) {
        itemController = [self.itemMap itemControllerForSection:indexPath.section];
        [self mapCell:cell toItemController:itemController];
    }

    id object = [self.itemMap itemForSection:indexPath.section];
    [self.displayHandler willDisplayCell:cell forListAdapter:self itemController:itemController object:object indexPath:indexPath];
    [self.workingRangeHandler willDisplayItemAtIndexPath:indexPath forListAdapter:self];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UICollectionViewDelegate> collectionViewDelegate = self.collectionViewDelegate;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [collectionViewDelegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }

    IGListItemController <IGListItemType> *itemController = [self itemControllerForCell:cell];
    [self.displayHandler didEndDisplayingCell:cell forListAdapter:self itemController:itemController indexPath:indexPath];
    [self.workingRangeHandler didEndDisplayingItemAtIndexPath:indexPath forListAdapter:self];

    // break the association between the cell and the item controller
    [self removeMapForCell:cell];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // forward this method to the delegate b/c this implementation will steal the message from the proxy
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollViewDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [scrollViewDelegate scrollViewDidScroll:scrollView];
    }
    NSArray<IGListItemController<IGListItemType> *> *visibleItemControllers = [self visibleItemControllers];
    for (IGListItemController<IGListItemType> *itemController in visibleItemControllers) {
        [[itemController displayDelegate] listAdapter:self didScrollItemController:itemController];
    }
}


#pragma mark - IGListCollectionContext

- (CGSize)containerSize {
    return UIEdgeInsetsInsetRect(self.collectionView.bounds, self.collectionView.contentInset).size;
}

- (NSUInteger)indexForCell:(UICollectionViewCell *)cell itemController:(nonnull IGListItemController<IGListItemType> *)itemController {
    IGAssertMainThread();
    IGParameterAssert(cell != nil);
    IGParameterAssert(itemController != nil);
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    IGAssert(indexPath.section == [self sectionForItemController:itemController],
             @"Requesting a cell from another item controller is not allowed.");
    return indexPath != nil ? indexPath.item : NSNotFound;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
                                   itemController:(IGListItemController <IGListItemType> *)itemController {
    IGAssertMainThread();
    IGParameterAssert(itemController != nil);
    NSIndexPath *indexPath = [self indexPathForItemController:itemController index:index];
    // prevent querying the collection view if it isn't fully reloaded yet for the current data set
    if (indexPath != nil
        && indexPath.section < [self.collectionView numberOfSections]) {
        // only return a cell if it belongs to the item controller
        // this association is created in -collectionView:cellForItemAtIndexPath:
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if ([self itemControllerForCell:cell] == itemController) {
            return cell;
        }
    }
    return nil;
}

- (NSArray<UICollectionViewCell *> *)visibleCellsForItemController:(IGListItemController<IGListItemType> *)itemController {
    NSMutableArray *cells = [NSMutableArray new];
    UICollectionView *collectionView = self.collectionView;
    NSArray *visibleCells = [collectionView visibleCells];
    const NSUInteger section = [self sectionForItemController:itemController];
    for (UICollectionViewCell *cell in visibleCells) {
        if ([collectionView indexPathForCell:cell].section == section) {
            [cells addObject:cell];
        }
    }
    return [cells copy];
}

- (void)deselectItemAtIndex:(NSInteger)index
         itemController:(IGListItemController<IGListItemType> *)itemController
                   animated:(BOOL)animated {
    IGAssertMainThread();
    IGParameterAssert(itemController != nil);
    NSIndexPath *indexPath = [self indexPathForItemController:itemController index:index];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
}

- (__kindof UICollectionViewCell *)dequeReusableCellOfClass:(Class)cellClass
                                          forItemController:(IGListItemController <IGListItemType> *)itemController
                                                    atIndex:(NSInteger)index {
    IGAssertMainThread();
    IGParameterAssert(itemController != nil);
    IGParameterAssert(cellClass != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Reloading adapter without a collection view.");
    NSString *identifier = [self reusableViewIdentifierForClass:cellClass];
    NSIndexPath *indexPath = [self indexPathForItemController:itemController index:index];
    if (![self.registeredCellClasses containsObject:cellClass]) {
        [collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (__kindof UICollectionReusableView *)dequeReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                          forItemController:(IGListItemController <IGListItemType> *)itemController
                                                                      class:(Class)viewClass
                                                                    atIndex:(NSInteger)index {
    IGAssertMainThread();
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Reloading adapter without a collection view.");
    NSString *identifier = [self reusableViewIdentifierForClass:viewClass];
    NSIndexPath *indexPath = [self indexPathForItemController:itemController index:index];
    if (![self.registeredSupplementaryViewClasses containsObject:viewClass]) {
        [collectionView registerClass:viewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
    }
    return [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier forIndexPath:indexPath];
}

- (void)reloadItemsInItemController:(IGListItemController<IGListItemType> *)itemController atIndexes:(NSIndexSet *)indexes {
    IGAssertMainThread();
    IGParameterAssert(indexes != nil);
    IGParameterAssert(itemController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Reloading from %@ without a collection view.", itemController);

    if (indexes.count == 0) {
        return;
    }

    NSArray *indexPaths = [self indexPathsFromItemController:itemController indexes:indexes adjustForUpdateBlock:YES];
    [self.updatingDelegate reloadItemsInCollectionView:collectionView indexPaths:indexPaths];
}

- (void)insertItemsInItemController:(IGListItemController<IGListItemType> *)itemController atIndexes:(NSIndexSet *)indexes {
    IGAssertMainThread();
    IGParameterAssert(indexes != nil);
    IGParameterAssert(itemController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Inserting items from %@ without a collection view.", itemController);

    if (indexes.count == 0) {
        return;
    }

    NSArray *indexPaths = [self indexPathsFromItemController:itemController indexes:indexes adjustForUpdateBlock:NO];
    [self.updatingDelegate insertItemsIntoCollectionView:collectionView indexPaths:indexPaths];
}

- (void)deleteItemsInItemController:(IGListItemController<IGListItemType> *)itemController atIndexes:(NSIndexSet *)indexes {
    IGAssertMainThread();
    IGParameterAssert(indexes != nil);
    IGParameterAssert(itemController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Deleting items from %@ without a collection view.", itemController);

    if (indexes.count == 0) {
        return;
    }

    NSArray *indexPaths = [self indexPathsFromItemController:itemController indexes:indexes adjustForUpdateBlock:YES];
    [self.updatingDelegate deleteItemsFromCollectionView:collectionView indexPaths:indexPaths];
}

- (void)reloadItemController:(IGListItemController <IGListItemType> *)itemController {
    IGAssertMainThread();
    IGParameterAssert(itemController != nil);
    UICollectionView *collectionView = self.collectionView;
    IGAssert(collectionView != nil, @"Reloading items from %@ without a collection view.", itemController);

    IGListItemMap *map = [self itemMapAdjustForUpdateBlock:YES];
    const NSInteger section = [map sectionForItemController:itemController];
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


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [self sizeForItemAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self.itemMap itemControllerForSection:section] inset];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self.itemMap itemControllerForSection:section] minimumLineSpacing];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    IGAssert(![self.collectionViewDelegate respondsToSelector:_cmd], @"IGListAdapter is consuming method also implemented by the collectionViewDelegate: %@", NSStringFromSelector(_cmd));
    return [[self.itemMap itemControllerForSection:section] minimumInteritemSpacing];
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
