/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGTestDelegateDataSource.h"

#import <IGListKit/IGListAdapter.h>

#import "IGTestDelegateController.h"
#import "IGTestObject.h"

@implementation IGTestDelegateDataSource

- (NSArray *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    IGTestDelegateController *sectionController = [[IGTestDelegateController alloc] init];
    sectionController.cellConfigureBlock = self.cellConfigureBlock;
    return sectionController;
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
