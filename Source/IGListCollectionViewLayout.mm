/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListCollectionViewLayout.h"

#import <vector>

#import <IGListKit/IGListAssert.h>

static NSString *const kDecorationBorderViewIdentifier = @"kDecorationBorderViewIdentifier";

static NSIndexPath *headerIndexPathForSection(NSInteger section) {
    return [NSIndexPath indexPathForItem:0 inSection:section];
}

struct IGSectionEntry {
    /**
     Represents the minimum-bounding box of every element in the section. This includes all item frames as well as the
     header bounds. It is made simply by unioning all item and header frames. Use this to find section intersections
     to build layout attributes given a rect.
     */
    CGRect bounds;

    // The insets for the section. Used to find total content size of the section.
    UIEdgeInsets insets;

    // The RESTING frame of the header view (e.g. when the header is not sticking to the top of the scroll view).
    CGRect headerBounds;

    // An array of frames for each cell in the section.
    std::vector<CGRect> itemBounds;

    // Returns YES when the section has visible content (header and/or items).
    BOOL isValid() {
        return !CGSizeEqualToSize(bounds.size, CGSizeZero);
    }
};

// Each section has a base zIndex of section * maxZIndexPerSection;
// section header adds (maxZIndexPerSection - 1) to the base zIndex;
// other cells adds (item) to the base zIndex.
// This allows us to present tooltips that can grow from the cell to its top.
static void adjustZIndexForAttributes(UICollectionViewLayoutAttributes *attributes) {
    const NSInteger maxZIndexPerSection = 1000;
    const NSInteger baseZIndex = attributes.indexPath.section * maxZIndexPerSection;

    switch (attributes.representedElementCategory) {
        case UICollectionElementCategoryCell:
            attributes.zIndex = baseZIndex + attributes.indexPath.item;
            break;
        case UICollectionElementCategorySupplementaryView:
            IGAssert([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader],
                     @"Only support for element kind header, not %@", attributes.representedElementKind);
            attributes.zIndex = baseZIndex + maxZIndexPerSection - 1;
            break;
        case UICollectionElementCategoryDecorationView:
            attributes.zIndex = baseZIndex - 1;
            break;
    }
}

@interface IGVerticalCollectionViewLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext
@property (nonatomic, assign) BOOL ig_invalidateSupplementaryAttributes;
@property (nonatomic, assign) BOOL ig_invalidateAllAttributes;
@end

@implementation IGVerticalCollectionViewLayoutInvalidationContext
@end

@interface IGListCollectionViewLayout ()

@property (nonatomic, assign, readonly) BOOL stickyHeaders;
@property (nonatomic, assign, readonly) CGFloat topContentInset;
@property (nonatomic, assign, readonly) CGFloat maximumContentWidth;

@end

@implementation IGListCollectionViewLayout {
    std::vector<IGSectionEntry> _sectionData;
    NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *_attributesCache;
    BOOL _cachedLayoutInvalid;

    /**
     The workflow for getting sticky headers working:
     1. Use a custom invalidation context to mark supplementary attributes invalid.
     2. Return YES from -shouldInvalidateLayoutForBoundsChange:
     3. In -invalidationContextForBoundsChange: mark supplementary attributes invalid on the custom context.
     4. Purge supplementary caches in -invalidateLayoutWithContext: if context says they are invalid
     5. Use cached attributes in -layoutAttributesForSupplementaryViewOfKind:atIndexPath: if they exist, else rebuild
     6. Make sure -layoutAttributesForElementsInRect: always uses the attributes returned from
     -layoutAttributesForSupplementaryViewOfKind:atIndexPath:.
     */
    NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *_headerAttributesCache;
    NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *_borderAttributesCache;
}

- (instancetype)initWithStickyHeaders:(BOOL)stickyHeaders
                      topContentInset:(CGFloat)topContentInset {
    return [self initWithStickyHeaders:stickyHeaders
                       topContentInset:topContentInset
                   maximumContentWidth:CGFLOAT_MAX
                 decorationBorderClass:nil];
}

