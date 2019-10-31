/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListSectionMap+DebugDescription.h"

#import "IGListBindingSectionController.h"

@implementation IGListSectionMap (DebugDescription)

- (NSArray<NSString *> *)debugDescriptionLines {
    NSMutableArray *debug = [NSMutableArray new];
#if IGLK_DEBUG_DESCRIPTION_ENABLED
    [self enumerateUsingBlock:^(id object, IGListSectionController *sectionController, NSInteger section, BOOL *stop) {
        if ([sectionController isKindOfClass:[IGListBindingSectionController class]]) {
            [debug addObject:[sectionController debugDescription]];
        } else {
            [debug addObject:[NSString stringWithFormat:@"Object and section controller at section: %li:", (long)section]];
            [debug addObject:[NSString stringWithFormat:@"  %@", object]];
            [debug addObject:[NSString stringWithFormat:@"  %@", sectionController]];
        }
    }];
#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED
    return debug;
}

@end
