/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListAdapterDataSource.h>

#import "IGListTestCase.h"
#import "IGTestCell.h"

@class IGTestDelegateController;
@class IGTestObject;

extern NSObject *const kIGTestDelegateDataSourceSkipObject;
extern NSObject *const kIGTestDelegateDataSourceNoSectionControllerSubclass;

@interface IGTestDelegateDataSource : NSObject <IGListTestCaseDataSource>

@property (nonatomic, copy) NSArray <IGTestObject *> *objects;

@property (nonatomic, copy) void (^cellConfigureBlock)(IGTestDelegateController *);

@property (nonatomic, strong) IGTestCell *overrideCell;

@end
