/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestAutoDataSource.h"

#import "IGTestAutoObject.h"
#import "IGTestAutoSectionController.h"

@implementation IGTestAutoDataSource

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController<IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [IGTestAutoSectionController new];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter { return nil; }

@end
