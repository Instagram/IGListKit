/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListAdapterUpdater+DebugDescription.h"

#import "IGListAdapterUpdaterInternal.h"
#import "IGListBatchUpdateData+DebugDescription.h"
#import "IGListDebuggingUtilities.h"

#if IGLK_DEBUG_DESCRIPTION_ENABLED
static NSMutableArray *linesFromObjects(NSArray *objects) {
    NSMutableArray *lines = [NSMutableArray new];
    for (id object in objects) {
        [lines addObject:[NSString stringWithFormat:@"Object %p of type %@ with identifier %@",
                          object, NSStringFromClass([object class]), [object diffIdentifier]]];
    }
    return lines;
}
#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED

@implementation IGListAdapterUpdater (DebugDescription)

- (NSArray<NSString *> *)debugDescriptionLines {
    NSMutableArray *debug = [NSMutableArray new];
#if IGLK_DEBUG_DESCRIPTION_ENABLED
    [debug addObject:[NSString stringWithFormat:@"Moves as deletes+inserts: %@", IGListDebugBOOL(self.movesAsDeletesInserts)]];
    [debug addObject:[NSString stringWithFormat:@"Allows background reloading: %@", IGListDebugBOOL(self.allowsBackgroundReloading)]];
    [debug addObject:[NSString stringWithFormat:@"Has queued reload data: %@", IGListDebugBOOL(self.hasQueuedReloadData)]];
    [debug addObject:[NSString stringWithFormat:@"Queued update is animated: %@", IGListDebugBOOL(self.queuedUpdateIsAnimated)]];

    NSString *stateString;
    switch (self.state) {
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

    if (self.applyingUpdateData != nil) {
        [debug addObject:@"Batch update data:"];
        [debug addObjectsFromArray:IGListDebugIndentedLines([self.applyingUpdateData debugDescriptionLines])];
    }

    if (self.fromObjects != nil) {
        [debug addObject:@"From objects:"];
        [debug addObjectsFromArray:IGListDebugIndentedLines(linesFromObjects(self.fromObjects))];
    }

    if (self.toObjectsBlock != nil) {
        [debug addObject:@"To objects:"];
        [debug addObjectsFromArray:IGListDebugIndentedLines(linesFromObjects(self.toObjectsBlock()))];
    }

    if (self.pendingTransitionToObjects != nil) {
        [debug addObject:@"Pending objects:"];
        [debug addObjectsFromArray:IGListDebugIndentedLines(linesFromObjects(self.pendingTransitionToObjects))];
    }
#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED
    return debug;
}

@end
