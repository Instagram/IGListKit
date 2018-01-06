/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

@class IGListBindingSectionController;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(ListBindingSectionBindingRangeDelegate)
@protocol IGListBindingSectionBindingRangeDelegate <NSObject>

- (void)sectionController:(IGListBindingSectionController *)sectionController itemAtIndexWillEnterBindingRange:(NSInteger)index;
- (void)sectionController:(IGListBindingSectionController *)sectionController itemAtIndexDidExitBindingRange:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
