/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
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
