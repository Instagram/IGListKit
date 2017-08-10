/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
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
            [debug addObject:[NSString stringWithFormat:@"Object and section controller at section: %zi:", section]];
            [debug addObject:[NSString stringWithFormat:@"  %@", object]];
            [debug addObject:[NSString stringWithFormat:@"  %@", sectionController]];
        }
    }];
#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED
    return debug;
}

@end
