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
