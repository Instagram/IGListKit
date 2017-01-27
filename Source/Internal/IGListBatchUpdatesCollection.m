//
//  IGListBatchUpdatesCollection.m
//  IGListKit
//
//  Created by Ryan Nystrom on 1/26/17.
//  Copyright © 2017 Instagram. All rights reserved.
//

#import "IGListBatchUpdatesCollection.h"

@implementation IGListBatchUpdatesCollection

- (instancetype)init {
    if (self = [super init]) {
        _sectionReloads = [NSMutableIndexSet new];
        _itemInserts = [NSMutableSet new];
        _itemMoves = [NSMutableSet new];
        _itemReloads = [NSMutableSet new];
        _itemDeletes = [NSMutableSet new];
        _completionBlocks = [NSMutableArray new];
    }
    return self;
}

//- (BOOL)hasChanges {
//    return self.sectionReloads.count > 0
//    || self.itemInserts.count > 0
//    || self.itemMoves.count > 0
//    || self.itemReloads.count > 0
//    || self.itemDeletes.count > 0
//    || self.completionBlocks.count > 0;
//}

@end
