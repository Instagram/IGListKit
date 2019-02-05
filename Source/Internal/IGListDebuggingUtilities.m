/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListDebuggingUtilities.h"

NSString *IGListDebugBOOL(BOOL b) {
    return b ? @"Yes" : @"No";
}

NSArray<NSString *> *IGListDebugIndentedLines(NSArray<NSString *> *lines) {
    NSMutableArray *newLines = [NSMutableArray new];
    for (NSString *line in lines) {
        [newLines addObject:[NSString stringWithFormat:@"  %@", line]];
    }
    return newLines;
}
