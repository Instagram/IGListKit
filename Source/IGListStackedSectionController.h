/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <IGListKit/IGListSectionController.h>

#import <IGListKit/IGListMacros.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An instance of `IGListStackedSectionController` is a clustered section controller, composed of many child section
 controllers. It constructs and routes item-level indexes to the appropriate child section controller with a local
 index. This lets you build section controllers made up of individual units that can be shared and reused with other
 section controllers.

 For example, you can create a "Comments" section controller that displays lists of text that is used alongside photo,
 video, or slideshow section controllers. You then have four small and manageable section controllers instead of one
 huge class.
 */
IGLK_SUBCLASSING_RESTRICTED
NS_SWIFT_NAME(ListStackedSectionController)
@interface IGListStackedSectionController : IGListSectionController

/**
 Creates a new stacked section controller.

 @param sectionControllers An array of section controllers that make up the stack.

 @note The order of the section controllers dictates the order in which they appear. 
 
 @warning The first section controller that is the supplementary source decides which supplementary views get displayed.
 */
- (instancetype)initWithSectionControllers:(NSArray <IGListSectionController *> *)sectionControllers NS_DESIGNATED_INITIALIZER;

/**
 :nodoc:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 :nodoc:
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
