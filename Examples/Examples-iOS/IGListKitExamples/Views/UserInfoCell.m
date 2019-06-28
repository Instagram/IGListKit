/**
 Copyright (c) Facebook, Inc. and its affiliates.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "UserInfoCell.h"

@interface UserInfoCell ()
@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation UserInfoCell

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
    self.avatarView = [[UIView alloc] init];
    self.avatarView.backgroundColor = [UIColor colorWithRed:210/255.0 green:65/255.0 blue:64/255.0 alpha:1.0];
    [self.contentView addSubview:self.avatarView];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:15];
    self.nameLabel.textColor = [UIColor darkTextColor];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.nameLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    
    CGFloat avatarViewWidth = 25.0;
    CGFloat avatarTopSpace = (CGRectGetHeight(bounds) - avatarViewWidth) / 2.0;
    CGFloat avatarLeftSpace = 8.0;
    self.avatarView.frame = CGRectMake(avatarLeftSpace, avatarTopSpace, avatarViewWidth, avatarViewWidth);
    self.avatarView.layer.cornerRadius = MIN(CGRectGetHeight(self.avatarView.frame), CGRectGetWidth(self.avatarView.frame)) / 2.0;
    self.avatarView.layer.masksToBounds = YES;
    
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarView.frame) + 8.0, CGRectGetMinY(self.avatarView.frame), CGRectGetWidth(bounds) - CGRectGetMaxX(self.avatarView.frame) - 8.0 * 2, CGRectGetHeight(self.avatarView.frame));
}

- (void)setName:(NSString *)name {
    _name = [name copy];
    
    self.nameLabel.text = _name;
}

@end
