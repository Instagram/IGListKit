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
#import "IGListTestContainerSizeSection.h"

@implementation IGListTestAdapterDataSource

- (NSArray *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    if ([object isKindOfClass:[NSNumber class]]) {
        if ([(NSNumber*)object  isEqual: @42]) {
            return [IGListTestContainerSizeSection new];
        }
        return [IGListTestSection new];
    }
    return nil;
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return self.backgroundView;
}

@end
