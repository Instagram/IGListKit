/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGTestStackedDataSource.h"

#import <IGListKit/IGListStackedSectionController.h>

#import "IGListTestSection.h"

@implementation IGTestStackedDataSource

- (NSArray *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController <IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSNumber *num in [(IGTestObject *)object value]) {
        IGListTestSection *controller = [[IGListTestSection alloc] init];
        controller.items = [num integerValue];
        [controllers addObject:controller];
    }
    return [[IGListStackedSectionController alloc] initWithSectionControllers:controllers];
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
