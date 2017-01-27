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
#import <IGListKit/IGListSectionType.h>
#import <IGListKit/IGListSectionController.h>

@protocol IGListDiffable;
@protocol IGListBindable;

/**
 Other naming options
 
 - IGListDiffingSectionController
 - IGListBindingSectionController
 - IGListAutoSectionController
 */

NS_ASSUME_NONNULL_BEGIN

@protocol IGListAutoSectionControllerDataSource <NSObject>

- (NSArray<id<IGListDiffable>> *)viewModelsForObject:(id)object;
- (UICollectionViewCell<IGListBindable> *)cellForViewModel:(id)viewModel atIndex:(NSInteger)index;
- (CGSize)sizeForViewModel:(id)viewModel;

@end

@interface IGListAutoSectionController : IGListSectionController<IGListSectionType>

/**
 func transform(object: IGListDiffable) -> [IGListDiffable]
 func cellClass(viewModel: IGListDiffable) -> Class (of type UICollectionView<IGListBindable>)
 
 how to add "extra" stuff to the cell, e.g. delegates. options:
 - override superclass method (don't call super tho)
 - use IGListDisplayDelegate (adds lots of boilerplate)
 - new, optional delegate w/ bindable method
 */

@property (nonatomic, weak, nullable) id<IGListAutoSectionControllerDataSource> dataSource;

- (void)updateAnimated:(BOOL)animated completion:(nullable void (^)())completion;

@end

NS_ASSUME_NONNULL_END
