/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListBatchUpdateData+DebugDescription.h"

@implementation IGListBatchUpdateData (DebugDescription)

- (NSArray<NSString *> *)debugDescriptionLines {
    NSMutableArray *debug = [NSMutableArray new];
#if IGLK_DEBUG_DESCRIPTION_ENABLED
    [debug addObject:[NSString stringWithFormat:@"Insert sections: %@", self.insertSections]];
    [debug addObject:[NSString stringWithFormat:@"Delete sections: %@", self.deleteSections]];

    for (IGListMoveIndex *move in self.moveSections) {
        [debug addObject:[NSString stringWithFormat:@"Move from section %li to %li", (long)move.from, (long)move.to]];
    }

    for (NSIndexPath *path in self.deleteIndexPaths) {
        [debug addObject:[NSString stringWithFormat:@"Delete section %li item %li", (long)path.section, (long)path.item]];
    }

    for (NSIndexPath *path in self.insertIndexPaths) {
        [debug addObject:[NSString stringWithFormat:@"Insert section %li item %li", (long)path.section, (long)path.item]];
    }

    for (IGListMoveIndexPath *move in self.moveIndexPaths) {
        [debug addObject:[NSString stringWithFormat:@"Move from section %li item %li to section %li item %li",
                          (long)move.from.section, (long)move.from.item, (long)move.to.section, (long)move.to.item]];
    }
#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED
    return debug;
}

@end
