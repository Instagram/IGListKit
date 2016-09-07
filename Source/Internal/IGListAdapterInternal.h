/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <IGListKit/IGListAdapter.h>

#import "IGListAdapterProxy.h"
#import "IGListCollectionContext.h"
#import "IGListDisplayHandler.h"
#import "IGListItemMap.h"
#import "IGListWorkingRangeHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface IGListAdapter ()
<
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
IGListCollectionContext
>
{
    __weak UICollectionView *_collectionView;
}

@property (nonatomic, strong, readonly) id <IGListUpdatingDelegate> updatingDelegate;
@property (nonatomic, strong, readonly) IGListItemMap *itemMap;
@property (nonatomic, strong, readonly) IGListDisplayHandler *displayHandler;
@property (nonatomic, strong, readonly) IGListWorkingRangeHandler *workingRangeHandler;

@property (nonatomic, strong, nullable) IGListAdapterProxy *delegateProxy;

@property (nonatomic, strong, nullable) UIView *emptyBackgroundView;

/**
 When making item updates inside a batch update block, delete operations must use the section /before/ any moves take
 place. This includes when other items are deleted or inserted ahead of the item controller making the mutations. In
 order to account for this we must track when the adapter is in the middle of an update block as well as the item
 controller mapping prior to the transition.

 Note that the previous item controller map is destroyed as soon as a transition is finished so there is no dangling
 items or item controllers.
 */
@property (nonatomic, assign) BOOL isInUpdateBlock;
@property (nonatomic, strong, nullable) IGListItemMap *previousItemMap;

@property (nonatomic, strong) NSMutableSet<Class> *registeredCellClasses;
@property (nonatomic, strong) NSMutableSet<Class> *registeredSupplementaryViewClasses;

- (NSArray *)indexPathsFromItemController:(IGListItemController <IGListItemType> *)itemController
                                  indexes:(NSIndexSet *)indexes
                     adjustForUpdateBlock:(BOOL)adjustForUpdateBlock;

- (NSString *)reusableViewIdentifierForClass:(Class)viewClass;

@end

NS_ASSUME_NONNULL_END