- (instancetype)initWithStickyHeaders:(BOOL)stickyHeaders
                      topContentInset:(CGFloat)topContentInset
                  maximumContentWidth:(CGFloat)maximumContentWidth
                decorationBorderClass:(Class)decorationBorderClass  {
    if (self = [super init]) {
        _stickyHeaders = stickyHeaders;
        _topContentInset = topContentInset;
        _maximumContentWidth = maximumContentWidth;
        _attributesCache = [NSMutableDictionary new];
        _headerAttributesCache = [NSMutableDictionary new];
        _borderAttributesCache = [NSMutableDictionary new];
        _cachedLayoutInvalid = YES;

        if (decorationBorderClass != nil) {
            [self registerClass:decorationBorderClass forDecorationViewOfKind:kDecorationBorderViewIdentifier];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    IGAssert(NO, @"Layout initialized from storybaords not yet supported");
    return [self initWithStickyHeaders:0 topContentInset:0 maximumContentWidth:0 decorationBorderClass:nil];
}

#pragma mark - UICollectionViewLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    IGAssertMainThread();

    NSMutableArray *result = [NSMutableArray new];

    // since we iterate through sections ascending, we may hit a section who is only partially visible
    // in that case we short circuit building layout attributes
    BOOL remainingCellsOutOfRect = NO;

    const NSRange range = [self rangeOfSectionsInRect:rect];
    if (range.location == NSNotFound) {
        return nil;
    }

    for (NSInteger section = range.location; section < NSMaxRange(range); section++) {
        const NSInteger itemCount = _sectionData[section].itemBounds.size();

        // do not add headers if there are no items
        if (itemCount > 0) {
            NSIndexPath *headerIndexPath = headerIndexPathForSection(section);
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                atIndexPath:headerIndexPath];
            // do not add zero height headers or headers that are outside the rect
            const CGRect frame = attributes.frame;
            const CGRect intersection = CGRectIntersection(frame, rect);
            if (!CGRectIsEmpty(intersection) || CGRectGetHeight(frame) == 0.0) {
                if (CGRectGetHeight(frame) > 0.0) {
                    [result addObject:attributes];
                }

                if (CGRectGetWidth(frame) >= self.maximumContentWidth) {
                    UICollectionViewLayoutAttributes *borderAttributes = [self layoutAttributesForDecorationViewOfKind:kDecorationBorderViewIdentifier atIndexPath:headerIndexPath];
                    [result addObject:borderAttributes];
                }
            }
        }

        // add all cells within the rect, return early if it starts iterating outside
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (!CGRectIntersectsRect(attributes.frame, rect)) {
                if (remainingCellsOutOfRect) {
                    return result;
                }
            } else {
                remainingCellsOutOfRect = YES;
                [result addObject:attributes];
            }
        }
    }

    return result;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    IGAssertMainThread();
    IGParameterAssert(indexPath != nil);

    UICollectionViewLayoutAttributes *attributes = _attributesCache[indexPath];
    if (attributes != nil) {
        return attributes;
    }

    attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = _sectionData[indexPath.section].itemBounds[indexPath.item];
    adjustZIndexForAttributes(attributes);
    _attributesCache[indexPath] = attributes;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    IGAssertMainThread();
    IGParameterAssert([elementKind isEqualToString:UICollectionElementKindSectionHeader]);
    IGParameterAssert(indexPath != nil);

    UICollectionViewLayoutAttributes *attributes = _headerAttributesCache[indexPath];
    if (attributes != nil) {
        return attributes;
    }

    UICollectionView *collectionView = self.collectionView;
    const NSInteger section = indexPath.section;
    const IGSectionEntry entry = _sectionData[section];
    const CGFloat minY = CGRectGetMinY(entry.bounds);

    CGRect frame = entry.headerBounds;

    if (self.stickyHeaders) {
        const CGFloat yOffset = collectionView.contentOffset.y + self.topContentInset + self.stickyHeaderOriginYAdjustment;

        if (section + 1 == _sectionData.size()) {
            frame.origin.y = MAX(minY, yOffset);
        } else {
            const CGFloat maxY = CGRectGetMinY(_sectionData[section + 1].bounds) - CGRectGetHeight(frame);
            frame.origin.y = MIN(MAX(minY, yOffset), maxY);
        }
    }

    attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    attributes.frame = frame;
    adjustZIndexForAttributes(attributes);
    _headerAttributesCache[indexPath] = attributes;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)decorationBorderViewOfKind:(NSString *)kind
                                                     atIndexPath:(NSIndexPath *)indexPath
                                     withSectionHeaderAttributes:(UICollectionViewLayoutAttributes *)headerAttributes {
    NSInteger section = headerAttributes.indexPath.section;
    NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:section];
    UICollectionViewLayoutAttributes *decorationViewAttributes = nil;

    NSIndexPath *firstObjectIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    NSIndexPath *lastObjectIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];

    CGRect headerFrame = headerAttributes.frame;
    CGRect firstObjectFrame;
    CGRect lastObjectFrame;
    if (numberOfItemsInSection > 0) {
        firstObjectFrame = [self layoutAttributesForItemAtIndexPath:firstObjectIndexPath].frame;
        lastObjectFrame = [self layoutAttributesForItemAtIndexPath:lastObjectIndexPath].frame;
    } else {
        firstObjectFrame = headerFrame;
        lastObjectFrame = headerFrame;
    }

    decorationViewAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:firstObjectIndexPath];
    decorationViewAttributes.frame = CGRectMake(CGRectGetMinX(headerFrame) - 1,
                                                MIN(CGRectGetMinY(headerFrame), CGRectGetMinY(firstObjectFrame)) - 1,
                                                CGRectGetWidth(headerFrame) + 2,
                                                MAX(CGRectGetMaxY(lastObjectFrame), CGRectGetMaxY(headerFrame)) - MIN(CGRectGetMinY(headerFrame), CGRectGetMinY(firstObjectFrame)) + 2);
    return decorationViewAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    IGAssertMainThread();
    IGParameterAssert(indexPath != nil);

    UICollectionViewLayoutAttributes *attributes = _borderAttributesCache[indexPath];
    if (attributes != nil) {
        return attributes;
    }
    if (CGRectGetWidth(self.collectionView.bounds) < self.maximumContentWidth) {
        return nil;
    }
    UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
    attributes = [self decorationBorderViewOfKind:decorationViewKind atIndexPath:indexPath withSectionHeaderAttributes:headerAttributes];
    adjustZIndexForAttributes(attributes);
    _borderAttributesCache[indexPath] = attributes;
    return attributes;
}

