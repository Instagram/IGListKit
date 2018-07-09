/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Conform to this protocol to provide information about a list's supplementary views. This data is used in
 `IGListAdapter` which then configures and maintains a `UICollectionView`. The supplementary API reflects that in
 `UICollectionView`, `UICollectionViewLayout`, and `UICollectionViewDataSource`.
 */
NS_SWIFT_NAME(ListSupplementaryViewSource)
@protocol IGListSupplementaryViewSource <NSObject>

/**
 Asks the SupplementaryViewSource for an array of supported element kinds.

 @return An array of element kind strings that the supplementary source handles.
 */
- (NSArray<NSString *> *)supportedElementKinds;

/**
 Asks the SupplementaryViewSource for a configured supplementary view for the specified kind and index.

 @param elementKind The kind of supplementary view being requested
 @param index The index for the supplementary veiw being requested.

 @note This is your opportunity to do any supplementary view setup and configuration.

 @warning You should never allocate new views in this method. Instead deque a view from the `IGListCollectionContext`.
 */
- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index;

/**
 Asks the SupplementaryViewSource for the size of a supplementary view for the given kind and index path.

 @param elementKind The kind of supplementary view.
 @param index The index of the requested view.

 @return The size for the supplementary view.
 */
- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
