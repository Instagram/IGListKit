/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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
@property (nonatomic, assign) BOOL wasDisplayed;
@property (nonatomic, assign) BOOL requestedContextMenu;

@end