- (CGSize)collectionViewContentSize {
    IGAssertMainThread();

    const NSInteger sectionCount = _sectionData.size();

    if (sectionCount == 0) {
        return CGSizeZero;
    }

    const IGSectionEntry section = _sectionData[sectionCount - 1];
    const CGFloat height = CGRectGetMaxY(section.bounds) + section.insets.bottom;
    return CGSizeMake(MIN(CGRectGetWidth(self.collectionView.bounds), self.maximumContentWidth), height);
}

- (void)invalidateLayoutWithContext:(IGVerticalCollectionViewLayoutInvalidationContext *)context {
    BOOL hasInvalidatedItemIndexPaths = NO;
    if ([context respondsToSelector:@selector(invalidatedItemIndexPaths)]) {
        hasInvalidatedItemIndexPaths = [context invalidatedItemIndexPaths].count > 0;
    }

    if (hasInvalidatedItemIndexPaths
        || [context invalidateEverything]
        || [context invalidateDataSourceCounts]
        || context.ig_invalidateAllAttributes) {
        _cachedLayoutInvalid = YES;
    }

    if (context.ig_invalidateSupplementaryAttributes) {
        [_headerAttributesCache removeAllObjects];
        [_borderAttributesCache removeAllObjects];
    }

    [super invalidateLayoutWithContext:context];
}

