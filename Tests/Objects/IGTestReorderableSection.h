/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <IGListDiffKit/IGListDiffable.h>
#import <IGListKit/IGListSectionController.h>

@interface IGTestReorderableSectionObject : NSObject <IGListDiffable>

@property (nonatomic, copy) NSArray *objects;

+ (instancetype)sectionWithObjects:(NSArray *)objects;

@end

@interface IGTestReorderableSection : IGListSectionController

@property (nonatomic, strong) IGTestReorderableSectionObject *sectionObject;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL isReorderable;

- (instancetype)initWithSectionObject:(IGTestReorderableSectionObject *)sectionObject;

@end
