/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListTestAdapterGridLayoutDataSource.h"

#import <IGListKit/IGListAdapter.h>

#import "IGListTestGridLayoutSection.h"

@implementation IGListTestAdapterGridLayoutDataSource

- (NSArray *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController <IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    IGListTestGridLayoutSection *list = [[IGListTestGridLayoutSection alloc] init];
    return list;
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return self.backgroundView;
}

@end
