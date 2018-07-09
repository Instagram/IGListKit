/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListDiffable.h>

@interface IGTestDiffingObject : NSObject<IGListDiffable>

- (instancetype)initWithKey:(id)key objects:(NSArray *)objects;

@property (nonatomic, strong, readonly) id key;
@property (nonatomic, strong, readonly) NSArray *objects;

@end
