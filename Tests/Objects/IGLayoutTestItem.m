/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGLayoutTestItem.h"

@implementation IGLayoutTestItem

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super init]) {
        _size = size;
    }
    return self;
}

@end
