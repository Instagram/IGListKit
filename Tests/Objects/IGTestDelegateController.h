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

@interface IGTestDelegateController : IGListSectionController <IGListSectionType, IGListDisplayDelegate>

@property (nonatomic, strong, readonly) IGTestObject *item;

@property (nonatomic, copy) void (^itemUpdateBlock)();
@property (nonatomic, copy) void (^cellConfigureBlock)(IGTestDelegateController *);
@property (nonatomic, assign, readonly) NSUInteger updateCount;

@property (nonatomic, assign) NSUInteger willDisplayCount;
@property (nonatomic, assign) NSUInteger didEndDisplayCount;
@property (nonatomic, strong) NSCountedSet *willDisplayCellIndexes;
@property (nonatomic, strong) NSCountedSet *didEndDisplayCellIndexes;

@end
