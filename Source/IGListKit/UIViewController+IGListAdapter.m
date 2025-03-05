/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UIViewController+IGListAdapter.h"

#import <objc/runtime.h>

@implementation UIViewController (IGListAdapter)

- (NSArray<IGListAdapter *> *)associatedListAdapters {
    return [[self _associatedListAdaptersTable] allObjects];
}

- (void)associateListAdapter:(IGListAdapter *)adapter {
    NSHashTable *const table = [self _associatedListAdaptersTable];
    [table addObject:adapter];
}

- (NSHashTable *)_associatedListAdaptersTable {
    NSHashTable *table = objc_getAssociatedObject(self, @selector(_associatedListAdaptersTable));
    if (table) {
        return table;
    }

    table = [NSHashTable weakObjectsHashTable];
    objc_setAssociatedObject(self, @selector(_associatedListAdaptersTable), table, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return table;
}

@end
