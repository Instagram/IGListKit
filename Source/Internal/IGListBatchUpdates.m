/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListBatchUpdates.h"

@implementation IGListBatchUpdates

- (instancetype)init {
    if (self = [super init]) {
        _sectionReloads = [NSMutableIndexSet new];
        _itemInserts = [NSMutableArray new];
        _itemMoves = [NSMutableArray new];
        _itemDeletes = [NSMutableArray new];
        _itemReloads = [NSMutableArray new];
        _itemUpdateBlocks = [NSMutableArray new];
        _itemCompletionBlocks = [NSMutableArray new];
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
