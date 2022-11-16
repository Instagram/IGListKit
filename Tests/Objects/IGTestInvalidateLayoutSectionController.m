/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGTestInvalidateLayoutSectionController.h"

#import "IGLayoutTestItem.h"
#import "IGTestCell.h"
#import "IGTestInvalidateLayoutObject.h"
#import "IGTestObject.h"

@implementation IGTestInvalidateLayoutSectionController

- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = self;
    }
    return self;
}

#pragma mark - IGListBindingSectionControllerDataSource

- (NSArray<id<IGListDiffable>> *)sectionController:(IGListBindingSectionController *)sectionController viewModelsForObject:(id)object {
    return [(IGTestInvalidateLayoutObject *)object objects];
}

- (UICollectionViewCell<IGListBindable> *)sectionController:(IGListBindingSectionController *)sectionController cellForViewModel:(id)viewModel atIndex:(NSInteger)index {
    IGTestCell *cell = [self.collectionContext dequeueReusableCellOfClass:[IGTestCell class] forSectionController:self atIndex:index];
    return cell;
}

- (CGSize)sectionController:(IGListBindingSectionController *)sectionController sizeForViewModel:(id)viewModel atIndex:(NSInteger)index {
    return [(IGLayoutTestItem *)[(IGTestObject *)viewModel value] size];
}

@end
