/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import "IGListSectionController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Special section controller that only contains a single item, and it will apply the view model update during -didUpdateObject: call, usually happened inside -[UICollectionView performBatchUpdates:completion:].

 This class is intended to be subclassed.
 */
NS_SWIFT_NAME(ListBindingSingleSectionController)
@interface IGListBindingSingleSectionController<__covariant ViewModel : id<IGListDiffable>, Cell : UICollectionViewCell *> : IGListSectionController

#pragma mark - Subclass

// Required to be implemented by subclass.
- (Class)cellClass;

// Required to be implemented by subclass.
- (void)configureCell:(Cell)cell withViewModel:(ViewModel)viewModel;

// Required to be implemented by subclass.
- (CGSize)sizeForViewModel:(ViewModel)viewModel;

// Subclasable. Defaults is no-op.
- (void)didSelectItemWithCell:(Cell)cell;

// Subclasable. Defaults is no-op.
- (void)didDeselectItemWithCell:(Cell)cell;

// Subclasable. Defaults is no-op.
- (void)didHighlightItemWithCell:(Cell)cell;

// Subclasable. Defaults is no-op.0
- (void)didUnhighlightItemWithCell:(Cell)cell;

- (BOOL)isDisplayingCell;

@end

NS_ASSUME_NONNULL_END
