/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGTestDiffingDataSource.h"

#import "IGTestDiffingObject.h"
#import "IGTestDiffingSectionController.h"

@implementation IGTestDiffingDataSource

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [IGTestDiffingSectionController new];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter { return nil; }

@end
