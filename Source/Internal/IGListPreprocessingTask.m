/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListPreprocessingTask.h"

#import "IGListAssert.h"
#import "IGListPreprocessingContext.h"
#import "IGListPreprocessingDelegate.h"
#import "IGListSectionController.h"
#import "IGListSectionMap.h"

@implementation IGListPreprocessingTask {
    NSMapTable<IGListPreprocessingContext *, id<IGListPreprocessingDelegate>> *_contextToDelegateMap;
    IGListSectionMap *_sectionMap;
    dispatch_group_t _group;
    dispatch_block_t _completion;
    BOOL _finished;
    BOOL _started;
    CGSize _containerSize;
}

- (instancetype)initWithSectionMap:(IGListSectionMap *)sectionMap
                     containerSize:(CGSize)containerSize {
    if (self = [super init]) {
        _containerSize = containerSize;
        NSPointerFunctionsOptions mapTableOptions = (NSMapTableStrongMemory | NSMapTableObjectPointerPersonality);
        _contextToDelegateMap = [NSMapTable mapTableWithKeyOptions:mapTableOptions valueOptions:mapTableOptions];
        _sectionMap = [sectionMap copy];
        _group = dispatch_group_create();
    }
    return self;
}

- (void)startWithCompletion:(dispatch_block_t)completionBlock {
    IGAssertMainThread();

    // Ensure this is only ever called once.
    if (_started) {
        IGAssert(NO, @"Attempt to call %@ more than once on the same object. %@ is one-shot!", NSStringFromSelector(_cmd), NSStringFromClass(self.class));
        return;
    }
    _started = YES;
    _completion = completionBlock;

    dispatch_queue_t queue = dispatch_queue_create("com.iglistkit.IGListPreprocessingTask", DISPATCH_QUEUE_CONCURRENT);

    dispatch_group_t group = _group;
    NSMapTable *contextToDelegateMap = _contextToDelegateMap;
    CGSize containerSize = _containerSize;
    [_sectionMap enumerateUsingBlock:^(id  _Nonnull object, IGListSectionController<IGListSectionType> * _Nonnull sectionController, NSInteger section, BOOL * _Nonnull stop) {
        id<IGListPreprocessingDelegate> delegate = sectionController.preprocessingDelegate;
        if (delegate == nil) {
            return;
        }

        // Create a context and associate it with this delegate.
        IGListPreprocessingContext *context = [[IGListPreprocessingContext alloc] initWithObject:object containerSize:containerSize sectionIndex:section dispatchGroup:group];
        [contextToDelegateMap setObject:delegate forKey:context];

        // Schedule the delegate's work – the context will dispatch_group_leave when it
        // the user calls -completePreprocessing.
        dispatch_group_enter(group);
        dispatch_async(queue, ^{
            [delegate preprocessWithContext:context];
        });
    }];

    // When the work is all done, call -finishOnMainThread on main.
    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
        [self finishOnMainThread];
    });
}

- (void)waitUntilCompleted {
    IGAssertMainThread();
    if (!_started) {
        IGAssert(NO, @"Attempt to wait on preprocessing that never started: %@", self);
        return;
    }

    dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
    [self finishOnMainThread];
}

#pragma mark - Private

- (void)finishOnMainThread {
    IGAssertMainThread();

    // Handle case where we ran completion before e.g.
    // -waitForPreprocessingToFinish was called before
    // completion was run naturally.
    if (_finished) {
        return;
    }
    _finished = YES;

    // Inform all the delegates about preprocessing being done.
    for (IGListPreprocessingContext *context in _contextToDelegateMap) {
        id<IGListPreprocessingDelegate> delegate = [_contextToDelegateMap objectForKey:context];
        [delegate preprocessingDidFinishWithContext:context];
    }
    
    // Call and release our completion block.
    if (_completion) {
        _completion();
        _completion = nil;
    }
}

@end
