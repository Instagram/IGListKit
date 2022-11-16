/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "PhotoCell.h"

@interface PhotoCell ()
@property (nonatomic, strong) UIView *view;
@end

@implementation PhotoCell

- (instancetype)init {
    if (self = [super init]) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor colorWithRed:4/255.0 green:170/255.0 blue:166/255.0 alpha:1.0];
    [self.contentView addSubview:self.view];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.view.frame = self.contentView.frame;
}

@end
