/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListTestAdapterDataSource.h"

#import <IGListKit/IGListAdapter.h>

#import "IGListTestSection.h"

@implementation IGListTestAdapterDataSource

- (NSArray *)itemsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListItemController <IGListItemType> *)listAdapter:(IGListAdapter *)listAdapter itemControllerForItem:(id)object {
    IGListTestSection *list = [[IGListTestSection alloc] init];
    return list;
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return self.backgroundView;
}

@end
