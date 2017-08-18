/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListSectionControllerInternal.h"

#import <IGListKit/IGListMacros.h>
#import <IGListKit/IGListAssert.h>

static NSString * const kIGListSectionControllerThreadKey = @"kIGListSectionControllerThreadKey";

@interface IGListSectionControllerThreadContext : NSObject
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) id<IGListCollectionContext> collectionContext;
@end
@implementation IGListSectionControllerThreadContext
@end

static NSMutableArray<IGListSectionControllerThreadContext *> *threadContextStack(void) {
    IGAssertMainThread();
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSMutableArray *stack = threadDictionary[kIGListSectionControllerThreadKey];
    if (stack == nil) {
        stack = [NSMutableArray new];
        threadDictionary[kIGListSectionControllerThreadKey] = stack;
    }
    return stack;
}

void IGListSectionControllerPushThread(UIViewController *viewController, id<IGListCollectionContext> collectionContext) {
    IGListSectionControllerThreadContext *context = [IGListSectionControllerThreadContext new];
    context.viewController = viewController;
    context.collectionContext = collectionContext;

    [threadContextStack() addObject:context];
}

void IGListSectionControllerPopThread(void) {
    NSMutableArray *stack = threadContextStack();
    IGAssert(stack.count > 0, @"IGListSectionController thread stack is empty");
    [stack removeLastObject];
}

@implementation IGListSectionController

- (instancetype)init {
    if (self = [super init]) {
        IGListSectionControllerThreadContext *context = [threadContextStack() lastObject];
        _viewController = context.viewController;
        _collectionContext = context.collectionContext;

        if (_collectionContext == nil) {
            IGLKLog(@"Warning: Creating %@ outside of -[IGListAdapterDataSource listAdapter:sectionControllerForObject:]. Collection context and view controller will be set later.",
                    NSStringFromClass([self class]));
        }

        _minimumInteritemSpacing = 0.0;
        _minimumLineSpacing = 0.0;
        _inset = UIEdgeInsetsZero;
        _section = NSNotFound;
    }
    return self;
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeZero;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    IGFailAssert(@"Section controller %@ must override %s:", self, __PRETTY_FUNCTION__);
    return nil;
}

- (void)didUpdateToObject:(id)object {}

- (void)didSelectItemAtIndex:(NSInteger)index {}

- (void)didDeselectItemAtIndex:(NSInteger)index {}

@end
