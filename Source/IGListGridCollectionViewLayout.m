/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <IGListKit/IGListAssert.h>
#import "IGListGridCollectionViewLayout.h"

#pragma mark - IGListGridLayoutLine

@interface _IGListGridLayoutLine : NSObject

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGFloat tailSpace;
@property (nonatomic, assign, readonly) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) NSInteger headIndex;
@property (nonatomic, copy) NSMutableArray<NSValue *> *itemSizes;

- (instancetype)initWithMinimumInteritemSpacing:(CGFloat)spacing
                                      headIndex:(NSInteger)headIndex
                                          frame:(CGRect)frame;
- (BOOL)addItemToTailWithSize:(CGSize)size;
- (UICollectionViewLayoutAttributes *)attributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray<UICollectionViewLayoutAttributes *> *)attributesForAllItems;

@end


#pragma mark - IGListGridCollectionViewLayout

@interface IGListGridCollectionViewLayout ()

@property (nonatomic, copy, nullable, readonly) NSMutableArray<_IGListGridLayoutLine *> *lineCache;
@property (nonatomic, copy, nullable, readonly) NSMutableArray<NSNumber *> *lineForItem;

@property (nonatomic, assign, readonly) CGFloat contentWidth;
@property (nonatomic, assign, readonly) CGFloat contentHeight;

@property (nonatomic, assign) NSInteger itemPerLine;
@property (nonatomic, assign) NSInteger lineNumber;

@end

@implementation IGListGridCollectionViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _minimumLineSpacing = 0.0f;
    _minimumInteritemSpacing = 0.0f;
    _lineCache = [NSMutableArray new];
    _lineForItem = [NSMutableArray new];
    _itemSize = CGSizeZero;
}

#pragma mark - Layout Infomation

- (void)prepareLayout {
#if DEBUG
    IGAssertMainThread();
    for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        IGAssert([self.collectionView numberOfItemsInSection:section] == 1, @"Each section should have exactly one item for this layout to work.");
    }
#endif
    if (CGSizeEqualToSize(self.itemSize, CGSizeZero)) {
        [self reloadLayout];
    } else {
        [self reloadLayoutWithConstantItemSize:self.itemSize];
    }
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.contentWidth, self.contentHeight);
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *array = [NSMutableArray array];
    if (CGSizeEqualToSize(self.itemSize, CGSizeZero)) {
        BOOL findFirstLine = NO;
        for (_IGListGridLayoutLine *line in self.lineCache) {
            if (CGRectIntersectsRect(line.frame, rect)) {
                findFirstLine = YES;
                NSArray<UICollectionViewLayoutAttributes *> *lineAttributes = [line attributesForAllItems];
                for (UICollectionViewLayoutAttributes *attributes in lineAttributes) {
                    if (CGRectIntersectsRect(attributes.frame, rect)) {
                        [array addObject:attributes];
                    }
                }
            } else if (findFirstLine) {
                break;
            }
        }
    } else {
        NSInteger firstLine = (NSInteger)(rect.origin.y / (self.itemSize.height + self.minimumLineSpacing));
        NSInteger lastLine = (NSInteger)((rect.origin.y + rect.size.height + self.itemSize.height + self.minimumLineSpacing)
                                         / (self.itemSize.height + self.minimumLineSpacing));
        NSInteger firstColumn = (NSInteger)(rect.origin.x / (self.itemSize.width + self.minimumInteritemSpacing));
        NSInteger LastColumn = (NSInteger)((rect.origin.x + rect.size.width + self.itemSize.width + self.minimumInteritemSpacing)
                                           / (self.itemSize.width + self.minimumInteritemSpacing));
        firstLine = firstLine >= 0 ? firstLine : 0;
        lastLine = lastLine >= 0 ? lastLine : 0;
        firstColumn = firstColumn >= 0 ? firstColumn : 0;
        LastColumn = LastColumn >= 0 ? LastColumn : 0;
        for (NSInteger l = firstLine; l <= lastLine; l++) {
            NSInteger section = 0;
            for (NSInteger c = firstColumn; c <= LastColumn; c++) {
                section = l * self.itemPerLine + c;
                if (section >= self.collectionView.numberOfSections) {
                    break;
                }
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
                UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                if (attributes != nil) {
                    [array addObject:attributes];
                }
            }
            if (section >= self.collectionView.numberOfSections) {
                break;
            }
        }
    }
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (CGSizeEqualToSize(self.itemSize, CGSizeZero)) {
        const NSInteger lineNumber = [self.lineForItem[indexPath.section] integerValue];
        _IGListGridLayoutLine *line = self.lineCache[lineNumber];
        return [line attributesForItemAtIndexPath:indexPath];
    } else {
        const NSInteger section = indexPath.section;
        const NSInteger lineNumber = section / self.itemPerLine;
        const NSInteger column = section - lineNumber * self.itemPerLine;
        const CGFloat x = column * (self.itemSize.width + self.minimumInteritemSpacing);
        const CGFloat y = lineNumber * (self.itemSize.height + self.minimumLineSpacing);
        const CGRect frame = CGRectMake(x, y, self.itemSize.width, self.itemSize.height);
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = frame;
        return attributes;
    }
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    const CGRect oldBounds = self.collectionView.bounds;
    return CGRectGetWidth(oldBounds) != CGRectGetWidth(newBounds)
    || CGRectGetHeight(oldBounds) != CGRectGetHeight(newBounds);
}

#pragma mark - Getter Setter

- (CGFloat)contentWidth {
    UIEdgeInsets insets = self.collectionView.contentInset;
    return CGRectGetWidth(self.collectionView.bounds) - (insets.left + insets.right);
}

