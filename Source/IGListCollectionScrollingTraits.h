/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

/**
 The current scrolling traits of the underlying collection view.
 The attributes are always equal to their corresponding properties on the underlying collection view.
 */
NS_SWIFT_NAME(ListCollectionScrollingTraits)
typedef struct IGListCollectionScrollingTraits {
    /// returns YES if user has touched. may not yet have started dragging.
    bool isTracking;
    /// returns YES if user has started scrolling. this may require some time and or distance to move to initiate dragging
    bool isDragging;
    /// returns YES if user isn't dragging (touch up) but scroll view is still moving.
    bool isDecelerating;
} IGListCollectionScrollingTraits;
