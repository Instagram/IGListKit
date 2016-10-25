/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

/**
 The IGListDiffable protocol provides the base methods needed to compare the identity and equality of two objects using
 one of the IGListDiff functions.
 */
@protocol IGListDiffable

/**
 Returns a key that uniquely identifies the object.

 @return A key that can be used to uniquely identify the object.

 @discussion Two objects may share the same identifier, but are not equal. A common pattern is to import IGListCommon.h
 and use the NSObject category for automatic conformance. However this means that objects will be identified on their
 pointer value so finding updates becomes impossible.

 @warning This value should never be mutated.
 */
- (nonnull id<NSObject>)diffIdentifier;

/**
 Returns a Boolean value that indicates whether the receiver and a given object are equal.

 @param object The object to be compared to the receiver.

 @return YES if the receiver and object are equal, otherwise NO.

 @warning If you implement a custom isEqual: you must also implement -hash. You can just use the -diffIdentifier value
 for your hash function:

 - (NSUInteger)hash {
 return [[self diffIdentifier] hash];
 }
 */
- (BOOL)isEqual:(nullable id<IGListDiffable>)object;

@end
