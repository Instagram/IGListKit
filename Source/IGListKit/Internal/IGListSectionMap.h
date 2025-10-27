/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListMacros.h"
#else
#import <IGListDiffKit/IGListMacros.h>
#endif

@class IGListSectionController;
@protocol IGListDiffable;


NS_ASSUME_NONNULL_BEGIN

/**
 The IGListSectionMap provides a way to map a collection of objects to a collection of section controllers and achieve
 constant-time lookups O(1).

 IGListSectionMap is a mutable object and does not guarantee thread safety.
 */
IGLK_SUBCLASSING_RESTRICTED
@interface IGListSectionMap : NSObject <NSCopying>

/**
 @param mapTable Table used to keep a relationship between the object and its section-controller
 */
- (instancetype)initWithMapTable:(NSMapTable<id<IGListDiffable>, IGListSectionController *> *)mapTable NS_DESIGNATED_INITIALIZER;

/**
 The objects stored in the map.
 */
@property (nonatomic, strong, readonly) NSArray<id<IGListDiffable>> *objects;

/**
 Update the map with objects and the section controller counterparts.

 @param objects The objects in the collection.
 @param sectionControllers The section controllers that map to each object.
 */
- (void)updateWithObjects:(NSArray<id<IGListDiffable>> *)objects sectionControllers:(NSArray<IGListSectionController *> *)sectionControllers;

/**
 Fetch a section controller given a section.

 @param section The section index of the section controller.

 @return A section controller.
 */
- (nullable IGListSectionController *)sectionControllerForSection:(NSInteger)section;

/**
 Fetch the object for a section

 @param section The section index of the object.

 @return The object corresponding to the section.
 */
- (nullable id<IGListDiffable>)objectForSection:(NSInteger)section;

/**
 Fetch a section controller given an object. Can return nil.

 @param object The object that maps to a section controller.

 @return A section controller.
 */
- (nullable IGListSectionController *)sectionControllerForObject:(id<IGListDiffable>)object;

/**
 Look up the section index for a section controller.

 @param sectionController The list to look up.

 @return The section index of the given section controller if it exists, NSNotFound otherwise.
 */
- (NSInteger)sectionForSectionController:(IGListSectionController *)sectionController;

/**
 Look up the section index for an object.

 @param object The object to look up.

 @return The section index of the given object if it exists, NSNotFound otherwise.
 */
- (NSInteger)sectionForObject:(id<IGListDiffable>)object;

/**
 Remove all saved objects and section controllers.
 */
- (void)reset;

/**
 Update an object with a new instance.
 */
- (void)updateObject:(id<IGListDiffable>)object;

/**
 Applies a given block object to the entries of the section controller map.

 @param block A block object to operate on entries in the section controller map.
 */
- (void)enumerateUsingBlock:(void (^)(id<IGListDiffable> object, IGListSectionController *sectionController, NSInteger section, BOOL *stop))block;

/**
 :nodoc:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 :nodoc:
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