- (CGFloat)contentHeight {
    CGFloat height = 0;

    if (CGSizeEqualToSize(self.itemSize, CGSizeZero)) {
        for (_IGListGridLayoutLine *line in self.lineCache) {
            height += line.frame.size.height;
        }
        height += ([self.lineCache count] - 1) * self.minimumLineSpacing;
    } else {
        height = self.lineNumber * (self.itemSize.height + self.minimumLineSpacing) - self.minimumLineSpacing;
    }

    return height;
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing {
    if (_minimumLineSpacing != minimumLineSpacing) {
        _minimumLineSpacing = minimumLineSpacing;
        [self invalidateLayout];
    }
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    if (_minimumInteritemSpacing != minimumInteritemSpacing) {
        _minimumInteritemSpacing = minimumInteritemSpacing;
        [self invalidateLayout];
    }
}

#pragma mark - Private API

- (void)reloadLayout {
    [self.lineCache removeAllObjects];
    [self.lineForItem removeAllObjects];

    // Init first line and add to lineCache
    CGRect frame = CGRectMake(0, 0, self.contentWidth, 0);
    _IGListGridLayoutLine *firstLine = [[_IGListGridLayoutLine alloc] initWithMinimumInteritemSpacing:self.minimumInteritemSpacing
                                                                                            headIndex:0
                                                                                                frame:frame];
    [self.lineCache addObject:firstLine];

    UICollectionView *collectionView = self.collectionView;

    for (NSInteger i = 0; i < collectionView.numberOfSections; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
        id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>) collectionView.delegate;
        const CGSize itemSize = [delegate collectionView:collectionView layout:self sizeForItemAtIndexPath:indexPath];
        
        IGAssertMainThread();
        IGAssert(itemSize.width <= self.contentWidth, @"The width of a single item must not exceed the width of the collection view.");
        
        _IGListGridLayoutLine *lastLine = [self.lineCache lastObject];
        if (![lastLine addItemToTailWithSize:itemSize]) {
            // Not enough space for the last line
            CGFloat y = lastLine.frame.origin.y + lastLine.frame.size.height + self.minimumLineSpacing;
            frame = CGRectMake(0, y, self.contentWidth, 0);
            _IGListGridLayoutLine *newLine = [[_IGListGridLayoutLine alloc] initWithMinimumInteritemSpacing:self.minimumInteritemSpacing
                                                                                                  headIndex:i
                                                                                                      frame:frame];
            [self.lineCache addObject:newLine];
            [newLine addItemToTailWithSize:itemSize];
        }
        [self.lineForItem addObject:@(self.lineCache.count - 1)];
    }
}

- (void)reloadLayoutWithConstantItemSize:(CGSize)itemSize {
    self.itemPerLine = (NSInteger) ((self.contentWidth + self.minimumInteritemSpacing)
                                    / (itemSize.width + self.minimumInteritemSpacing));
    self.lineNumber = (self.collectionView.numberOfSections + self.itemPerLine - 1) / self.itemPerLine;
}

@end


#pragma mark - IGListGridLayoutLine

@implementation _IGListGridLayoutLine

- (instancetype)initWithMinimumInteritemSpacing:(CGFloat)spacing
                                      headIndex:(NSInteger)headIndex
                                          frame:(CGRect)frame {
    IGAssertMainThread();
    IGParameterAssert(spacing >= 0);
    IGParameterAssert(headIndex >= 0);

    self = [super init];
    if (self) {
        _frame = frame;
        _minimumInteritemSpacing = spacing;
        _itemSizes = [NSMutableArray array];
        _headIndex = headIndex;
        _tailSpace = frame.size.width;
    }
    return self;
}

- (BOOL)addItemToTailWithSize:(CGSize)size {
    if (size.width > self.tailSpace) {
        return NO;
    }

    self.tailSpace -= size.width + self.minimumInteritemSpacing;
    if (size.height > self.frame.size.height) {
        CGRect frame = self.frame;
        frame.size.height = size.height;
        self.frame = frame;
    }
    NSValue *sizeValue = [NSValue valueWithCGSize:size];
    [self.itemSizes addObject:sizeValue];
    return YES;
}

- (UICollectionViewLayoutAttributes *)attributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger index = indexPath.section - self.headIndex;
    CGFloat x = 0;
    NSInteger idx = 0;
    for (NSValue *sizeValue in self.itemSizes) {
        if (idx < index) {
            const CGSize size = [sizeValue CGSizeValue];
            x += size.width + self.minimumInteritemSpacing;
        } else {
            break;
        }
        idx++;
    }
    UICollectionViewLayoutAttributes *attributes = [self attributesForItemAtIndexPath:indexPath withXOffset:x];
    return attributes;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)attributesForAllItems {
    NSMutableArray *array = [NSMutableArray array];
    CGFloat x = 0;
    NSInteger idx = 0;
    for (NSValue *sizeValue in self.itemSizes) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:(self.headIndex + idx)];
        UICollectionViewLayoutAttributes *attributes = [self attributesForItemAtIndexPath:indexPath withXOffset:x];
        [array addObject:attributes];
        const CGSize size = [sizeValue CGSizeValue];
        x += size.width + self.minimumInteritemSpacing;
        idx++;
    }
    return [array copy];
}

#pragma mark - Private API

- (UICollectionViewLayoutAttributes *)attributesForItemAtIndexPath:(NSIndexPath *)indexPath withXOffset:(CGFloat)xOffset {
    const NSInteger index = indexPath.section - self.headIndex;
    const CGSize itemSize = [self.itemSizes[index] CGSizeValue];

    // Center vertically
    const CGFloat y = (self.frame.size.height - itemSize.height) / 2;

    const CGRect frame = CGRectMake(self.frame.origin.x + xOffset, self.frame.origin.y + y, itemSize.width, itemSize.height);
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = frame;
    return attributes;
}

@end
