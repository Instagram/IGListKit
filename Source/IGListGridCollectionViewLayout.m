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
@property (nonatomic, strong) NSMutableArray<NSValue *> *itemSizes;
@property (nonatomic, assign) IGListGridCollectionViewLayoutAlignment alignment;

- (instancetype)initWithMinimumInteritemSpacing:(CGFloat)spacing
                                      headIndex:(NSInteger)headIndex
                                          frame:(CGRect)frame
                                      alignment:(IGListGridCollectionViewLayoutAlignment)alignment;
- (BOOL)addItemToTailWithSize:(CGSize)size;
- (CGRect)frameForItemAtIndex:(NSInteger)index;
- (NSArray<NSValue *> *)framesForAllItems;

@end


#pragma mark - IGListGridCollectionViewLayout

@interface IGListGridCollectionViewLayout ()

@property (nonatomic, strong, nullable, readonly) NSMutableArray<_IGListGridLayoutLine *> *lineCache;
@property (nonatomic, strong, nullable, readonly) NSMutableArray<NSNumber *> *lineForIndex;
@property (nonatomic, strong, nullable, readonly) NSMutableArray<NSIndexPath *> *indexToIndexPathMap;
@property (nonatomic, strong, nullable, readonly) NSMutableDictionary<NSIndexPath *, NSNumber *> *indexPathToIndexMap;

@property (nonatomic, assign, readonly) CGFloat contentWidth;
@property (nonatomic, assign, readonly) CGFloat contentHeight;

@property (nonatomic, assign) NSInteger itemPerLine;
@property (nonatomic, assign) NSInteger lineNumber;
@property (nonatomic, assign) CGFloat interitemSpacing;
@property (nonatomic, assign) CGFloat tailSpacing;

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
    _lineForIndex = [NSMutableArray new];
    _indexToIndexPathMap = [NSMutableArray new];
    _indexPathToIndexMap = [NSMutableDictionary new];
    _itemSize = CGSizeZero;
    _alignment = IGListGridCollectionViewLayoutAlignmentLeft;
}

#pragma mark - Layout Infomation

- (void)prepareLayout {
    // Clean cache
    [self.lineCache removeAllObjects];
    [self.lineForIndex removeAllObjects];
    [self.indexToIndexPathMap removeAllObjects];
    [self.indexPathToIndexMap removeAllObjects];
    
    // Load indexPath Map
    UICollectionView *collectionView = self.collectionView;
    for (NSInteger section = 0; section < collectionView.numberOfSections; section++) {
        for(NSInteger item = 0; item < [collectionView numberOfItemsInSection:section]; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            [self.indexToIndexPathMap addObject:indexPath];
            self.indexPathToIndexMap[indexPath] = [NSNumber numberWithInteger:self.indexPathToIndexMap.count];
        }
    }
    
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
                NSArray<NSValue *> *lineFrames = [line framesForAllItems];
                __block NSInteger headIndex = line.headIndex;
                [lineFrames enumerateObjectsUsingBlock:^(NSValue *frameValue, NSUInteger idx, BOOL *stop) {
                    const CGRect frame = [frameValue CGRectValue];
                    if (CGRectIntersectsRect(frame, rect)) {
                        const NSInteger index = headIndex + idx;
                        NSIndexPath *indexPath = self.indexToIndexPathMap[index];
                        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                        attributes.frame = frame;
                        [array addObject:attributes];
                    }
                }];
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
            NSInteger index = 0;
            for (NSInteger c = firstColumn; c <= LastColumn; c++) {
                index = l * self.itemPerLine + c;
                if (index >= self.indexToIndexPathMap.count) {
                    break;
                }
                NSIndexPath *indexPath = self.indexToIndexPathMap[index];
                UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                if (attributes != nil) {
                    [array addObject:attributes];
                }
            }
            if (index >= self.indexToIndexPathMap.count) {
                break;
            }
        }
    }
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (CGSizeEqualToSize(self.itemSize, CGSizeZero)) {
        const NSInteger index = [self.indexPathToIndexMap[indexPath] integerValue];
        const NSInteger lineNumber = [self.lineForIndex[index] integerValue];
        _IGListGridLayoutLine *line = self.lineCache[lineNumber];
        const CGRect frame = [line frameForItemAtIndex:index];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = frame;
        return attributes;
    } else {
        const NSInteger index = [self.indexPathToIndexMap[indexPath] integerValue];
        CGFloat offset = 0.0;
        CGFloat interitemSpacing = self.minimumInteritemSpacing;
        if (self.alignment == IGListGridCollectionViewLayoutAlignmentCenter) {
            interitemSpacing = self.interitemSpacing;
            if (self.itemPerLine == 1 || (index + 1 == self.indexToIndexPathMap.count && index % self.itemPerLine == 0)) {
                // Only 1 item in line, center item.
                offset = self.tailSpacing / 2.0;
            }
        } else if (self.alignment == IGListGridCollectionViewLayoutAlignmentRight) {
            offset = self.tailSpacing;
        }
        const NSInteger lineNumber = index / self.itemPerLine;
        const NSInteger column = index - lineNumber * self.itemPerLine;
        const CGFloat x = column * (self.itemSize.width + interitemSpacing) + offset;
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
    
- (void)setAlignment:(IGListGridCollectionViewLayoutAlignment)alignment {
    if (_alignment != alignment) {
        _alignment = alignment;
        [self invalidateLayout];
    }
}

#pragma mark - Private API

- (void)reloadLayout {
    // Init first line and add to lineCache
    CGRect frame = CGRectMake(0, 0, self.contentWidth, 0);
    _IGListGridLayoutLine *firstLine = [[_IGListGridLayoutLine alloc] initWithMinimumInteritemSpacing:self.minimumInteritemSpacing
                                                                                            headIndex:0
                                                                                                frame:frame
                                                                                            alignment:self.alignment];
    [self.lineCache addObject:firstLine];

    UICollectionView *collectionView = self.collectionView;
    for (NSInteger section = 0; section < collectionView.numberOfSections; section++) {
        for (NSInteger item = 0; item < [collectionView numberOfItemsInSection:section]; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSInteger index = [self.indexPathToIndexMap[indexPath] integerValue];
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
                                                                                                      headIndex:index
                                                                                                          frame:frame
                                                                                                      alignment:self.alignment];
                [self.lineCache addObject:newLine];
                [newLine addItemToTailWithSize:itemSize];
            }
            [self.lineForIndex addObject:@(self.lineCache.count - 1)];
        }
    }
}

