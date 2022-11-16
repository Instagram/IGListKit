/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGTestCell.h"

#import "IGTestObject.h"

@implementation IGTestCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _label = [[UILabel alloc] init];
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)bindViewModel:(id)viewModel {
    IGTestObject *object = viewModel;
    self.label.text = [object.value description];
}

@end
