/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListKit.h>

#define genTestObject(k, v) [[IGTestObject alloc] initWithKey:k value:v]

@interface IGTestObject : NSObject <IGListDiffable, NSCopying>

- (instancetype)initWithKey:(id <NSCopying>)key value:(id)value;

@property (nonatomic, strong, readonly) id key;
@property (nonatomic, strong) id value;

@end
