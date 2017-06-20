/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestSingleStoryboardItemDataSource.h"

#import <IGListKit/IGListSingleSectionController.h>

#import "IGTestStoryboardCell.h"

@implementation IGTestSingleStoryboardItemDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object
{
    void (^configureBlock)(id, __kindof UICollectionViewCell *) = ^(IGTestObject *item, IGTestStoryboardCell *cell) {
        cell.label.text = [item.value description];
    };
    CGSize (^sizeBlock)(id, id<IGListCollectionContext>) = ^CGSize(IGTestObject *item, id<IGListCollectionContext> collectionContext) {
        return CGSizeMake([collectionContext containerSize].width, 44);
    };
    return [[IGListSingleSectionController alloc] initWithStoryboardCellIdentifier:@"IGTestStoryboardCell"
                                                                    configureBlock:configureBlock
                                                                         sizeBlock:sizeBlock];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
