/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListKit.h>

@interface IGTestStoryboardSupplementarySource : NSObject <IGListSupplementaryViewSource>

@property (nonatomic, strong, readwrite) NSArray<NSString *> *supportedElementKinds;

@property (nonatomic, weak) id<IGListCollectionContext> collectionContext;

@property (nonatomic, weak) IGListSectionController *sectionController;

@end
