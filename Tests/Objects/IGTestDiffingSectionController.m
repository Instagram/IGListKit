/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestDiffingSectionController.h"

#import "IGTestDiffingObject.h"
#import "IGTestStringBindableCell.h"
#import "IGTestNumberBindableCell.h"

@implementation IGTestDiffingSectionController

- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = self;
        self.selectionDelegate = self;
    }
    return self;
}

#pragma mark - IGListDiffingSectionControllerDataSource

- (NSArray<id<IGListDiffable>> *)sectionController:(IGListDiffingSectionController *)sectionController viewModelsForObject:(id)object {
    return [(IGTestDiffingObject *)object objects];
}

- (UICollectionViewCell<IGListBindable> *)sectionController:(IGListDiffingSectionController *)sectionController cellForViewModel:(id)viewModel atIndex:(NSInteger)index {
    const BOOL isString = [viewModel isKindOfClass:[NSString class]];
    Class cellClass = isString ? [IGTestStringBindableCell class] : [IGTestNumberBindableCell class];
    id cell = [self.collectionContext dequeueReusableCellOfClass:cellClass forSectionController:self atIndex:index];
    return cell;
}

- (CGSize)sectionController:(IGListDiffingSectionController *)sectionController sizeForViewModel:(id)viewModel {
    const BOOL isString = [viewModel isKindOfClass:[NSString class]];
    return CGSizeMake([self.collectionContext containerSize].width, isString ? 55 : 30);
}

#pragma mark - IGListDiffingSectionControllerSelectionDelegate

- (void)sectionController:(IGListDiffingSectionController *)sectionController didSelectItemAtIndex:(NSInteger)index viewModel:(id)viewModel {
    self.selectedViewModel = viewModel;
}

@end
