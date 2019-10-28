/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListDiffKit/IGListMacros.h>

@class IGListAdapter;

IGLK_SUBCLASSING_RESTRICTED
@interface IGListDebugger : NSObject

+ (void)trackAdapter:(IGListAdapter *)adapter;

+ (NSArray<NSString *> *)adapterDescriptions;

+ (void)clear;

+ (NSString *)dump;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
