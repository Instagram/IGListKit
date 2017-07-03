/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

@class UIView;

@protocol IGListReusableView <NSObject>

/**
 String to identify the cell during reuse.
 */
@property(nonatomic, readonly, copy) NSString *reuseIdentifier;

/**
 The view that should be used to house all custom views within this cell.
 */
@property(nonatomic, readonly, strong) UIView *contentView;

/**
 Method that is called before a cell is reused by the list view. It is where custom clean up should be performed.
 */
- (void)prepareForReuse;

@end
