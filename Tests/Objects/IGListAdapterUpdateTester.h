// 
// Copyright (c) 2016-present, Facebook, Inc.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//
// GitHub:
// https://github.com/Instagram/IGListKit
// 
// Documentation:
// https://instagram.github.io/IGListKit/
//

#import <Foundation/Foundation.h>

#import <IGListKit/IGListAdapterUpdateListener.h>

@interface IGListAdapterUpdateTester : NSObject <IGListAdapterUpdateListener>

@property (nonatomic, assign) NSInteger hits;
@property (nonatomic, assign) IGListAdapterUpdateType type;
@property (nonatomic, assign) BOOL animated;

@end
