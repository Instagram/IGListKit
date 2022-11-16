/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <IGListDiffKit/IGListDiffable.h>

@interface IGSectionObject : NSObject <IGListDiffable>

@property (nonatomic, copy) NSArray *objects;

+ (instancetype)sectionWithObjects:(NSArray *)objects;

+ (instancetype)sectionWithObjects:(NSArray *)objects identifier:(NSString *)identifier;

/**
 @param usesIdentifierForDiffable YES if we only use the `identifier` for -isEqualToDiffableObject. NO then we compares both the `identifier` as well as `objects`.
 */
+ (instancetype)sectionWithObjects:(NSArray *)objects identifier:(NSString *)identifier usesIdentifierForDiffable:(BOOL)usesIdentifierForDiffable;

@end

@interface IGListTestUICollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, copy) NSArray <IGSectionObject *> *sections;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

@end
