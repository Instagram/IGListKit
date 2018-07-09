/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListTestAdapterStoryboardDataSource.h"

#import <IGListKit/IGListAdapter.h>

#import "IGListTestStoryboardSection.h"

@implementation IGListTestAdapterStoryboardDataSource

- (NSArray *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    IGListTestStoryboardSection *list = [[IGListTestStoryboardSection alloc] init];
    return list;
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return self.backgroundView;
}

@end
