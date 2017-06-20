/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListDiffable.h>

@interface IGTestDiffingObject : NSObject<IGListDiffable>

- (instancetype)initWithKey:(id)key objects:(NSArray *)objects;

@property (nonatomic, strong, readonly) id key;
@property (nonatomic, strong, readonly) NSArray *objects;

@end
