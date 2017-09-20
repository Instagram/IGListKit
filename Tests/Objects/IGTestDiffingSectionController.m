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
#import "IGTestObject.h"
#import "IGTestCell.h"

@implementation IGTestDiffingSectionController

- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = self;
        self.selectionDelegate = self;
    }
    return self;
}

#pragma mark - IGListBindingSectionControllerDataSource

- (NSArray<id<IGListDiffable>> *)sectionController:(IGListBindingSectionController *)sectionController viewModelsForObject:(id)object {
    return [(IGTestDiffingObject *)object objects];
}

- (UICollectionViewCell<IGListBindable> *)sectionController:(IGListBindingSectionController *)sectionController cellForViewModel:(id)viewModel atIndex:(NSInteger)index {
    Class cellClass;
    if ([viewModel isKindOfClass:[NSString class]]) {
        cellClass = [IGTestStringBindableCell class];
    } else if ([viewModel isKindOfClass:[NSNumber class]]) {
        cellClass = [IGTestNumberBindableCell class];
    } else {
        cellClass = [IGTestCell class];
    }
    id cell = [self.collectionContext dequeueReusableCellOfClass:cellClass forSectionController:self atIndex:index];
    return cell;
}

- (CGSize)sectionController:(IGListBindingSectionController *)sectionController sizeForViewModel:(id)viewModel atIndex:(NSInteger)index {
    const BOOL isString = [viewModel isKindOfClass:[NSString class]];
    return CGSizeMake([self.collectionContext containerSize].width, isString ? 55 : 30);
}

#pragma mark - IGListBindingSectionControllerSelectionDelegate

- (void)sectionController:(IGListBindingSectionController *)sectionController didSelectItemAtIndex:(NSInteger)index viewModel:(id)viewModel {
    self.selectedViewModel = viewModel;
}

- (void)sectionController:(IGListBindingSectionController *)sectionController didDeselectItemAtIndex:(NSInteger)index viewModel:(id)viewModel {
    self.deselectedViewModel = viewModel;
}

- (void)sectionController:(IGListBindingSectionController *)sectionController didHighlightItemAtIndex:(NSInteger)index viewModel:(id)viewModel {
    self.highlightedViewModel = viewModel;
}

- (void)sectionController:(IGListBindingSectionController *)sectionController didUnhighlightItemAtIndex:(NSInteger)index viewModel:(id)viewModel {
    self.unhighlightedViewModel = viewModel;
}

@end
