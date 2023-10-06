/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@protocol IGListDiffable;

/// Returns a copy of the provided array, with all duplicates 
/// of objects with the same `diffIdentifier` value removed.
/// - Parameter objects: The list of diffable objects to filter.
NSArray *objectsWithDuplicateIdentifiersRemoved(NSArray<id<IGListDiffable>> *objects);
