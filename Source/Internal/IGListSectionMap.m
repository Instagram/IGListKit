/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListSectionMap.h"

#import <IGListKit/IGListAssert.h>

@interface IGListSectionMap ()

// both of these maps allow fast lookups of objects, list objects, and indexes
@property (nonatomic, strong, readonly) NSMapTable<IGListSectionController<IGListSectionType> *, id> *sectionControllerToObjectMap;
@property (nonatomic, strong, readonly) NSMapTable<IGListSectionController<IGListSectionType> *, NSNumber *> *sectionControllerToSectionMap;

@property (nonatomic, strong, readwrite) NSArray *objects;

@end

@implementation IGListSectionMap

- (instancetype)initWithMapTable:(NSMapTable *)mapTable {
    IGParameterAssert(mapTable != nil);

    if (self = [super init]) {
        _sectionControllerToObjectMap = [mapTable copy];

        // lookup list objects by pointer equality
        _sectionControllerToSectionMap = [[NSMapTable alloc] initWithKeyOptions:NSMapTableStrongMemory | NSMapTableObjectPointerPersonality
                                                                   valueOptions:NSMapTableStrongMemory
                                                                       capacity:0];
        _objects = [NSArray new];
    }
    return self;
}


#pragma mark - Public API

- (NSInteger)sectionForSectionController:(IGListSectionController <IGListSectionType> *)sectionController {
    IGParameterAssert(sectionController != nil);

    NSNumber *index = [self.sectionControllerToSectionMap objectForKey:sectionController];
    return index != nil ? [index unsignedIntegerValue] : NSNotFound;
}

- (IGListSectionController <IGListSectionType> *)sectionControllerForSection:(NSInteger)section {
    return [self.sectionControllerToObjectMap objectForKey:[self objectForSection:section]];
}

- (void)updateWithObjects:(NSArray *)objects sectionControllers:(NSArray *)sectionControllers {
    IGParameterAssert(objects.count == sectionControllers.count);

    self.objects = [objects copy];

    [self reset];

    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        IGListSectionController<IGListSectionType> *sectionController = sectionControllers[idx];

        // set the index of the list for easy reverse lookup
        [self.sectionControllerToSectionMap setObject:@(idx) forKey:sectionController];
        [self.sectionControllerToObjectMap setObject:sectionController forKey:object];
    }];
}

- (nullable IGListSectionController <IGListSectionType> *)sectionControllerForObject:(id)object {
    IGParameterAssert(object != nil);

    return [self.sectionControllerToObjectMap objectForKey:object];
}

- (id)objectForSection:(NSInteger)section {
    NSArray *objects = self.objects;
    if (section < objects.count) {
        return objects[section];
    } else {
        return nil;
    }
}

- (NSInteger)sectionForObject:(id)object {
    IGParameterAssert(object != nil);

    id sectionController = [self sectionControllerForObject:object];
    if (sectionController == nil) {
        return NSNotFound;
    } else {
        return [self sectionForSectionController:sectionController];
    }
}

- (void)reset {
    [self.sectionControllerToSectionMap removeAllObjects];
    [self.sectionControllerToObjectMap removeAllObjects];
}

- (void)updateObject:(id)object {
    IGParameterAssert(object != nil);
    const NSUInteger section = [self sectionForObject:object];
    id sectionController = [self sectionControllerForObject:object];
    [self.sectionControllerToSectionMap setObject:@(section) forKey:sectionController];
    [self.sectionControllerToObjectMap setObject:sectionController forKey:object];

    NSMutableArray *mobjects = [self.objects mutableCopy];
    mobjects[section] = object;
    self.objects = [mobjects copy];
}

- (void)enumerateUsingBlock:(void (^)(id object, IGListSectionController <IGListSectionType> *sectionController, NSInteger section, BOOL *stop))block {
    IGParameterAssert(block != nil);

    BOOL stop = NO;
    NSArray *objects = self.objects;
    for (NSUInteger section = 0; section < objects.count; section++) {
        id object = objects[section];
        IGListSectionController <IGListSectionType> *sectionController = [self sectionControllerForObject:object];
        block(object, sectionController, section, &stop);
        if (stop) {
            break;
        }
    }
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    IGListSectionMap *copy = [[IGListSectionMap allocWithZone:zone] initWithMapTable:self.sectionControllerToObjectMap];
    copy->_sectionControllerToSectionMap = [self.sectionControllerToSectionMap copy];
    copy->_objects = [self.objects copy];
    return copy;
}

@end
