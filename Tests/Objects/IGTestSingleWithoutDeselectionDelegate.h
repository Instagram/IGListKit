/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


#import <Foundation/Foundation.h>

#import <IGListKit/IGListKit.h>

@interface IGTestSingleWithoutDeselectionDelegate : NSObject <IGListSingleSectionControllerDelegate>

@property (nonatomic, assign) BOOL selected;

@end
