/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestSingleNibItemDataSource.h"

#import <IGListKit/IGListSingleSectionController.h>

#import "IGTestCell.h"

@implementation IGTestSingleNibItemDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object
{
    void (^configureBlock)(id, __kindof UICollectionViewCell *) = ^(IGTestObject *item, IGTestCell *cell) {
        cell.label.text = [item.value description];
    };
    CGSize (^sizeBlock)(id, id<IGListCollectionContext>) = ^CGSize(IGTestObject *item, id<IGListCollectionContext> collectionContext) {
        return CGSizeMake([collectionContext containerSize].width, 44);
    };
    return [[IGListSingleSectionController alloc] initWithNibName:@"IGTestNibCell"
                                                           bundle:[NSBundle bundleForClass:self.class]
                                                   configureBlock:configureBlock
                                                        sizeBlock:sizeBlock];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
