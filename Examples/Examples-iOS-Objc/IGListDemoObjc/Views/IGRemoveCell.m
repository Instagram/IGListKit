//
//  IGRemoveCell.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGRemoveCell.h"
#import <IGListKit.h>

@interface IGRemoveCell ()
@property (nonatomic, strong) UIButton *button;
@end

@implementation IGRemoveCell

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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    CGRect bounds = self.contentView.bounds;
    CGRect slice;
    CGRect remainder;
    CGRectDivide(bounds, &slice, &remainder, 100, CGRectMaxXEdge);
    self.label.frame = CGRectInset(slice, 15, 0);
    self.button.frame = remainder;
}

- (void)setupSubviews {
    [self.contentView addSubview:self.label];
    [self.contentView addSubview:self.button];
}

#pragma mark - Actions

- (void)onButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(removeCellDidTapButton:)]) {
        [self.delegate removeCellDidTapButton:self];
    }
}

#pragma mark - Custom Accessors

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
    }
    return _label;
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        [_button setTitle:@"Remove" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _button.backgroundColor = [UIColor clearColor];
        [_button addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _button;
}

@end
