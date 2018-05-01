/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@class IGLayoutTestItem;

#define genLayoutTestSection(i) [[IGLayoutTestSection alloc] initWithItems:i]

@interface IGLayoutTestSection : NSObject

@property (nonatomic, assign, readonly) UIEdgeInsets insets;
@property (nonatomic, assign, readonly) CGFloat lineSpacing;
@property (nonatomic, assign, readonly) CGFloat interitemSpacing;
@property (nonatomic, assign, readonly) CGFloat headerHeight;
@property (nonatomic, assign, readonly) CGFloat footerHeight;
@property (nonatomic, strong, readonly) NSArray<IGLayoutTestItem *> *items;

- (instancetype)initWithItems:(NSArray<IGLayoutTestItem *> *)items;

- (instancetype)initWithInsets:(UIEdgeInsets)insets
                   lineSpacing:(CGFloat)lineSpacing
              interitemSpacing:(CGFloat)interitemSpacing
                  headerHeight:(CGFloat)headerHeight
                  footerHeight:(CGFloat)footerHeight
                         items:(NSArray<IGLayoutTestItem *> *)items NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
