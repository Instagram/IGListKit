/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGTestStringBindableCell.h"

@implementation IGTestStringBindableCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _label = [UILabel new];
    }
    return self;
}

#pragma mark - IGListBindable

- (void)bindViewModel:(id)viewModel {
    self.label.text = viewModel;
}

@end
