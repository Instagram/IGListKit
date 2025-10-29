/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListSectionMap.h"

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListAssert.h"
#else
#import <IGListDiffKit/IGListAssert.h>
#endif

#import "IGListSectionControllerInternal.h"

@interface IGListSectionMap ()

// both of these maps allow fast lookups of objects, list objects, and indexes
@property (nonatomic, strong, readonly, nonnull) NSMapTable<id<IGListDiffable>, IGListSectionController *> *objectToSectionControllerMap;
@property (nonatomic, strong, readonly, nonnull) NSMapTable<IGListSectionController *, NSNumber *> *sectionControllerToSectionMap;

@property (nonatomic, strong, nonnull) NSMutableArray<id<IGListDiffable>> *mObjects;

@property (nonatomic, strong, nullable) NSMutableArray<id<NSObject>> *diffIdentifiersSnapshot;

@end

@implementation IGListSectionMap

- (instancetype)initWithMapTable:(NSMapTable<id<IGListDiffable>, IGListSectionController *> *)mapTable {
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

- (NSArray<id<IGListDiffable>> *)objects {
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

- (void)updateWithObjects:(NSArray<id<IGListDiffable>> *)objects sectionControllers:(NSArray<IGListSectionController *> *)sectionControllers {
    IGParameterAssert(objects.count == sectionControllers.count);

    [self reset];

    [self _validateAllDiffIdentifiers];
    self.mObjects = [objects mutableCopy];
    [self _updateAllDiffIdentifiers];

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

- (nullable IGListSectionController *)sectionControllerForObject:(id<IGListDiffable>)object {
    IGParameterAssert(object != nil);

    return [self.objectToSectionControllerMap objectForKey:object];
}

- (nullable id<IGListDiffable>)objectForSection:(NSInteger)section {
    if (section < 0) {
        return nil;
    }

    NSArray *objects = self.mObjects;
    if ((NSUInteger)section >= objects.count) {
        return nil;
    }

    return objects[section];
}

- (NSInteger)sectionForObject:(id<IGListDiffable>)object {
    if (object == nil) {
        return NSNotFound;
    }

    id sectionController = [self sectionControllerForObject:object];
    if (sectionController == nil) {
        return NSNotFound;
    }

    return [self sectionForSectionController:sectionController];
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

- (void)updateObject:(id<IGListDiffable>)object {
    IGParameterAssert(object != nil);
    const NSInteger section = [self sectionForObject:object];
    id sectionController = [self sectionControllerForObject:object];
    [self.sectionControllerToSectionMap setObject:@(section) forKey:sectionController];
    [self.objectToSectionControllerMap setObject:sectionController forKey:object];


    [self _validateDiffIdentifierAtSection:section];
    self.mObjects[section] = object;
    [self _updateDiffIdentifierAtSection:section newObject:object];
}

- (void)enumerateUsingBlock:(void (^)(id<IGListDiffable> object, IGListSectionController *sectionController, NSInteger section, BOOL *stop))block {
    IGParameterAssert(block != nil);

    BOOL stop = NO;
    NSArray *objects = self.objects;
    for (NSInteger section = 0; section < (NSInteger)objects.count; section++) {
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
        copy->_diffIdentifiersSnapshot = [self.diffIdentifiersSnapshot mutableCopy];
    }
    return copy;
}


#pragma mark - Diff Identifiers validation

#if IG_ASSERTIONS_ENABLED
static void IGListSectionMapValidateDiffIdentifier(NSUInteger section, NSArray<id<IGListDiffable>> *mObjects, NSArray<id<NSObject>> *_Nullable diffIdentifiersSnapshot) {
  if (mObjects.count != diffIdentifiersSnapshot.count) {
    // Don't have an accurate snapshot of the diff identifiers.
    return;
  }
  
  if (section < 0 || section >= mObjects.count) {
    return;
  }
  
  id<IGListDiffable> const object = mObjects[section];
  id<NSObject> const newDiffIdentifier = [object diffIdentifier];
  id<NSObject> const oldDiffIdentifier = diffIdentifiersSnapshot[section];
  
  // Between updates, we don't expect the diffIdentifier to change for the same section. If it does, we lose our ability to find the
  // corresponding section-controller in `objectToSectionControllerMap` and usually crash. For example:
  // - Section has suddently 0 items, so batch updates are wrong
  // - Adapter returns nil cell
  // The fix is to make sure -diffIdentifier is not mutable. Generally, -diffIdentifier should be pretty simple (like a UUID)
  // and -isEqualToDiffableObject should be where we compare all other relevant properties to trigger an update.
  IGAssert([oldDiffIdentifier isEqual:newDiffIdentifier], @"Diff identifier changed for object %@ at section %i, from %@ to %@",
           NSStringFromClass([(NSObject *)object class]),
           (unsigned int)section,
           oldDiffIdentifier,
           newDiffIdentifier);
}
#endif

- (void)_validateAllDiffIdentifiers {
#if IG_ASSERTIONS_ENABLED
  for (NSUInteger section = 0; section < _mObjects.count; section++) {
    IGListSectionMapValidateDiffIdentifier(section, _mObjects, _diffIdentifiersSnapshot);
  }
#endif
}

- (void)_validateDiffIdentifierAtSection:(NSInteger)section {
#if IG_ASSERTIONS_ENABLED
  IGListSectionMapValidateDiffIdentifier(section, _mObjects, _diffIdentifiersSnapshot);
#endif
}

- (void)_updateAllDiffIdentifiers {
#if IG_ASSERTIONS_ENABLED
  if (!_diffIdentifiersSnapshot) {
    _diffIdentifiersSnapshot = [NSMutableArray new];
  }
  
  [_diffIdentifiersSnapshot removeAllObjects];
  for (id<IGListDiffable> object in _mObjects) {
    [_diffIdentifiersSnapshot addObject:[object diffIdentifier]];
  }
#endif
}

- (void)_updateDiffIdentifierAtSection:(NSInteger)section newObject:(id<IGListDiffable>)newObject {
#if IG_ASSERTIONS_ENABLED
  _diffIdentifiersSnapshot[section] = newObject.diffIdentifier;
#endif
}

@end
