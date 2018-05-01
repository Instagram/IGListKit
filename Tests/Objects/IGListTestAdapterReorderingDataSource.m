/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListTestAdapterReorderingDataSource.h"

#import <IGListKit/IGListAdapter.h>

#import "IGTestReorderableSection.h"

@implementation IGListTestAdapterReorderingDataSource

- (NSArray *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [IGTestReorderableSection new];
}

- (nullable UIView *)emptyViewForListAdapter:(nonnull IGListAdapter *)listAdapter {
    return self.backgroundView;
}

#pragma mark - IGListAdapterMoveDelegate

- (void)listAdapter:(IGListAdapter *)listAdapter
         moveObject:(id)object
               from:(NSArray *)previousObjects
                 to:(NSArray *)objects {
    self.objects = objects;
}

@end
