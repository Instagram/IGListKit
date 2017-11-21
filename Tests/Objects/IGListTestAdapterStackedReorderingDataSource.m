/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListTestAdapterStackedReorderingDataSource.h"

#import <IGListKit/IGListAdapter.h>

#import "IGTestReorderableSection.h"

@implementation IGListTestAdapterStackedReorderingDataSource

- (instancetype)initWithSectionControllers:(NSArray<IGListSectionController *> *)sections {
    if (self = [super init]) {
        _sectionControllers = sections;
    }
    return self;
}

- (NSArray *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [[IGListStackedSectionController alloc] initWithSectionControllers:self.sectionControllers];
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

