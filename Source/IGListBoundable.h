/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <IGListKit/IGListSectionController.h>
NS_ASSUME_NONNULL_BEGIN
@class IGListSectionController;

NS_SWIFT_NAME(ListBoundable)
@protocol IGListBoundable <NSObject>

/**
 Tells the caller which sectionController to use section model.
 */
- (IGListSectionController *)boundedSectionController;


@end


NS_ASSUME_NONNULL_END
