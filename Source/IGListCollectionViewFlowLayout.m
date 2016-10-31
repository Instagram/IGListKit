/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <IGListKit/IGListAssert.h>
#import "IGListCollectionViewFlowLayout.h"

@interface _IGFlowLayoutLine : NSObject

/**
 The scroll direction of the grid.
 */
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

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
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

/**
 The spacing to use between items.
 */
@property (nonatomic, assign) CGFloat interitemSpacing;

/**
 The sizes to of the items in line.
 */
@property (nonatomic, copy) NSMutableArray<NSValue *> *itemSizes;

/**
 The index in itemSize array of the index path.
 */
@property (nonatomic, copy) NSMutableDictionary<NSIndexPath*, NSNumber*> *indexForIndexPath;

/**
 Initialization
 */
- (id)initWithFrame:(CGRect)frame scrollDirection:(UICollectionViewScrollDirection)direction minimumInteritemSpacing:(CGFloat)spacing;

/**
 Adds item to the tail of the line with index path.
 
 @param size The size of the item to be added.
 
 @return A bool indicates if the item can be added to the line.
 */
- (BOOL)addItemToTailWithSize:(CGSize)size atIndexPath:(NSIndexPath *)indexPath;

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

- (NSArray<UICollectionViewLayoutAttributes *> *)attributesForItems;

@end

@interface IGListCollectionViewFlowLayout ()

/**
 The array for line objects in order of line number.
 */
@property (nonatomic, copy, nullable) NSMutableArray<_IGFlowLayoutLine *> *lineCache;

/**
 The line number for each item in order of index path.
 */
@property (nonatomic, copy, nullable) NSMutableArray *lineForItem;

/**
 The width of in collection view content.
 */
@property (nonatomic, assign) CGFloat contentWidth;

/**
 The height of in collection view content.
 */
@property (nonatomic, assign) CGFloat contentHeight;

@end

@implementation IGListCollectionViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _scrollDirection = UICollectionViewScrollDirectionVertical;
    _minimumLineSpacing = 0.0;
    _minimumInteritemSpacing = 0.0;
    _lineCache = [NSMutableArray<_IGFlowLayoutLine *> array];
    _lineForItem = [NSMutableArray array];
}

#pragma mark - Layout Infomation

- (void)prepareLayout
{
    if ([self.lineCache count] == 0) {
        // Init first line and add to lineCache
        CGRect frame = CGRectMake(0, 0, self.contentWidth, 0);
        _IGFlowLayoutLine *firstLine = [[_IGFlowLayoutLine alloc] initWithFrame:frame scrollDirection:self.scrollDirection minimumInteritemSpacing:self.minimumInteritemSpacing];
        [self.lineCache addObject:firstLine];
        
        for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
            id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>) self.collectionView.delegate;
            CGSize itemSize = [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
            _IGFlowLayoutLine *lastLine = [self.lineCache lastObject];
            if (![lastLine addItemToTailWithSize:itemSize atIndexPath:indexPath]) {
                // Not enough space for the last line
                CGFloat y = lastLine.frame.origin.y + lastLine.frame.size.height + self.minimumLineSpacing;
                frame = CGRectMake(0, y, self.contentWidth, 0);
                _IGFlowLayoutLine *newLine = [[_IGFlowLayoutLine alloc] initWithFrame:frame scrollDirection:self.scrollDirection minimumInteritemSpacing:self.minimumInteritemSpacing];
                [self.lineCache addObject:newLine];
                [newLine addItemToTailWithSize:itemSize atIndexPath:indexPath];
            }
            [self.lineForItem addObject:[NSNumber numberWithInteger:(self.lineCache.count - 1)]];
        }
    }
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.contentWidth, self.contentHeight);
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [NSMutableArray array];
    for (_IGFlowLayoutLine *line in self.lineCache) {
        if (CGRectIntersectsRect(line.frame, rect)) {
            NSArray<UICollectionViewLayoutAttributes *> *lineAttributes = [line attributesForItems];
            for (UICollectionViewLayoutAttributes *attributes in lineAttributes) {
                if (CGRectIntersectsRect(attributes.frame, rect)) {
                    [array addObject:attributes];
                }
            }
        }
    }
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lineNumber = [self.lineForItem[indexPath.section] integerValue];
    _IGFlowLayoutLine *line = self.lineCache[lineNumber];
    return [line attributesForItemAtIndexPath:indexPath];
}

#pragma mark - Getter Setter

- (CGFloat)contentWidth
{
    UIEdgeInsets insets = self.collectionView.contentInset;
    return CGRectGetWidth(self.collectionView.bounds) - (insets.left + insets.right);
}

- (CGFloat)contentHeight
{
    UIEdgeInsets insets = self.collectionView.contentInset;
    CGFloat height = 0;
    for (_IGFlowLayoutLine *line in self.lineCache) {
        height += line.frame.size.height;
    }
    height += [self.lineCache count] * self.minimumLineSpacing - (insets.top + insets.bottom);
    return height;
}

@end

#pragma mark _IGFlowLayoutLine

@implementation _IGFlowLayoutLine

- (id)initWithFrame:(CGRect)frame scrollDirection:(UICollectionViewScrollDirection)direction minimumInteritemSpacing:(CGFloat)spacing
{
    self = [super init];
    if (self) {
        _frame = frame;
        _scrollDirection = direction;
        _minimumInteritemSpacing = spacing;
        _itemSizes = [NSMutableArray array];
        _indexForIndexPath = [NSMutableDictionary dictionary];
        _tailSpace = frame.size.width - self.minimumInteritemSpacing;
    }
    return self;
}

- (BOOL)addItemToTailWithSize:(CGSize)size atIndexPath:(NSIndexPath *)indexPath
{
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
    self.indexForIndexPath[indexPath] = [NSNumber numberWithInteger:(self.itemSizes.count - 1)];
    return YES;
}

- (UICollectionViewLayoutAttributes *)attributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [self.indexForIndexPath[indexPath] integerValue];
    __block CGFloat x = 0;
    [self.itemSizes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < index) {
            CGSize size = [obj CGSizeValue];
            x += size.width + self.minimumInteritemSpacing;
        } else {
            *stop = YES;
        }
    }];
    CGSize itemSize = [self.itemSizes[index] CGSizeValue];
    
    // Center vertically
    CGFloat y = (self.frame.size.height - itemSize.height) / 2;
    
    CGRect frame = CGRectMake(self.frame.origin.x + x, self.frame.origin.y + y, itemSize.width, itemSize.height);
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = frame;
    return attributes;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)attributesForItems
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSIndexPath *indexPath in [self.indexForIndexPath allKeys]) {
        // Can improve performance here
        [array addObject:[self attributesForItemAtIndexPath:indexPath]];
    }
    return array;
}

@end
