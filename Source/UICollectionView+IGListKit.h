/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@interface UICollectionView (IGListKit)
/**
 A method used to configure collectionView background and disable prefetching so cells are configured as they come on screen.
 
 */
- (void)ig_ConfigForIGListKit;
@end
