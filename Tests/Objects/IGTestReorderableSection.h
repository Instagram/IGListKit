/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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

