/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "NSIndexSet+PrettyDescription.h"

@implementation NSIndexSet (PrettyDescription)

- (NSString *)prettyDescription {
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexes addObject:@(idx)];
    }];
    return [indexes componentsJoinedByString:@", "];
}

@end
