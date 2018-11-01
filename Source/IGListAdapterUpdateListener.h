/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@class IGListAdapter;

NS_ASSUME_NONNULL_BEGIN

/**
 The type of update that was performed by an `IGListAdapter`.
 */
NS_SWIFT_NAME(ListAdapterUpdateType)
typedef NS_ENUM(NSInteger, IGListAdapterUpdateType) {
    /**
     `-[IGListAdapter performUpdatesAnimated:completion:]` was executed.
     */
    IGListAdapterUpdateTypePerformUpdates,
    /**
     `-[IGListAdapter reloadDataWithCompletion:]` was executed.
     */
    IGListAdapterUpdateTypeReloadData,
    /**
     `-[IGListCollectionContext performBatchAnimated:updates:completion:]` was executed by an `IGListSectionController`.
     */
    IGListAdapterUpdateTypeItemUpdates,
};

/**
 Conform to this protocol to receive events about `IGListAdapter` updates.
 */
NS_SWIFT_NAME(ListAdapterUpdateListener)
@protocol IGListAdapterUpdateListener <NSObject>

/**
 Notifies a listener that the listAdapter was updated.

 @param listAdapter The `IGListAdapter` that updated.
 @param update The type of update executed.
 @param animated A flag indicating if the update was animated. Always `NO` for `IGListAdapterUpdateTypeReloadData`.

 @note This event is sent before the completion block in `-[IGListAdapter performUpdatesAnimated:completion:]` and
 `-[IGListAdapter reloadDataWithCompletion:]` is executed. This event is also delivered when an
 `IGListSectionController` updates via `-[IGListCollectionContext performBatchAnimated:updates:completion:]`.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter
    didFinishUpdate:(IGListAdapterUpdateType)update
           animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
