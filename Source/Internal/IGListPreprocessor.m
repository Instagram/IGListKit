/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListPreprocessor.h"

#import "IGListAssert.h"
#import "IGListPreprocessingContext.h"
#import "IGListPreprocessingDelegate.h"
#import "IGListSectionController.h"
#import "IGListSectionMap.h"

@implementation IGListPreprocessor {
    NSMapTable<IGListPreprocessingContext *, id<IGListPreprocessingDelegate>> *_contextToDelegateMap;
    IGListSectionMap *_sectionMap;
    dispatch_group_t _group;
    dispatch_block_t _completion;
    BOOL _ranCompletion;
    BOOL _scheduledPreprocessing;
    CGSize _containerSize;
}

- (instancetype)initWithSectionMap:(IGListSectionMap *)sectionMap
                     containerSize:(CGSize)containerSize
                        completion:(nonnull dispatch_block_t)completionBlock {
    if (self = [super init]) {
        _containerSize = containerSize;
        NSPointerFunctionsOptions mapTableOptions = (NSMapTableStrongMemory | NSMapTableObjectPointerPersonality);
        _contextToDelegateMap = [NSMapTable mapTableWithKeyOptions:mapTableOptions valueOptions:mapTableOptions];
        _sectionMap = [sectionMap copy];
        _group = dispatch_group_create();
        _completion = completionBlock;
    }
    return self;
}

- (void)schedulePreprocessing {
    IGAssertMainThread();

    // Ensure this is only ever called once.
    if (_scheduledPreprocessing) {
        IGAssert(NO, @"Attempt to call %@ more than once on the same object. %@ is one-shot!", NSStringFromSelector(_cmd), NSStringFromClass(self.class));
        return;
    }
    _scheduledPreprocessing = YES;

    dispatch_queue_t queue = dispatch_queue_create("com.iglistkit.iglistpreprocessor", DISPATCH_QUEUE_CONCURRENT);

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

    // When the work is all done, call -runCompletionIfNeeded on main.
    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
        [self runCompletionIfNeeded];
    });
}

- (void)waitForPreprocessingToFinish {
    IGAssertMainThread();

    dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
    [self runCompletionIfNeeded];
}

#pragma mark - Private

- (void)runCompletionIfNeeded {
    IGAssertMainThread();

    // Handle case where we ran completion before e.g.
    // -waitForPreprocessingToFinish was called before
    // completion was run naturally.
    if (_ranCompletion) {
        return;
    }
    _ranCompletion = YES;

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
