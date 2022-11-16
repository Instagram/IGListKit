/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListSectionController.h>


@interface IGListTestHorizontalSection : IGListSectionController

@property (nonatomic, assign) NSInteger items;

@property (nonatomic, assign) BOOL wasSelected;

@end
