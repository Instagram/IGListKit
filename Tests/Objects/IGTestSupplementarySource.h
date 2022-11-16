/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListKit.h>

@interface IGTestSupplementarySource : NSObject <IGListSupplementaryViewSource>

@property (nonatomic, assign) BOOL dequeueFromNib;

@property (nonatomic, assign) CGSize size;

@property (nonatomic, copy, readwrite) NSArray<NSString *> *supportedElementKinds;

@property (nonatomic, weak) id<IGListCollectionContext> collectionContext;

@property (nonatomic, weak) IGListSectionController *sectionController;

@end
