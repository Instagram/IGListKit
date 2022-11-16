/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListDiffKit/IGListDiffable.h>

@interface IGTestDiffingObject : NSObject<IGListDiffable>

- (instancetype)initWithKey:(id)key objects:(NSArray *)objects;

@property (nonatomic, strong, readonly) id key;
@property (nonatomic, strong, readonly) NSArray *objects;

@end
