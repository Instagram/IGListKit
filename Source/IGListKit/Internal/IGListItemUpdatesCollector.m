/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListItemUpdatesCollector.h"

@implementation IGListItemUpdatesCollector

- (instancetype)init {
    if (self = [super init]) {
        _sectionReloads = [NSMutableIndexSet new];
        _itemInserts = [NSMutableArray new];
        _itemMoves = [NSMutableArray new];
        _itemDeletes = [NSMutableArray new];
        _itemReloads = [NSMutableArray new];
    }
    return self;
}

- (BOOL)hasChanges {
    return [self.sectionReloads count] > 0
    || [self.itemInserts count] > 0
    || [self.itemMoves count] > 0
    || [self.itemReloads count] > 0
    || [self.itemDeletes count] > 0;
}

@end
