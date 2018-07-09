/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
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
