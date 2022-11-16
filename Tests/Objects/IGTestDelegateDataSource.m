/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGTestDelegateDataSource.h"

#import <IGListKit/IGListAdapter.h>

#import "IGTestDelegateController.h"
#import "IGTestObject.h"

NSObject *const kIGTestDelegateDataSourceSkipObject = @"kIGTestDelegateDataSourceSkipObject";

@implementation IGTestDelegateDataSource

- (NSArray *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.objects;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    if ([object isEqual:kIGTestDelegateDataSourceSkipObject]) {
        return nil;
    }
    IGTestDelegateController *sectionController = [[IGTestDelegateController alloc] init];
    sectionController.cellConfigureBlock = self.cellConfigureBlock;
    return sectionController;
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
