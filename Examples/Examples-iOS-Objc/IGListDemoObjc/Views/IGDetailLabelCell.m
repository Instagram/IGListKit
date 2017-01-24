//
//  IGDetailLabelCell.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGDetailLabelCell.h"

@interface IGDetailLabelCell ()

@end

@implementation IGDetailLabelCell

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
    CGFloat padding = 15.0;
    CGRect frame = CGRectInset(self.contentView.bounds, padding, 0);
    self.titleLabel.frame = frame;
    self.detailLabel.frame = frame;
}

- (void)setupSubviews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
}

#pragma mark - Custom Accessors

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = [UIColor darkTextColor];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.font = [UIFont systemFontOfSize:17];
        _detailLabel.textColor = [UIColor lightGrayColor];
    }
    return _detailLabel;
}

@end
