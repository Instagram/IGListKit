/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListDiffable.h>

/**
 This category adds diffing comparisons similar to adding the object into an `NSSet`, 
 where the object's `-isEqual:` method drives the uniqueness of the object.

 For instance, an `NSString`'s `-isEqual:` will compare the value of the strings. 
 So if you were to diff `@"cat"` and `@"cat"` each object would have the same diff identifier.

 However objects that don't implement a custom `-isEqual:` (e.g. the `NSObject` base class), the diff will default to simple
 pointer comparisons to establish uniqueness.
 */
@interface NSObject (IGListDiffable) <IGListDiffable>

@end
