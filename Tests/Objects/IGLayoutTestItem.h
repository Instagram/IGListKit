/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#define genLayoutTestItem(s) [[IGLayoutTestItem alloc] initWithSize:s]

@interface IGLayoutTestItem : NSObject

@property (nonatomic, assign, readonly) CGSize size;

- (instancetype)initWithSize:(CGSize)size;

@end
