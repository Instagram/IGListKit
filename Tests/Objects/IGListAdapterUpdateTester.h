/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListAdapterUpdateListener.h>

@interface IGListAdapterUpdateTester : NSObject <IGListAdapterUpdateListener>

@property (nonatomic, assign) NSInteger hits;
@property (nonatomic, assign) IGListAdapterUpdateType type;
@property (nonatomic, assign) BOOL animated;

@end
