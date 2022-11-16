/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListAdapterDataSource.h>

#import "IGListTestCase.h"
#import "IGTestObject.h"

@interface IGTestSingleNibItemDataSource : NSObject <IGListTestCaseDataSource>

@property (nonatomic, copy) NSArray <IGTestObject *> *objects;

@end
