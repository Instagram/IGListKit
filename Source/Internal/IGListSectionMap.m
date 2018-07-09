/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListSectionMap.h"

#import <IGListKit/IGListAssert.h>

#import "IGListSectionControllerInternal.h"

@interface IGListSectionMap ()

// both of these maps allow fast lookups of objects, list objects, and indexes
@property (nonatomic, strong, readonly, nonnull) NSMapTable<id, IGListSectionController *> *objectToSectionControllerMap;
@property (nonatomic, strong, readonly, nonnull) NSMapTable<IGListSectionController *, NSNumber *> *sectionControllerToSectionMap;

@property (nonatomic, strong, nonnull) NSMutableArray *mObjects;

@end

@implementation IGListSectionMap

- (instancetype)initWithMapTable:(NSMapTable *)mapTable {
    IGParameterAssert(mapTable != nil);

    if (self = [super init]) {
        _objectToSectionControllerMap = [mapTable copy];

        // lookup list objects by pointer equality
        _sectionControllerToSectionMap = [[NSMapTable alloc] initWithKeyOptions:NSMapTableStrongMemory | NSMapTableObjectPointerPersonality
                                                                   valueOptions:NSMapTableStrongMemory
                                                                       capacity:0];
        _mObjects = [NSMutableArray new];
    }
    return self;
}


#pragma mark - Public API

- (NSArray *)objects {
    return [self.mObjects copy];
}

- (NSInteger)sectionForSectionController:(IGListSectionController *)sectionController {
    IGParameterAssert(sectionController != nil);

    NSNumber *index = [self.sectionControllerToSectionMap objectForKey:sectionController];
    return index != nil ? [index integerValue] : NSNotFound;
}

- (IGListSectionController *)sectionControllerForSection:(NSInteger)section {
    return [self.objectToSectionControllerMap objectForKey:[self objectForSection:section]];
}

- (void)updateWithObjects:(NSArray *)objects sectionControllers:(NSArray *)sectionControllers {
    IGParameterAssert(objects.count == sectionControllers.count);

    [self reset];

    self.mObjects = [objects mutableCopy];

    id firstObject = objects.firstObject;
    id lastObject = objects.lastObject;

    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        IGListSectionController *sectionController = sectionControllers[idx];

        // set the index of the list for easy reverse lookup
        [self.sectionControllerToSectionMap setObject:@(idx) forKey:sectionController];
        [self.objectToSectionControllerMap setObject:sectionController forKey:object];

        sectionController.isFirstSection = (object == firstObject);
        sectionController.isLastSection = (object == lastObject);
        sectionController.section = (NSInteger)idx;
    }];
}

- (nullable IGListSectionController *)sectionControllerForObject:(id)object {
    IGParameterAssert(object != nil);

    return [self.objectToSectionControllerMap objectForKey:object];
}

- (nullable id)objectForSection:(NSInteger)section {
    NSArray *objects = self.mObjects;
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
    [self enumerateUsingBlock:^(id  _Nonnull object, IGListSectionController * _Nonnull sectionController, NSInteger section, BOOL * _Nonnull stop) {
        sectionController.section = NSNotFound;
        sectionController.isFirstSection = NO;
        sectionController.isLastSection = NO;
    }];

    [self.sectionControllerToSectionMap removeAllObjects];
    [self.objectToSectionControllerMap removeAllObjects];
}

- (void)updateObject:(id)object {
    IGParameterAssert(object != nil);
    const NSInteger section = [self sectionForObject:object];
    id sectionController = [self sectionControllerForObject:object];
    [self.sectionControllerToSectionMap setObject:@(section) forKey:sectionController];
    [self.objectToSectionControllerMap setObject:sectionController forKey:object];
    self.mObjects[section] = object;
}

- (void)enumerateUsingBlock:(void (^)(id object, IGListSectionController *sectionController, NSInteger section, BOOL *stop))block {
    IGParameterAssert(block != nil);

    BOOL stop = NO;
    NSArray *objects = self.objects;
    for (NSInteger section = 0; section < objects.count; section++) {
        id object = objects[section];
        IGListSectionController *sectionController = [self sectionControllerForObject:object];
        block(object, sectionController, section, &stop);
        if (stop) {
            break;
        }
    }
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    IGListSectionMap *copy = [[IGListSectionMap allocWithZone:zone] initWithMapTable:self.objectToSectionControllerMap];
    if (copy != nil) {
        copy->_sectionControllerToSectionMap = [self.sectionControllerToSectionMap copy];
        copy->_mObjects = [self.mObjects mutableCopy];
    }
    return copy;
}

@end
