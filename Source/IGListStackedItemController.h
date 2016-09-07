/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <IGListKit/IGListItemController.h>
#import <IGListKit/IGListItemType.h>
#import <IGListKit/IGListMacros.h>

/**
 This is a clustered item controller, composed of many child item controllers. It constructs and routes item-level
 indexes to the appropriate child item controller with a local index. This lets you build item controllers made up of
 individual units that can be shared and reused with other item controllers.

 For example, you can create a "Comments" item controller that displays lists of text that is used alongside photo,
 video, or slideshow item controllers. You then have four small and manageable item controllers instead of one huge
 class.
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListStackedItemController : IGListItemController <IGListItemType>

/**
 Create a new stacked item controller.

 @param itemControllers An array of item controllers that make up the stack.

 @discussion The order of the item controllers dictates the order in which they appear. The first item controller that
 is the supplementary source decides which supplementary views get displayed.
 */
- (instancetype)initWithItemControllers:(NSArray <IGListItemController<IGListItemType> *> *)itemControllers NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
