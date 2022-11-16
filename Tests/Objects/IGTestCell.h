/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListBindable.h>

@interface IGTestCell : UICollectionViewCell <IGListBindable>

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) IBOutlet UILabel *label;

@end
