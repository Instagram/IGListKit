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
#import <IGListKit/IGListDiffable.h>

@interface IGTestReorderableSectionObject : NSObject <IGListDiffable>

@property (nonatomic, strong) NSArray *objects;

+ (instancetype)sectionWithObjects:(NSArray *)objects;

@end

@interface IGTestReorderableSection : IGListSectionController

@property (nonatomic, strong) IGTestReorderableSectionObject *sectionObject;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL isReorderable;

- (instancetype)initWithSectionObject:(IGTestReorderableSectionObject *)sectionObject;

@end

