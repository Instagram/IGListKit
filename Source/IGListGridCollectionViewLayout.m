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

/**
 The scroll direction of the grid.
 */
@property (nonatomic, assign, readonly) UICollectionViewScrollDirection scrollDirection;

/**
 The width of the line (in the sense of scroll direction).
 */
@property (nonatomic, assign) CGRect frame;

/**
 The space remains of the line (in the sense of scroll direction).
 */
@property (nonatomic, assign) CGFloat tailSpace;

/**
 The minimum spacing to use between items.
 */
@property (nonatomic, assign, readonly) CGFloat minimumInteritemSpacing;

/**
 The section index of the first item in line.
 */
@property (nonatomic, assign) NSInteger headIndex;

/**
 The sizes to of the items in line.
 */
@property (nonatomic, copy) NSMutableArray<NSValue *> *itemSizes;

/**
 Initialization
 */
- (id)initWithMinimumInteritemSpacing:(CGFloat)spacing
                            headIndex:(NSInteger)headIndex
                                frame:(CGRect)frame
                      scrollDirection:(UICollectionViewScrollDirection)direction;

/**
 Adds item to the tail of the line with index path.
 
 @param size The size of the item to be added.
 
 @return A bool indicates if the item can be added to the line.
 */
- (BOOL)addItemToTailWithSize:(CGSize)size;

/**
 Get attributes of the item at index path.
 
 @param indexPath The index path of the item.
 
 @return The attributes for the item in collection view.
 */

- (UICollectionViewLayoutAttributes *)attributesForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Get attributes of all the item in line.
 
 @return An array of attributes for all the items in line.
 */

- (NSArray<UICollectionViewLayoutAttributes *> *)attributesForAllItems;

@end

#pragma mark - IGListGridCollectionViewLayout

@interface IGListGridCollectionViewLayout ()

/**
 The array for line objects in order of line number.
 */
@property (nonatomic, copy, nullable) NSMutableArray<_IGListGridLayoutLine *> *lineCache;

/**
 The line number for each item in order of index path.
 */
@property (nonatomic, copy, nullable) NSMutableArray *lineForItem;

/**
 The width of in collection view content.
 */
@property (nonatomic, assign, readonly) CGFloat contentWidth;

/**
 The height of in collection view content.
 */
@property (nonatomic, assign, readonly) CGFloat contentHeight;

/**
 The item count per line when item has fixed size.
 */
@property (nonatomic, assign) NSInteger itemPerLine;

/**
 The line count when item has fixed size.
 */
@property (nonatomic, assign) NSInteger lineNumber;

/**
 The real interitem spacing when item has fixed size.
 */
@property (nonatomic, assign) CGFloat interitemSpacing;

@end

#pragma mark - IGListGridCollectionViewLayout Implementation

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
    _scrollDirection = UICollectionViewScrollDirectionVertical;
    _minimumLineSpacing = 0.0;
    _minimumInteritemSpacing = 0.0;
    _lineCache = [NSMutableArray<_IGListGridLayoutLine *> array];
    _lineForItem = [NSMutableArray array];
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
        NSInteger firstLine = (int)(rect.origin.y / (self.itemSize.height + self.minimumLineSpacing));
        NSInteger lastLine = (int)((rect.origin.y + rect.size.height + self.itemSize.height + self.minimumLineSpacing)
                                             / (self.itemSize.height + self.minimumLineSpacing));
        NSInteger firstColumn = (int)(rect.origin.x / (self.itemSize.width + self.minimumInteritemSpacing));
        NSInteger LastColumn = (int)((rect.origin.x + rect.size.width + self.itemSize.width + self.minimumInteritemSpacing)
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
                [array addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
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
                                                                                        frame:frame
                                                                              scrollDirection:self.scrollDirection];
    [self.lineCache addObject:firstLine];
    
    for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
        id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>) self.collectionView.delegate;
        const CGSize itemSize = [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        _IGListGridLayoutLine *lastLine = [self.lineCache lastObject];
        if (![lastLine addItemToTailWithSize:itemSize]) {
            // Not enough space for the last line
            CGFloat y = lastLine.frame.origin.y + lastLine.frame.size.height + self.minimumLineSpacing;
            frame = CGRectMake(0, y, self.contentWidth, 0);
            _IGListGridLayoutLine *newLine = [[_IGListGridLayoutLine alloc] initWithMinimumInteritemSpacing:self.minimumInteritemSpacing
                                                                                            headIndex:i
                                                                                                frame:frame
                                                                                      scrollDirection:self.scrollDirection];
            [self.lineCache addObject:newLine];
            [newLine addItemToTailWithSize:itemSize];
        }
        [self.lineForItem addObject:[NSNumber numberWithInteger:(self.lineCache.count - 1)]];
    }
}

- (void)reloadLayoutWithConstantItemSize:(CGSize)itemSize {
    self.itemPerLine = (int) ((self.contentWidth + self.minimumInteritemSpacing)
                               / (itemSize.width + self.minimumInteritemSpacing));
    self.lineNumber = (self.collectionView.numberOfSections + self.itemPerLine - 1) / self.itemPerLine;
    self.interitemSpacing = (self.contentWidth - (self.itemSize.width * self.itemPerLine)) / (self.itemPerLine - 1);
}

@end

@implementation _IGListGridLayoutLine

- (id)initWithMinimumInteritemSpacing:(CGFloat)spacing
                            headIndex:(NSInteger)headIndex
                                frame:(CGRect)frame
                      scrollDirection:(UICollectionViewScrollDirection)direction {
    IGAssertMainThread();
    IGParameterAssert(spacing >= 0);
    IGParameterAssert(headIndex >= 0);
    
    self = [super init];
    if (self) {
        _frame = frame;
        _scrollDirection = direction;
        _minimumInteritemSpacing = spacing;
        _itemSizes = [NSMutableArray array];
        _headIndex = headIndex;
        _tailSpace = frame.size.width - self.minimumInteritemSpacing;
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
    return array;
}

#pragma mark - Private API

- (UICollectionViewLayoutAttributes *)attributesForItemAtIndexPath:(NSIndexPath *)indexPath withXOffset:(CGFloat)x {
    const NSInteger index = indexPath.section - self.headIndex;
    const CGSize itemSize = [self.itemSizes[index] CGSizeValue];
    
    // Center vertically
    const CGFloat y = (self.frame.size.height - itemSize.height) / 2;
    
    const CGRect frame = CGRectMake(self.frame.origin.x + x, self.frame.origin.y + y, itemSize.width, itemSize.height);
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = frame;
    return attributes;
}

@end
