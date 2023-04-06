/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListAdapterUpdater+DebugDescription.h"

#import "IGListAdapterUpdaterInternal.h"
#import "IGListBatchUpdateData+DebugDescription.h"
#import "IGListDebuggingUtilities.h"
#import "IGListUpdateTransactable.h"

@implementation IGListAdapterUpdater (DebugDescription)

- (NSArray<NSString *> *)debugDescriptionLines {
    NSMutableArray *debug = [NSMutableArray new];
#if defined(IGLK_DEBUG_DESCRIPTION_ENABLED) && IGLK_DEBUG_DESCRIPTION_ENABLED
    [debug addObject:@"Options:"];
    NSArray<NSString *> *options = @[
        [NSString stringWithFormat:@"sectionMovesAsDeletesInserts: %@", IGListDebugBOOL(self.sectionMovesAsDeletesInserts)],
        [NSString stringWithFormat:@"singleItemSectionUpdates: %@", IGListDebugBOOL(self.singleItemSectionUpdates)],
        [NSString stringWithFormat:@"preferItemReloadsForSectionReloads: %@", IGListDebugBOOL(self.preferItemReloadsForSectionReloads)],
        [NSString stringWithFormat:@"allowsReloadingOnTooManyUpdates: %@", IGListDebugBOOL(self.allowsReloadingOnTooManyUpdates)],
        [NSString stringWithFormat:@"allowsBackgroundDiffing: %@", IGListDebugBOOL(self.allowsBackgroundDiffing)]
    ];
    [debug addObjectsFromArray:IGListDebugIndentedLines(options)];

    const IGListBatchUpdateState state = self.transaction ? [self.transaction state] : IGListBatchUpdateStateIdle;

    NSString *stateString;
    switch (state) {
        case IGListBatchUpdateStateIdle:
            stateString = @"Idle";
            break;
        case IGListBatchUpdateStateQueuedBatchUpdate:
            stateString = @"Queued batch update";
            break;
        case IGListBatchUpdateStateExecutedBatchUpdateBlock:
            stateString = @"Executed batch update block";
            break;
        case IGListBatchUpdateStateExecutingBatchUpdateBlock:
            stateString = @"Executing batch update block";
            break;
    }
    [debug addObject:[NSString stringWithFormat:@"State: %@", stateString]];

#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED
    return debug;
}

@end
