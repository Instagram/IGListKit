/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#ifndef IGListArrayUtilsInternal_h
#define IGListArrayUtilsInternal_h

static NSArray *objectsWithDuplicateIdentifiersRemoved(NSArray<id<IGListDiffable>> *objects) {
    if (objects == nil) {
        return nil;
    }
    
    NSMutableSet *identifiers = [NSMutableSet new];
    NSMutableArray *uniqueObjects = [NSMutableArray new];
    for (id<IGListDiffable> object in objects) {
        id diffIdentifier = [object diffIdentifier];
        if (diffIdentifier != nil
            && ![identifiers containsObject:diffIdentifier]) {
            [identifiers addObject:diffIdentifier];
            [uniqueObjects addObject:object];
        } else {
            IGLKLog(@"WARNING: Object %@ already appeared in objects array", object);
        }
    }
    return uniqueObjects;
}

#endif /* IGListArrayUtilsInternal_h */
