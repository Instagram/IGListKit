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

#import "PersonCell.h"

#import "PersonModel.h"

@interface PersonCell ()
@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, assign) CGFloat separatorHeight;
@end

@implementation PersonCell

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
    self.avatarView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    [self.contentView addSubview:self.avatarView];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = [UIColor darkTextColor];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.nameLabel];

    self.separatorView = [[UIView alloc] init];
    self.separatorView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self.contentView addSubview:self.separatorView];

    self.separatorHeight = (1 / [UIScreen mainScreen].scale);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    const CGFloat outerInset = 10;
    const CGRect bounds = self.contentView.bounds;
    const CGRect insetBounds = CGRectInset(bounds, outerInset, outerInset);
    const CGFloat avatarViewWidth = insetBounds.size.height;

    const CGRect avatarViewFrame = CGRectMake(outerInset, outerInset, avatarViewWidth, avatarViewWidth);
    if (!CGRectEqualToRect(avatarViewFrame, self.avatarView.frame)) {
        self.avatarView.layer.cornerRadius = round(avatarViewWidth / 2.0);
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.frame = avatarViewFrame;
    }

    const CGFloat avatarLabelInset = 8;
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(avatarViewFrame) + avatarLabelInset,
                                      outerInset,
                                      CGRectGetWidth(insetBounds) - avatarViewWidth - avatarLabelInset * 2,
                                      CGRectGetHeight(insetBounds));

    self.separatorView.frame = CGRectMake(0,
                                          CGRectGetHeight(bounds) - self.separatorHeight,
                                          CGRectGetWidth(bounds),
                                          self.separatorHeight);
}

static NSAttributedString *AttributedStringForPerson(PersonModel *person) {
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:person.firstName
                                                                   attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0]}]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@" "
                                                                   attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0]}]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:person.lastName
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]}]];
    return string;
}

- (void)setPerson:(PersonModel *)person {
    _person = [person copy];
    
    self.nameLabel.attributedText = AttributedStringForPerson(person);
}

@end
