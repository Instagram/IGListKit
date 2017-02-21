/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListKit/IGListMacros.h>

NS_ASSUME_NONNULL_BEGIN

@class IGListPreprocessingContext;
@protocol IGListPreprocessingDelegate;

IGLK_SUBCLASSING_RESTRICTED
@interface IGListPreprocessingContext : NSObject

/**
 * Make this private / protocolize the public API.
 */
- (instancetype)initWithObject:(id)object
                 containerSize:(CGSize)containerSize
                  sectionIndex:(NSInteger)sectionIndex
                 dispatchGroup:(dispatch_group_t)group;

@property (nonatomic, strong, readonly) id objectOfSectionController;

@property (nonatomic, readonly) CGSize containerSize;

@property (nonatomic, readonly) NSInteger sectionIndex;

@property (nonatomic, nullable, strong) id value;

- (void)completePreprocessing;

@end

NS_ASSUME_NONNULL_END