+ (Class)invalidationContextClass {
    return [IGVerticalCollectionViewLayoutInvalidationContext class];
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds {
    const CGRect oldBounds = self.collectionView.bounds;

    IGVerticalCollectionViewLayoutInvalidationContext *context =
    (IGVerticalCollectionViewLayoutInvalidationContext *)[super invalidationContextForBoundsChange:newBounds];
    context.ig_invalidateSupplementaryAttributes = YES;
    if (!CGSizeEqualToSize(oldBounds.size, newBounds.size)) {
        context.ig_invalidateAllAttributes = YES;
    }
    return context;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    const CGRect oldBounds = self.collectionView.bounds;

    // if the y origin has changed, only invalidate when using sticky headers
    if (CGRectGetMinY(newBounds) != CGRectGetMinY(oldBounds)) {
        return self.stickyHeaders;
    }

    // always invalidate for size changes
    return !CGSizeEqualToSize(oldBounds.size, newBounds.size);
}

- (void)prepareLayout {
    if (_cachedLayoutInvalid) {
        [self cacheLayout];
    }
}

#pragma mark - Public API

- (void)setStickyHeaderOriginYAdjustment:(CGFloat)stickyHeaderOriginYAdjustment {
    IGAssertMainThread();

    if (_stickyHeaderOriginYAdjustment != stickyHeaderOriginYAdjustment) {
        _stickyHeaderOriginYAdjustment = stickyHeaderOriginYAdjustment;

        IGVerticalCollectionViewLayoutInvalidationContext *invalidationContext = [[IGVerticalCollectionViewLayoutInvalidationContext alloc] init];
        invalidationContext.ig_invalidateSupplementaryAttributes = YES;
        [self invalidateLayoutWithContext:invalidationContext];
    }
}

#pragma mark - Private API

- (void)cacheLayout {
    _cachedLayoutInvalid = NO;

    // purge attribute caches so they are rebuilt
    [_attributesCache removeAllObjects];
    [_headerAttributesCache removeAllObjects];
    [_borderAttributesCache removeAllObjects];

    UICollectionView *collectionView = self.collectionView;
    id<UICollectionViewDataSource> dataSource = collectionView.dataSource;
    id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)collectionView.delegate;

    const NSInteger sectionCount = [dataSource numberOfSectionsInCollectionView:collectionView];
    const CGFloat collectionViewWidth = CGRectGetWidth(collectionView.bounds);
    const CGFloat width = MIN(collectionViewWidth, self.maximumContentWidth);
    const CGFloat centeringInset = (collectionViewWidth - width) / 2.0f;

    auto sectionData = std::vector<IGSectionEntry>(sectionCount);

    CGFloat itemY = 0.0;
    CGFloat maxRowHeight = 0.0;
    CGFloat itemX = 0.0;

    // union item frames and optionally the header to find a bounding box of the entire section
    CGRect rollingSectionBounds;

    for (NSInteger section = 0; section < sectionCount; section++) {
        const NSInteger itemCount = [dataSource collectionView:collectionView numberOfItemsInSection:section];
        sectionData[section].itemBounds = std::vector<CGRect>(itemCount);

        const CGSize headerSize = [delegate collectionView:collectionView layout:self referenceSizeForHeaderInSection:section];
        const UIEdgeInsets insets = [delegate collectionView:collectionView layout:self insetForSectionAtIndex:section];
        const CGFloat lineSpacing = [delegate collectionView:collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
        const CGFloat interitemSpacing = [delegate collectionView:collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];

        const CGFloat paddedWidth = width - insets.left - insets.right;
        const BOOL headerExists = headerSize.height > 0;

        // start the section y accounting for the header height
        // header height is subtracted from the sectionBounds when calculating the header bounds after items are done
        // this bumps the first row of items down enough to make room for the header
        itemY += headerSize.height;

        // add the left inset in case the section falls on the same row as the previous
        // if the section is newlined then the x is reset
        itemX += insets.left;

        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            const CGSize size = [delegate collectionView:collectionView layout:self sizeForItemAtIndexPath:indexPath];

            IGAssert(size.width <= paddedWidth, @"Width of item %zi in section %zi must be less than container %.0f accounting for section insets %@",
                     item, section, width, NSStringFromUIEdgeInsets(insets));
            const CGFloat itemWidth = MIN(size.width, paddedWidth);

            // if the x + width of the item busts the width of the container
            // or if this is the first item and the header has a non-zero size
            // newline to the next row and reset
            if ((itemX + itemWidth > paddedWidth) ||
                (item == 0 && headerExists)) {
                itemY += maxRowHeight;
                itemX = insets.left;
                maxRowHeight = 0.0;

                // if newlining, always append line spacing unless its the very first item of the section
                if (item > 0) {
                    itemY += lineSpacing;
                }
            }

            const CGRect frame = CGRectMake(centeringInset + itemX,
                                            itemY + insets.top,
                                            itemWidth,
                                            size.height);
            sectionData[section].itemBounds[item] = frame;

            // track the max size of the row to find the y of the next row
            if (size.height > maxRowHeight) {
                maxRowHeight = size.height;
            }

            // increase the rolling x by the item width and add item spacing for all items on the same row
            itemX += itemWidth + interitemSpacing;

            // union the rolling section bounds
            if (item == 0) {
                rollingSectionBounds = frame;
            } else {
                rollingSectionBounds = CGRectUnion(rollingSectionBounds, frame);
            }
        }

        const CGRect headerBounds = CGRectMake(insets.left,
                                               CGRectGetMinY(rollingSectionBounds) - headerSize.height,
                                               paddedWidth,
                                               headerSize.height);
        sectionData[section].headerBounds = headerBounds;

        // union the header before setting the bounds of the section
        // only do this when the header has a size, otherwise the union stretches to box empty space
        if (headerExists) {
            rollingSectionBounds = CGRectUnion(rollingSectionBounds, headerBounds);
        }

        sectionData[section].bounds = rollingSectionBounds;
        sectionData[section].insets = insets;

        // bump the x for the next section with the right insets
        itemX += insets.right;

        // account for the top/bottom insets of the section since maxRowHeight only uses the item size.height
        maxRowHeight += insets.top + insets.bottom;
    }

    _sectionData = sectionData;
}

- (NSRange)rangeOfSectionsInRect:(CGRect)rect {
    NSRange result = NSMakeRange(NSNotFound, 0);

    const NSInteger sectionCount = _sectionData.size();
    for (NSInteger section = 0; section < sectionCount; section++) {
        IGSectionEntry entry = _sectionData[section];
        if (entry.isValid() && CGRectIntersectsRect(entry.bounds, rect)) {
            const NSRange sectionRange = NSMakeRange(section, 1);
            if (result.location == NSNotFound) {
                result = sectionRange;
            } else {
                result = NSUnionRange(result, sectionRange);
            }
        }
    }
    
    return result;
}

@end
