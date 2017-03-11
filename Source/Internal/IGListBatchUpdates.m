/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListBatchUpdates.h"

@implementation IGListBatchUpdates

- (instancetype)init {
    if (self = [super init]) {
        _sectionReloads = [NSMutableIndexSet new];
        _itemInserts = [NSMutableSet new];
        _itemMoves = [NSMutableSet new];
        _itemReloads = [NSMutableSet new];
        _itemDeletes = [NSMutableSet new];
        _itemUpdateBlocks = [NSMutableArray new];
        _completionBlocks = [NSMutableArray new];
    }
    return self;
}

- (BOOL)hasChanges {
    return [self.itemUpdateBlocks count] > 0
    || [self.sectionReloads count] > 0
    || [self.itemInserts count] > 0
    || [self.itemMoves count] > 0
    || [self.itemReloads count] > 0
    || [self.itemDeletes count] > 0;
}

@end
