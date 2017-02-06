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

@class IGListAutoSectionController;

NS_ASSUME_NONNULL_BEGIN

@protocol IGListAutoSectionControllerDataSource <NSObject>

- (NSArray<id<IGListDiffable>> *)sectionController:(IGListAutoSectionController *)sectionController
                               viewModelsForObject:(id)object;

- (UICollectionViewCell<IGListBindable> *)sectionController:(IGListAutoSectionController *)sectionController
                                           cellForViewModel:(id)viewModel atIndex:(NSInteger)index;

- (CGSize)sectionController:(IGListAutoSectionController *)sectionController
           sizeForViewModel:(id)viewModel;

@end

@protocol IGListAutoSectionControllerSelectionDelegate

- (void)sectionController:(IGListAutoSectionController *)sectionController
     didSelectItemAtIndex:(NSInteger)index
                viewModel:(id)viewModel;

@end

@interface IGListAutoSectionController : IGListSectionController<IGListSectionType>

@property (nonatomic, weak, nullable) id<IGListAutoSectionControllerDataSource> dataSource;

@property (nonatomic, weak, nullable) id<IGListAutoSectionControllerSelectionDelegate> selectionDelegate;

@property (nonatomic, strong, readonly) NSArray<id<IGListDiffable>> *viewModels;

- (void)updateAnimated:(BOOL)animated completion:(nullable void (^)())completion;

@end

NS_ASSUME_NONNULL_END
