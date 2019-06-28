/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListAdapterDataSource.h>

#import "IGListTestCase.h"

@class IGTestDiffingObject;

@interface IGTestDiffingDataSource : NSObject <IGListTestCaseDataSource>

@property (nonatomic, strong) NSArray<IGTestDiffingObject *> *objects;

@end
