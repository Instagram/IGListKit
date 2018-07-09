/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <IGListKit/IGListAdapterDataSource.h>

#import "IGTestObject.h"
#import "IGListTestCase.h"

@interface IGTestStackedDataSource : NSObject <IGListTestCaseDataSource>

@property (nonatomic, strong) NSArray <IGTestObject *> *objects;

@end
