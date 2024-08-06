//
//  IGListDiffExecutor.m
//  IGActionRowViewProvider
//
//  Created by Maxime Ollivier on 8/1/24.
//

#import "IGListPerformDiff.h"

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListDiff.h"
#else
#import <IGListDiffKit/IGListDiff.h>
#endif

#import "IGListTransitionData.h"

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

static dispatch_queue_t _queueForData(IGListTransitionData *data, BOOL allowsBackground, IGListAdaptiveDiffingExperimentConfig adaptiveConfig) {
    if (!allowsBackground) {
        return dispatch_get_main_queue();
    }

    return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
}

static void _adaptivePerformDiffWithData(IGListTransitionData *_Nullable data,
                                         BOOL allowsBackground,
                                         IGListAdaptiveDiffingExperimentConfig adaptiveConfig,
                                         IGListDiffExecutorCompletion completion) {
    const dispatch_queue_t queue = _queueForData(data, allowsBackground, adaptiveConfig);

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
                               BOOL allowsBackground,
                               IGListAdaptiveDiffingExperimentConfig adaptiveConfig,
                               IGListDiffExecutorCompletion completion) {
    if (!completion) {
        return;
    }
    
    if (adaptiveConfig.enabled) {
        _adaptivePerformDiffWithData(data, allowsBackground, adaptiveConfig, completion);
    } else {
        // Just to be safe, lets keep the original code path intact while adaptive diffing is still an experiment.
        _regularPerformDiffWithData(data, allowsBackground, completion);
    }
}
