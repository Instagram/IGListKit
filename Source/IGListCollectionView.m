/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListCollectionView.h"

@interface IGListCollectionView ()

@property (nonatomic, assign, readonly) BOOL requiresManualWillDisplay;
@property (nonatomic, strong) NSSet *ig_visibleIndexPaths;

@end

@implementation IGListCollectionView

- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    self.alwaysBounceVertical = YES;

    // iOS 6 and 7 do not support -collectionView:willDisplayCell:forItemAtIndexPath: so we do it ourselves
    _requiresManualWillDisplay = [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    /**
     UICollectionView will sometimes lay its cells out with an animation. This is especially noticeable on older devices
     while scrolling quickly. The simplest fix is to just disable animations for -layoutSubviews, which is where cells
     and other views inside the UICollectionView are laid out.
     */
    [UIView performWithoutAnimation:^{
        [super layoutSubviews];
    }];

    if (self.requiresManualWillDisplay && [self.delegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        NSArray *indexPaths = [self indexPathsForVisibleItems];
        for (NSIndexPath *path in indexPaths) {
            if (![self.ig_visibleIndexPaths containsObject:path]) {
                UICollectionViewCell *cell = [self cellForItemAtIndexPath:path];
                [self.delegate collectionView:self willDisplayCell:cell forItemAtIndexPath:path];
            }
        }
        self.ig_visibleIndexPaths = [NSSet setWithArray:indexPaths];
    }
}

@end
