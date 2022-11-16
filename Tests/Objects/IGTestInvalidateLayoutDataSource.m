/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGTestInvalidateLayoutDataSource.h"

#import "IGTestInvalidateLayoutObject.h"
#import "IGTestInvalidateLayoutSectionController.h"

@implementation IGTestInvalidateLayoutDataSource

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [IGTestInvalidateLayoutSectionController new];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter { return nil; }

@end
