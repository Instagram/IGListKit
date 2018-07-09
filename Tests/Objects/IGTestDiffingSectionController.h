/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <IGListKit/IGListKit.h>

@interface IGTestDiffingSectionController : IGListBindingSectionController <IGListBindingSectionControllerDataSource, IGListBindingSectionControllerSelectionDelegate>

@property (nonatomic, strong) id selectedViewModel;
@property (nonatomic, strong) id deselectedViewModel;
@property (nonatomic, strong) id highlightedViewModel;
@property (nonatomic, strong) id unhighlightedViewModel;

@end
