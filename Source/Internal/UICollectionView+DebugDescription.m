/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "UICollectionView+DebugDescription.h"

#import <IGListKit/IGListMacros.h>

@implementation UICollectionView (DebugDescription)

- (NSArray<NSString *> *)debugDescriptionLines {
    NSMutableArray *debug = [NSMutableArray new];
#if IGLK_DEBUG_DESCRIPTION_ENABLED
    [debug addObject:[NSString stringWithFormat:@"Class: %@, instance: %p", NSStringFromClass(self.class), self]];
    [debug addObject:[NSString stringWithFormat:@"Data source: %@", self.dataSource]];
    [debug addObject:[NSString stringWithFormat:@"Delegate: %@", self.delegate]];
    [debug addObject:[NSString stringWithFormat:@"Layout: %@", self.collectionViewLayout]];
    [debug addObject:[NSString stringWithFormat:@"Frame: %@, bounds: %@",
                      NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds)]];

    const NSInteger sections = [self numberOfSections];
    [debug addObject:[NSString stringWithFormat:@"Number of sections: %zi", sections]];

    for (NSInteger section = 0; section < sections; section++) {
        [debug addObject:[NSString stringWithFormat:@"  %zi items in section %zi",
                          [self numberOfItemsInSection:section], section]];
    }

    [debug addObject:@"Visible cell details:"];
    NSArray *visibleIndexPaths = [[self indexPathsForVisibleItems] sortedArrayUsingSelector:@selector(compare:)];
    for (NSIndexPath *path in visibleIndexPaths) {
        [debug addObject:[NSString stringWithFormat:@"  Visible cell at section %zi, item %zi:",
         path.section, path.item]];
        [debug addObject:[NSString stringWithFormat:@"  %@", [[self cellForItemAtIndexPath:path] description] ?: @""]];
    }
#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED
    return debug;
}

@end
