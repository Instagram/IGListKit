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

#import "IGListAdapterProxy.h"
#import "IGListDisplayHandler.h"
#import "IGListSectionMap.h"
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
@property (nonatomic, strong, readonly) IGListSectionMap *sectionMap;
@property (nonatomic, strong, readonly) IGListDisplayHandler *displayHandler;
@property (nonatomic, strong, readonly) IGListWorkingRangeHandler *workingRangeHandler;

@property (nonatomic, strong, nullable) IGListAdapterProxy *delegateProxy;

@property (nonatomic, strong, nullable) UIView *emptyBackgroundView;

/**
 When making object updates inside a batch update block, delete operations must use the section /before/ any moves take
 place. This includes when other objects are deleted or inserted ahead of the section controller making the mutations.
 In order to account for this we must track when the adapter is in the middle of an update block as well as the section
 controller mapping prior to the transition.

 Note that the previous section controller map is destroyed as soon as a transition is finished so there is no dangling
 objects or section controllers.
 */
@property (nonatomic, assign) BOOL isInUpdateBlock;
@property (nonatomic, strong, nullable) IGListSectionMap *previoussectionMap;

@property (nonatomic, strong) NSMutableSet<Class> *registeredCellClasses;
@property (nonatomic, strong) NSMutableSet<Class> *registeredSupplementaryViewClasses;

- (NSArray *)indexPathsFromSectionController:(IGListSectionController <IGListSectionType> *)sectionController
                                  indexes:(NSIndexSet *)indexes
                     adjustForUpdateBlock:(BOOL)adjustForUpdateBlock;

- (NSString *)reusableViewIdentifierForClass:(Class)viewClass;

@end

NS_ASSUME_NONNULL_END
