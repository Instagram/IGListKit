/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@class PersonModel;

@interface PersonCell : UICollectionViewCell
@property (nonatomic, copy) PersonModel *person;
@end
