/*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import <Foundation/Foundation.h>

#import <IGListDiffKit/IGListMacros.h>

NS_ASSUME_NONNULL_BEGIN

@class IGListSectionController;

/**
 Container object that holds the data needed for an update.
*/
IGLK_SUBCLASSING_RESTRICTED
NS_SWIFT_NAME(ListTransitionData)
@interface IGListTransitionData : NSObject

- (instancetype)initFromObjects:(NSArray *)fromObjects
                      toObjects:(NSArray *)toObjects
           toSectionControllers:(NSArray<IGListSectionController *> *)toSectionControllers NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// The previous objects in the collection view. Objects must conform to `IGListDiffable`.
@property (nonatomic, copy, readonly) NSArray *fromObjects;
/// The new objects in the collection view. Objects must conform to `IGListDiffable`.
@property (nonatomic, copy, readonly) NSArray *toObjects;
/// The section controllers corresponding to the `toObjects`
@property (nonatomic, copy, readonly) NSArray<IGListSectionController *> *toSectionControllers;

@end

NS_ASSUME_NONNULL_END
