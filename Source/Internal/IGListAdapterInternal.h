/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <IGListKit/IGListAdapter.h>
#import <IGListKit/IGListCollectionContext.h>
#import <IGListKit/IGListBatchContext.h>

#import "IGListAdapterProxy.h"
#import "IGListDisplayHandler.h"
#import "IGListSectionMap.h"
#import "IGListWorkingRangeHandler.h"
#import "IGListAdapter+UICollectionView.h"

NS_ASSUME_NONNULL_BEGIN

/// Generate a string representation of a reusable view class when registering with a UICollectionView.
NS_INLINE NSString *IGListReusableViewIdentifier(Class viewClass, NSString * _Nullable nibName, NSString * _Nullable kind) {
    return [NSString stringWithFormat:@"%@%@%@", kind ?: @"", nibName ?: @"", NSStringFromClass(viewClass)];
}

@interface IGListAdapter ()
<
IGListCollectionContext,
IGListBatchContext
>
{
    __weak UICollectionView *_collectionView;
    BOOL _isDequeuingCell;
    BOOL _isSendingWorkingRangeDisplayUpdates;
}

@property (nonatomic, strong) id <IGListUpdatingDelegate> updater;

@property (nonatomic, strong, readonly) IGListSectionMap *sectionMap;
@property (nonatomic, strong, readonly) IGListDisplayHandler *displayHandler;
@property (nonatomic, strong, readonly) IGListWorkingRangeHandler *workingRangeHandler;

@property (nonatomic, strong, nullable) IGListAdapterProxy *delegateProxy;

@property (nonatomic, strong, nullable) UIView *emptyBackgroundView;

// we need to special case interactive section moves that are moved to the last position
@property (nonatomic) BOOL isLastInteractiveMoveToLastSectionIndex;

/**
 When making object updates inside a batch update block, delete operations must use the section /before/ any moves take
 place. This includes when other objects are deleted or inserted ahead of the section controller making the mutations.
 In order to account for this we must track when the adapter is in the middle of an update block as well as the section
 controller mapping prior to the transition.

 Note that the previous section controller map is destroyed as soon as a transition is finished so there is no dangling
 objects or section controllers.
 */
@property (nonatomic, assign) BOOL isInUpdateBlock;
@property (nonatomic, strong, nullable) IGListSectionMap *previousSectionMap;

@property (nonatomic, strong) NSMutableSet<Class> *registeredCellClasses;
@property (nonatomic, strong) NSMutableSet<NSString *> *registeredNibNames;
@property (nonatomic, strong) NSMutableSet<NSString *> *registeredSupplementaryViewIdentifiers;
@property (nonatomic, strong) NSMutableSet<NSString *> *registeredSupplementaryViewNibNames;

- (void)mapView:(__kindof UIView *)view toSectionController:(IGListSectionController *)sectionController;
- (nullable IGListSectionController *)sectionControllerForView:(__kindof UIView *)view;
- (void)removeMapForView:(__kindof UIView *)view;

- (NSArray *)indexPathsFromSectionController:(IGListSectionController *)sectionController
                                     indexes:(NSIndexSet *)indexes
                  usePreviousIfInUpdateBlock:(BOOL)usePreviousIfInUpdateBlock;

- (nullable NSIndexPath *)indexPathForSectionController:(IGListSectionController *)controller
                                                  index:(NSInteger)index
                             usePreviousIfInUpdateBlock:(BOOL)usePreviousIfInUpdateBlock;

@end

NS_ASSUME_NONNULL_END
