/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListBatchUpdateData+DebugDescription.h"

@implementation IGListBatchUpdateData (DebugDescription)

- (NSArray<NSString *> *)debugDescriptionLines {
    NSMutableArray *debug = [NSMutableArray new];
#if IGLK_DEBUG_DESCRIPTION_ENABLED
    [debug addObject:[NSString stringWithFormat:@"Insert sections: %@", self.insertSections]];
    [debug addObject:[NSString stringWithFormat:@"Delete sections: %@", self.deleteSections]];

    for (IGListMoveIndex *move in self.moveSections) {
        [debug addObject:[NSString stringWithFormat:@"Move from section %zi to %zi", move.from, move.to]];
    }

    for (NSIndexPath *path in self.deleteIndexPaths) {
        [debug addObject:[NSString stringWithFormat:@"Delete section %zi item %zi", path.section, path.item]];
    }

    for (NSIndexPath *path in self.insertIndexPaths) {
        [debug addObject:[NSString stringWithFormat:@"Insert section %zi item %zi", path.section, path.item]];
    }

    for (IGListMoveIndexPath *move in self.moveIndexPaths) {
        [debug addObject:[NSString stringWithFormat:@"Move from section %zi item %zi to section %zi item %zi",
         move.from.section, move.from.item, move.to.section, move.to.item]];
    }
#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED
    return debug;
}

@end
