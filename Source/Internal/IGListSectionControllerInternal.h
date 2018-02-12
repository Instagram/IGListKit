/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListSectionController.h"

FOUNDATION_EXTERN void IGListSectionControllerPushThread(UIViewController *viewController, id<IGListCollectionContext> collectionContext);

FOUNDATION_EXTERN void IGListSectionControllerPopThread(void);

@interface IGListSectionController()

@property (nonatomic, weak, readwrite) id<IGListCollectionContext> collectionContext;

@property (nonatomic, weak, readwrite) UIViewController *viewController;

@property (nonatomic, assign, readwrite) NSInteger section;

@property (nonatomic, assign, readwrite) BOOL isFirstSection;

@property (nonatomic, assign, readwrite) BOOL isLastSection;

/*
 Provides a way for specialized section controllers (like the stacked section controller) to reject invalid moves
 */
- (BOOL)canMoveItemAtIndex:(NSInteger)sourceItemIndex toIndex:(NSInteger)destinationItemIndex;

@end
