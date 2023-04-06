/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListSectionController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This class adds a helper layer to `IGListSectionController` to automatically store a generic object in
 `didUpdateToObject:`.
 */
NS_SWIFT_NAME(ListGenericSectionController)
@interface IGListGenericSectionController<__covariant ObjectType> : IGListSectionController

/**
 The object mapped to this section controller. Matches the object provided in
 `[IGListAdapterDataSource listAdapter:sectionControllerForObject:]` when this section controller was created and
 returned.

 @note This object is briefly `nil` between initialization and the first call to `didUpdateToObject:`. After that, it is
 safe to assume that this is non-`nil`. For this reason, we bridge it to Swift as an implicitly-unwrapped Optional, so
 that idiomatic IGListKit code is not forced to handle nullability with explicit `as!` or `fatalError`.
 */
@property (nonatomic, strong, null_unspecified, readonly) ObjectType object;

/**
 Updates the section controller to a new object.

 @param object The object mapped to this section controller.

 @note This `IGListSectionController` subclass sets its object in this method, so any overrides **must call super**.
 */
- (void)didUpdateToObject:(ObjectType)object NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
