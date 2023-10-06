/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListArrayUtilsInternal.h"

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListBatchUpdateData.h"
#import "IGListDiffable.h"
#else
#import <IGListDiffKit/IGListBatchUpdateData.h>
#import <IGListDiffKit/IGListDiffable.h>
#endif

NSArray *objectsWithDuplicateIdentifiersRemoved(NSArray<id<IGListDiffable>> *objects) {
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
            IGLKLog(@"Duplicate identifier %@ for object %@ with object %@", diffIdentifier, object, previousObject);
        }
    }
    return uniqueObjects;
}
