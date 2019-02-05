/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListAdapter.h>
#import <IGListKit/IGListCollectionViewDelegateLayout.h>

@interface IGListAdapter (UICollectionView)
<
UICollectionViewDataSource,
IGListCollectionViewDelegateLayout
>
@end
