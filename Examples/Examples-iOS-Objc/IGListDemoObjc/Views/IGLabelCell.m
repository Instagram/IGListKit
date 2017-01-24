//
//  IGLabelCell.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGLabelCell.h"

@interface IGLabelCell ()
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) CALayer *separator;
@end

@implementation IGLabelCell

- (instancetype)init
{
    self = [super init];
    if (self) {
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
    
    CGRect bounds = self.contentView.bounds;
    self.label.frame = UIEdgeInsetsInsetRect(bounds, self.insets);
    
    CGFloat height = 0.5;
    CGFloat left = self.insets.left;
    self.separator.frame = CGRectMake(left, bounds.size.height - height, bounds.size.width - left, height);
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.contentView.backgroundColor = [UIColor colorWithWhite:highlighted ? 0.9 : 1 alpha:1];
}

#pragma mark - Public

+ (CGFloat)textHeightWithText:(NSString *)text width:(CGFloat)width {
    return 0;
}

#pragma mark - setupSubviews

- (void)setupSubviews {
    [self.contentView addSubview:self.label];
    [self.contentView.layer addSublayer:self.separator];
}

#pragma mark - Custom Accessors

- (UIEdgeInsets)insets {
    return UIEdgeInsetsMake(8, 15, 8, 15);
}

- (UIFont *)font {
    if (!_font) {
        _font = [UIFont systemFontOfSize:17];
    }
    return _font;
}

- (CGFloat)singleLineHeight {
    return self.font.lineHeight + self.insets.top + self.insets.bottom;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 1;
        _label.font = self.font;
    }
    return _label;
}

- (CALayer *)separator {
    if (!_separator) {
        _separator = [[CALayer alloc] init];
        _separator.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1].CGColor;
    }
    return _separator;
}

@end
