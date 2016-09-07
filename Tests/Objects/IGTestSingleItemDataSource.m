/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestSingleItemDataSource.h"

#import <IGListKit/IGListSingleItemController.h>

#import "IGTestCell.h"

@implementation IGTestSingleItemDataSource

- (NSArray *)itemsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListItemController <IGListItemType> *)listAdapter:(IGListAdapter *)listAdapter itemControllerForItem:(id)object {
    void (^configureBlock)(id, __kindof UICollectionViewCell *) = ^(IGTestObject *item, IGTestCell *cell) {
        cell.label.text = [item.value description];
    };
    CGSize (^sizeBlock)(id<IGListCollectionContext>) = ^CGSize(id<IGListCollectionContext> collectionContext) {
        return CGSizeMake([collectionContext containerSize].width, 44);
    };
    return [[IGListSingleItemController alloc] initWithCellClass:IGTestCell.class
                                                  configureBlock:configureBlock
                                                       sizeBlock:sizeBlock];
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
