/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListMacros.h>

NS_ASSUME_NONNULL_BEGIN

/**
 This UICollectionViewLayout subclass is for vertically-scrolling lists of data with variable widths and heights. It
 supports an infinite number of sections and items. All work is done on the main thread, and while extremely efficient,
 care must be taken not to stall the main thread in sizing delegate methods.

 This layout piggybacks on the mechanics of UICollectionViewFlowLayout in that:

 - Your UICollectionView data source must also conform to UICollectionViewDelegateFlowLayout
 - Header support given via UICollectionElementKindSectionHeader

 All UICollectionViewDelegateFlowLayout methods are required and used by this layout:

 ```
 - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
 - (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
 - (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
 - (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
 - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
 ```

 Sections and items are put into the same horizontal row until the max-x position of an item extends beyond the width
 of the collection view. When that happens, the item is "newlined" to the next row. The y position of that row is
 determined by the maximum height (including section insets) of the section/item of the previous row.

 Ex. of a section (2,0) with a large width causing a newline.
 ```
 |[ 0,0 ][ 1,0 ]         |
 |[         2,0         ]|
 ```

 A section with a non-zero height header will always cause that section to newline. Headers are always stretched to the
 width of the collection view, pinched with the section insets.

 Ex. of a section (2,0) with a header inset on the left/right.
 ```
 |[ 0,0 ][ 1,0 ]         |
 | >======header=======< |
 | [ 2,0 ]               |
 ```

 Section insets apply to items in the section no matter if they begin on a new row or are on the same row as a previous
 section.

 Ex. of a section (2) with multiple items and a left inset.
 ```
 |[ 0,0 ][ 1,0 ] >[ 2,0 ]|
 | >[ 2,1 ][ 2,2 ][ 2,3 ]|
 ```

 Interitem spacing applies to items and sections within the same row. Line spacing only applies to items within the same
 section.

 Please see the unit tests for more configuration examples and expected output.
 */
NS_SWIFT_NAME(ListCollectionViewLayout)
@interface IGListCollectionViewLayout : UICollectionViewLayout

/**
 Set this to adjust the offset of the sticky headers. Can be used to change the sticky header position as UI like the
 navigation bar is scrolled offscreen. Changing this to the height of the navigation bar will give the effect of the
 headers sticking to the nav as it is collapsed.

 @discussion Changing the value on this method will invalidate the layout every time.
 */
@property (nonatomic, assign) CGFloat stickyHeaderOriginYAdjustment;

/**
 Create and return a new collection view layout.

 @param stickyHeaders Set to `YES` to stick section headers to the top of the bounds while scrolling.
 @param topContentInset The top content inset used to offset the sticky headers. Ignored if stickyHeaders is `NO`.
 @param stretchToEdge Specifies whether to stretch width of last item to right edge when distance from last item to right edge < epsilon(1)

 @return A new collection view layout.
 */
- (instancetype)initWithStickyHeaders:(BOOL)stickyHeaders
                      topContentInset:(CGFloat)topContentInset
                        stretchToEdge:(BOOL)stretchToEdge NS_DESIGNATED_INITIALIZER;

/**
 :nodoc:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 :nodoc:
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
