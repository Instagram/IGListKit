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

#import <IGListKit/IGListAssert.h>

static NSArray *objectsWithDuplicateIdentifiersRemoved(NSArray<id<IGListDiffable>> *objects) {
    if (objects == nil) {
        return nil;
    }
    
    NSMapTable *identifierMap = [NSMapTable strongToStrongObjectsMapTable];
    NSMutableArray *uniqueObjects = [NSMutableArray new];
    for (id<IGListDiffable> object in objects) {
        id diffIdentifier = [object diffIdentifier];
        id previousObject = [identifierMap objectForKey:diffIdentifier];
        if (diffIdentifier != nil
            && previousObject == nil) {
            [identifierMap setObject:object forKey:diffIdentifier];
            [uniqueObjects addObject:object];
        } else {
            IGFailAssert(@"Duplicate identifier %@ for object %@ with object %@", diffIdentifier, object, previousObject);
        }
    }
    return uniqueObjects;
}

#endif /* IGListArrayUtilsInternal_h */
