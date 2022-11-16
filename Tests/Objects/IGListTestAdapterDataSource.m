/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListTestAdapterDataSource.h"

#import <IGListKit/IGListAdapter.h>

#import "IGListTestContainerSizeSection.h"
#import "IGListTestSection.h"

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
