/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

/**
 * This file is generated using the remodel generation script.
 * The name of the input file is PersonModel.value
 */

#import <Foundation/Foundation.h>

#import <IGListDiffKit/IGListDiffable.h>

@interface PersonModel : NSObject <IGListDiffable, NSCopying>

@property (nonatomic, readonly, copy) NSString *firstName;
@property (nonatomic, readonly, copy) NSString *lastName;
@property (nonatomic, readonly, copy) NSString *uniqueId;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName uniqueId:(NSString *)uniqueId NS_DESIGNATED_INITIALIZER;

@end
