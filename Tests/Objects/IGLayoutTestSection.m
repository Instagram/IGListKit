/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGLayoutTestSection.h"

@implementation IGLayoutTestSection

- (instancetype)initWithItems:(NSArray<IGLayoutTestItem *> *)items {
    return [self initWithInsets:UIEdgeInsetsZero
                    lineSpacing:0
               interitemSpacing:0
                   headerHeight:0
                   footerHeight:0
                          items:items];
}

- (instancetype)initWithInsets:(UIEdgeInsets)insets
                   lineSpacing:(CGFloat)lineSpacing
              interitemSpacing:(CGFloat)interitemSpacing
                  headerHeight:(CGFloat)headerHeight
                  footerHeight:(CGFloat)footerHeight
                         items:(NSArray<IGLayoutTestItem *> *)items {
    if (self = [super init]) {
        _insets = insets;
        _lineSpacing = lineSpacing;
        _interitemSpacing = interitemSpacing;
        _headerHeight = headerHeight;
        _footerHeight = footerHeight;
        _items = [items copy];
    }
    return self;
}

@end
