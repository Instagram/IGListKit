/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListDebugger.h"

#import "IGListDebuggingUtilities.h"
#import "IGListAdapter+DebugDescription.h"

@implementation IGListDebugger

static NSHashTable<IGListAdapter *> *livingAdaptersTable = nil;

+ (void)trackAdapter:(IGListAdapter *)adapter {
#if IGLK_DEBUG_DESCRIPTION_ENABLED
    if (livingAdaptersTable == nil) {
        livingAdaptersTable = [NSHashTable weakObjectsHashTable];
    }
    [livingAdaptersTable addObject:adapter];
#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED
}

+ (NSArray<NSString *> *)adapterDescriptions {
    NSMutableArray *descriptions = [NSMutableArray new];
    for (IGListAdapter *adapter in livingAdaptersTable) {
        [descriptions addObject:[adapter debugDescription]];
    }
    return descriptions;
}

+ (NSString *)dump {
    return [[self adapterDescriptions] componentsJoinedByString:@"\n"];
}

@end
