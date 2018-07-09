/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListSectionController.h>


@interface IGListTestSection : IGListSectionController

@property (nonatomic, assign) NSInteger items;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL wasSelected;
@property (nonatomic, assign) BOOL wasDeselected;
@property (nonatomic, assign) BOOL wasHighlighted;
@property (nonatomic, assign) BOOL wasUnhighlighted;

@end
