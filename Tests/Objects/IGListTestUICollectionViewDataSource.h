/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import <IGListDiffKit/IGListDiffable.h>

@interface IGSectionObject : NSObject <IGListDiffable>

@property (nonatomic, strong) NSArray *objects;

+ (instancetype)sectionWithObjects:(NSArray *)objects;

+ (instancetype)sectionWithObjects:(NSArray *)objects identifier:(NSString *)identifier;

/**
 @param usesIdentifierForDiffable YES if we only use the `identifier` for -isEqualToDiffableObject. NO then we compares both the `identifier` as well as `objects`.
 */
+ (instancetype)sectionWithObjects:(NSArray *)objects identifier:(NSString *)identifier usesIdentifierForDiffable:(BOOL)usesIdentifierForDiffable;

@end

@interface IGListTestUICollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, strong) NSArray <IGSectionObject *> *sections;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

@end
