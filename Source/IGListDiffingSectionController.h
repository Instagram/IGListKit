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

@class IGListDiffingSectionController;

NS_ASSUME_NONNULL_BEGIN

@protocol IGListDiffingSectionControllerDataSource <NSObject>

- (NSArray<id<IGListDiffable>> *)sectionController:(IGListDiffingSectionController *)sectionController
                               viewModelsForObject:(id)object;

- (UICollectionViewCell<IGListBindable> *)sectionController:(IGListDiffingSectionController *)sectionController
                                           cellForViewModel:(id)viewModel atIndex:(NSInteger)index;

- (CGSize)sectionController:(IGListDiffingSectionController *)sectionController
           sizeForViewModel:(id)viewModel;

@end

@protocol IGListDiffingSectionControllerSelectionDelegate

- (void)sectionController:(IGListDiffingSectionController *)sectionController
     didSelectItemAtIndex:(NSInteger)index
                viewModel:(id)viewModel;

@end

@interface IGListDiffingSectionController : IGListSectionController<IGListSectionType>

@property (nonatomic, weak, nullable) id<IGListDiffingSectionControllerDataSource> dataSource;

@property (nonatomic, weak, nullable) id<IGListDiffingSectionControllerSelectionDelegate> selectionDelegate;

@property (nonatomic, strong, readonly) NSArray<id<IGListDiffable>> *viewModels;

- (void)updateAnimated:(BOOL)animated completion:(nullable void (^)())completion;

@end

NS_ASSUME_NONNULL_END
