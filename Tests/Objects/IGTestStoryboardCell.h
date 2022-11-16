/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@interface IGTestStoryboardCell : UICollectionViewCell

@property (nonatomic, weak) id delegate;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
