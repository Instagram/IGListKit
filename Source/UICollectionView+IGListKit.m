/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "UICollectionView+IGListKit.h"

@implementation UICollectionView (IGListKit)

- (void)ig_ConfigForIGListKit {
    self.backgroundColor = [UIColor whiteColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        self.prefetchingEnabled = NO;    
    }
}

@end