- (void)reloadLayoutWithConstantItemSize:(CGSize)itemSize {
    self.itemPerLine = (NSInteger)((self.contentWidth + self.minimumInteritemSpacing)
                                / (itemSize.width + self.minimumInteritemSpacing));
    self.lineNumber = (self.indexToIndexPathMap.count + self.itemPerLine - 1) / self.itemPerLine;
    self.interitemSpacing = (self.contentWidth - (self.itemPerLine * itemSize.width)) / (CGFloat)(self.itemPerLine - 1);
    self.tailSpacing = self.contentWidth + self.minimumLineSpacing - (CGFloat)self.itemPerLine * (itemSize.width + self.minimumLineSpacing);
}

@end


#pragma mark - IGListGridLayoutLine

@implementation _IGListGridLayoutLine

- (instancetype)initWithMinimumInteritemSpacing:(CGFloat)spacing
                                      headIndex:(NSInteger)headIndex
                                          frame:(CGRect)frame
                                      alignment:(IGListGridCollectionViewLayoutAlignment)alignment{
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
        _alignment = alignment;
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

- (CGRect)frameForItemAtIndex:(NSInteger)index {
    CGFloat x = 0;
    CGFloat lineWidth = self.frame.size.width;
    CGFloat interitemSpacing = self.minimumInteritemSpacing;
    if (self.alignment == IGListGridCollectionViewLayoutAlignmentCenter) {
        // Only one item is in this line.
        if (self.itemSizes.count == 1) {
            const CGSize size = [self.itemSizes[0] CGSizeValue];
            x = (lineWidth - size.width) / 2.0;
            return [self frameForItemAtIndex:index withXOffset:x];
        } else {
            interitemSpacing += (self.tailSpace + self.minimumInteritemSpacing) / (self.itemSizes.count - 1.0);
        }
    } else if (self.alignment == IGListGridCollectionViewLayoutAlignmentRight) {
        x += self.tailSpace + self.minimumInteritemSpacing;
    }
    NSInteger idx = 0;
    for (NSValue *sizeValue in self.itemSizes) {
        if (idx < index - self.headIndex) {
            const CGSize size = [sizeValue CGSizeValue];
            x += size.width + interitemSpacing;
        } else {
            break;
        }
        idx++;
    }
    return [self frameForItemAtIndex:index withXOffset:x];
}

- (NSArray<NSValue *> *)framesForAllItems {
    NSMutableArray *array = [NSMutableArray array];
    CGFloat x = 0;
    CGFloat lineWidth = self.frame.size.width;
    CGFloat interitemSpacing = self.minimumInteritemSpacing;
    NSInteger idx = 0;
    if (self.alignment == IGListGridCollectionViewLayoutAlignmentCenter) {
        if (self.itemSizes.count == 1) {
            const CGSize size = [self.itemSizes[0] CGSizeValue];
            x = (lineWidth - size.width) / 2.0;
            NSInteger index = self.headIndex + idx;
            CGRect frame = [self frameForItemAtIndex:index withXOffset:x];
            [array addObject:[NSValue valueWithCGRect:frame]];
            return array;
        } else {
            interitemSpacing += (self.tailSpace + self.minimumInteritemSpacing) / (self.itemSizes.count - 1.0);
        }
    } else if (self.alignment == IGListGridCollectionViewLayoutAlignmentRight) {
        x += self.tailSpace + self.minimumInteritemSpacing;
    }
    for (NSValue *sizeValue in self.itemSizes) {
        NSInteger index = self.headIndex + idx;
        CGRect frame = [self frameForItemAtIndex:index withXOffset:x];
        [array addObject:[NSValue valueWithCGRect:frame]];
        const CGSize size = [sizeValue CGSizeValue];
        x += size.width + interitemSpacing;
        idx++;
    }
    return array;
}

#pragma mark - Private API

- (CGRect)frameForItemAtIndex:(NSInteger)index withXOffset:(CGFloat)xOffset {
    const NSInteger i = index - self.headIndex;
    const CGSize itemSize = [self.itemSizes[i] CGSizeValue];

    // Center vertically
    const CGFloat y = (self.frame.size.height - itemSize.height) / 2;

    const CGRect frame = CGRectMake(self.frame.origin.x + xOffset, self.frame.origin.y + y, itemSize.width, itemSize.height);
    return frame;
}

@end
