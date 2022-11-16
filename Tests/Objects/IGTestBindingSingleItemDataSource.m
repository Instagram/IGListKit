/**
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestBindingSingleItemDataSource.h"

#import <IGListKit/IGListBindingSingleSectionController.h>

#import "IGTestCell.h"

@interface IGTestBindingSingleSectionController : IGListBindingSingleSectionController

@end

@implementation IGTestBindingSingleSectionController

- (Class)cellClass {
    return IGTestCell.class;
}

- (void)configureCell:(IGTestCell *)cell withViewModel:(IGTestObject *)viewModel {
    cell.label.text = [viewModel.value description];
}

- (CGSize)sizeForViewModel:(IGTestObject *)viewModel {
     return CGSizeMake([self.collectionContext containerSize].width, 44);
}

- (void)didSelectItemWithCell:(IGTestCell *)cell {
    cell.label.text = @"did-select";
}

- (void)didDeselectItemWithCell:(IGTestCell *)cell {
    cell.label.text = @"did-deselect";
}

- (void)didHighlightItemWithCell:(IGTestCell *)cell {
    cell.label.text = @"did-highlight";
}

- (void)didUnhighlightItemWithCell:(IGTestCell *)cell {
    cell.label.text = @"did-unhighlight";
}

@end


@implementation IGTestBindingSingleItemDataSource

- (NSArray *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [IGTestBindingSingleSectionController new];
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
