/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class IGListAdapter;



@interface IGListWorkingRangeHandler : NSObject

/**
 Initializes the working range handler.

 @param workingRangeSize the number of sections beyond the visible viewport that should be considered within the working
 range. Applies equally in both directions above and below the viewport.
 */
- (instancetype)initWithWorkingRangeSize:(NSInteger)workingRangeSize;

/**
 Tells the handler that a cell will be displayed in the IGListKit infra.

 @param indexPath The index path of the cell in the UICollectionView.
 @param listAdapter The adapter managing the infra.
 */
- (void)willDisplayItemAtIndexPath:(NSIndexPath *)indexPath
                    forListAdapter:(IGListAdapter *)listAdapter;

/**
 Tells the handler that a cell did end display in the IGListKit infra.

 @param indexPath The index path of the cell in the UICollectionView.
 @param listAdapter The adapter managing the infra.
 */
- (void)didEndDisplayingItemAtIndexPath:(NSIndexPath *)indexPath
                         forListAdapter:(IGListAdapter *)listAdapter;

@end
