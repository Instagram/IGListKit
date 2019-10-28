/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListDebugger.h"

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

+ (void)clear {
    [livingAdaptersTable removeAllObjects];
}

+ (NSString *)dump {
    return [[self adapterDescriptions] componentsJoinedByString:@"\n"];
}

@end
