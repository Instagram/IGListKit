/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListTestCollectionViewLayout.h"

@implementation IGListTestCollectionViewLayout {
    NSDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *_attributes;
}

- (void)prepareLayout {
    UICollectionView *const collectionView = self.collectionView;
    
    // Get the UICollectionViewDelegateFlowLayout for sizes
    if (![collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)]) {
        _attributes = nil;
        return;
    }
    const id<UICollectionViewDelegateFlowLayout> flowDelegate = (id<UICollectionViewDelegateFlowLayout>)collectionView.delegate;
    
    // Create the attributes
    NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *const attributes = [NSMutableDictionary new];
    const NSInteger numberOfSections = collectionView.numberOfSections;

    for (NSInteger section = 0; section < numberOfSections; section++) {
        const NSInteger numberOfItems = [collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < numberOfItems; item++) {
            NSIndexPath *const indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *const attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            const CGSize size = [flowDelegate collectionView:collectionView layout:self sizeForItemAtIndexPath:indexPath];
            attribute.frame = CGRectMake(0, 0, size.width, size.height);
            attributes[indexPath] = attribute;
        }
    }

    _attributes = [attributes copy];
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray<UICollectionViewLayoutAttributes *> *attributes = [NSMutableArray new];
    [_attributes enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL* stop) {
        if (CGRectIntersectsRect(attribute.frame, rect)) {
            [attributes addObject:attribute];
        }
    }];
    return [attributes copy];
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _attributes[indexPath];
}

@end
