/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListKit.h>

@class IGTestObject;

@interface IGTestDelegateController : IGListSectionController <IGListDisplayDelegate, IGListWorkingRangeDelegate, IGListTransitionDelegate>

@property (nonatomic, strong) IGTestObject *item;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, copy) void (^itemUpdateBlock)(void);
@property (nonatomic, copy) void (^cellConfigureBlock)(IGTestDelegateController *);
@property (nonatomic, assign, readonly) NSInteger updateCount;

@property (nonatomic, assign) NSInteger willDisplayCount;
@property (nonatomic, assign) NSInteger didEndDisplayCount;
@property (nonatomic, strong) NSCountedSet *willDisplayCellIndexes;
@property (nonatomic, strong) NSCountedSet *didEndDisplayCellIndexes;

@property (nonatomic, assign) CGPoint initialAttributesOffset;
@property (nonatomic, assign) CGPoint finalAttributesOffset;

@end
