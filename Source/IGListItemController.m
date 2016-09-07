/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListItemControllerInternal.h"

#import <IGListKit/IGListMacros.h>
#import <IGListKit/IGListAssert.h>

static NSString * const kIGListItemControllerThreadKey = @"kIGListItemControllerThreadKey";

@interface IGListItemControllerThreadContext : NSObject
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) id<IGListCollectionContext> collectionContext;
@end
@implementation IGListItemControllerThreadContext
@end

static NSMutableArray<IGListItemControllerThreadContext *> *threadContextStack(void) {
    IGAssertMainThread();
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSMutableArray *stack = threadDictionary[kIGListItemControllerThreadKey];
    if (stack == nil) {
        stack = [NSMutableArray new];
        threadDictionary[kIGListItemControllerThreadKey] = stack;
    }
    return stack;
}

void IGListItemControllerPushThread(UIViewController *viewController, id<IGListCollectionContext> collectionContext) {
    IGListItemControllerThreadContext *context = [IGListItemControllerThreadContext new];
    context.viewController = viewController;
    context.collectionContext = collectionContext;

    [threadContextStack() addObject:context];
}

void IGListItemControllerPopThread(void) {
    NSMutableArray *stack = threadContextStack();
    IGAssert(stack.count > 0, @"IGListItemController thread stack is empty");
    [stack removeLastObject];
}

@implementation IGListItemController

- (instancetype)init {
    if (self = [super init]) {
        IGListItemControllerThreadContext *context = [threadContextStack() lastObject];
        _viewController = context.viewController;
        _collectionContext = context.collectionContext;

        if (_collectionContext == nil) {
            IGLKLog(@"Warning: Creating %@ outside of -[IGListAdapterDataSource listAdapter:itemControllerForItem:]. Collection context and view controller will be set later.",
                    NSStringFromClass([self class]));
        }

        _minimumInteritemSpacing = 0.0;
        _minimumLineSpacing = 0.0;
        _inset = UIEdgeInsetsZero;
    }
    return self;
}

@end
