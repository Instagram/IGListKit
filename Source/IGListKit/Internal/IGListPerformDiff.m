/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListPerformDiff.h"

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListDiff.h"
#else
#import <IGListDiffKit/IGListDiff.h>
#endif

#import "IGListTransitionData.h"
#import "IGListViewVisibilityTracker.h"

#pragma mark - Regular (not adaptive)

static void _regularPerformDiffWithData(IGListTransitionData *_Nullable data,
                                        BOOL allowsBackground,
                                        IGListDiffExecutorCompletion completion) {
    if (allowsBackground) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            IGListIndexSetResult *result = IGListDiff(data.fromObjects, data.toObjects, IGListDiffEquality);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result, allowsBackground);
            });
        });
    } else {
        IGListIndexSetResult *result = IGListDiff(data.fromObjects, data.toObjects, IGListDiffEquality);
        completion(result, allowsBackground);
    }
}

#pragma mark - Adaptive

static dispatch_queue_t _queueForData(IGListTransitionData *data, 
                                      UIView *view,
                                      BOOL allowsBackground,
                                      IGListAdaptiveDiffingExperimentConfig adaptiveConfig) {
    if (!allowsBackground) {
        return dispatch_get_main_queue();
    }
    
    if (adaptiveConfig.lowerPriorityWhenViewNotVisible) {
        IGListViewVisibilityTracker *const tracker = IGListViewVisibilityTrackerAttachedOnView(view);
        if (tracker && tracker.state == IGListViewVisibilityStateNotVisible) {
            return dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);
        }
    }
    
    // If we don't have a lot of items, the dispatching back and forth can add unnecessary delay.
    if ((NSInteger)data.fromObjects.count < adaptiveConfig.maxItemCountToRunOnMain
        && (NSInteger)data.toObjects.count < adaptiveConfig.maxItemCountToRunOnMain) {
        return dispatch_get_main_queue();
    }

    const intptr_t qos = adaptiveConfig.higherQOSEnabled ? QOS_CLASS_USER_INTERACTIVE : QOS_CLASS_USER_INITIATED;
    return dispatch_get_global_queue(qos, 0);
}

static void _adaptivePerformDiffWithData(IGListTransitionData *_Nullable data,
                                         UIView *view,
                                         BOOL allowsBackground,
                                         IGListAdaptiveDiffingExperimentConfig adaptiveConfig,
                                         IGListDiffExecutorCompletion completion) {
    const dispatch_queue_t queue = _queueForData(data, view, allowsBackground, adaptiveConfig);

    if (queue == dispatch_get_main_queue() && [NSThread isMainThread]) {
        IGListIndexSetResult *const result = IGListDiff(data.fromObjects, data.toObjects, IGListDiffEquality);
        completion(result, NO);
    } else {
        dispatch_async(queue, ^{
            IGListIndexSetResult *const result = IGListDiff(data.fromObjects, data.toObjects, IGListDiffEquality);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result, YES);
            });
        });
    }
}

#pragma mark - Public

void IGListPerformDiffWithData(IGListTransitionData *_Nullable data,
                               UIView *view,
                               BOOL allowsBackground,
                               IGListAdaptiveDiffingExperimentConfig adaptiveConfig,
                               IGListDiffExecutorCompletion completion) {
    if (!completion) {
        return;
    }
    
    if (adaptiveConfig.enabled) {
        _adaptivePerformDiffWithData(data, view, allowsBackground, adaptiveConfig, completion);
    } else {
        // Just to be safe, lets keep the original code path intact while adaptive diffing is still an experiment.
        _regularPerformDiffWithData(data, allowsBackground, completion);
    }
}
