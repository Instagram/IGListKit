/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListUpdateCoalescer.h"

@implementation IGListUpdateCoalescer {
    BOOL _hasQueuedUpdate;

    // Adaptive
    NSDate *_lastUpdateStartDate;
    NSTimeInterval _coalescenceInterval;
}

- (void)queueUpdate {
    if (_hasQueuedUpdate) {
        return;
    }
    
    // dispatch_async to give the main queue time to collect more batch updates so that a minimum amount of work
    // (diffing, etc) is done on main. dispatch_async does not garauntee a full runloop turn will pass though.
    // see -performUpdateWithCollectionViewBlock:animated:sectionDataBlock:applySectionDataBlock:completion: for more
    // details on how coalescence is done.
    
    if (self.adaptiveCoalescingExperimentConfig.enabled) {
        [self _adaptiveDispatchUpdate];
    } else {
        [self _regularDispatchUpdate];
    }
}

- (void)_regularDispatchUpdate {
    _hasQueuedUpdate = YES;
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf _performUpdate];
    });
}

- (void)_adaptiveDispatchUpdate {
    const IGListAdaptiveCoalescingExperimentConfig config = _adaptiveCoalescingExperimentConfig;
    
    const NSTimeInterval timeSinceLastUpdate = -[_lastUpdateStartDate timeIntervalSinceNow];
    if (!_lastUpdateStartDate || timeSinceLastUpdate > _coalescenceInterval) {
        // It's been long enough, so lets reset interval and perform update right away
        _coalescenceInterval = config.minInterval;
        [self _performUpdate];
        return;
    }
    
    // If we keep hitting the delay, lets increase it.
    _coalescenceInterval = MIN(_coalescenceInterval + config.intervalIncrement, config.maxInterval);
    
    // Delay by the time remaining in the interval
    const NSTimeInterval remainingTime = MAX(_coalescenceInterval - timeSinceLastUpdate, 0);
    
    _hasQueuedUpdate = YES;
    __weak __typeof__(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(remainingTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf _performUpdate];
    });
}

- (void)_performUpdate {
    _hasQueuedUpdate = NO;
    _lastUpdateStartDate = [NSDate date];
    [self.delegate performUpdateWithCoalescer:self];
}

#pragma mark - Properties

- (void)setAdaptiveCoalescingExperimentConfig:(IGListAdaptiveCoalescingExperimentConfig)adaptiveCoalescingExperimentConfig {
    _adaptiveCoalescingExperimentConfig = adaptiveCoalescingExperimentConfig;
    _coalescenceInterval = adaptiveCoalescingExperimentConfig.minInterval;
}

@end
