//
//  IGListAsyncTask.h
//  IGListKit
//
//  Created by Adlai Holler on 2/21/17.
//  Copyright © 2017 Instagram. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A protocol for objects that implement a task that runs asynchronously
 * from the main thread, and that can be safely waited on to finish.
 */
@protocol IGListAsyncTask <NSObject>

/**
 * Schedules the task to begin.
 *
 * @param completionBlock A block to call on the main thread after
 * the work is done. This block should be called whether -waitUntilCompleted
 * is used or not.
 *
 * Must be called on the main thread.
 */
- (void)startWithCompletion:(nullable dispatch_block_t)completionBlock;

/**
 * Blocks the main thread until the task is complete.
 *
 * This must be called *after* -startWithCompletion: and should only be called once.
 *
 * Must be called on the main thread.
 */
- (void)waitUntilCompleted;

@end

NS_ASSUME_NONNULL_END
