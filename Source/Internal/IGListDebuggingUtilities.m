/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
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
