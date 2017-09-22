// 
// Copyright (c) 2016-present, Facebook, Inc.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//
// GitHub:
// https://github.com/Instagram/IGListKit
// 
// Documentation:
// https://instagram.github.io/IGListKit/
//

#import <UIKit/UIKit.h>

#import <IGListKit/IGListIndexPathResult.h>
#import <IGListKit/IGListIndexSetResult.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (BatchUpdates)

- (void)ig_performUpdateWithIndexSetResult:(nullable IGListIndexSetResult *)indexSetResult
                           indexPathResult:(nullable IGListIndexPathResult *)indexPathResult
                                    update:(nullable void (^)(void))update
                                completion:(nullable void (^)(BOOL))completion;

@end

NS_ASSUME_NONNULL_END
