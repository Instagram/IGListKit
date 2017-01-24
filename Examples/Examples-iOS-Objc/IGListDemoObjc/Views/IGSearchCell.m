//
//  IGSearchCell.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGSearchCell.h"

@implementation IGSearchCell

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
    self.searchBar.frame = self.contentView.bounds;
}

- (void)setupSubviews {
    [self.contentView addSubview:self.searchBar];
}

#pragma mark - Custom Accessors

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
    }
    return _searchBar;
}

@end
