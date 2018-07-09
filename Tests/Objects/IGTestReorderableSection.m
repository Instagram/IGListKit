/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGTestReorderableSection.h"

@implementation IGTestReorderableSectionObject

+ (instancetype)sectionWithObjects:(NSArray *)objects {
    IGTestReorderableSectionObject *object = [IGTestReorderableSectionObject new];
    object.objects = objects;
    return object;
}

#pragma mark - IGListDiffable

- (id<NSObject>)diffIdentifier {
    // this is for test purposes only. please dont do this.
    return [NSString stringWithFormat:@"%zi", self.hash];
}

- (BOOL)isEqualToDiffableObject:(id)object {
    if (object == self) {
        return YES;
    } else if ([object isKindOfClass:IGTestReorderableSectionObject.class]) {
        return (self.objects && [self.objects isEqualToArray:[object objects]])
        || (!self.objects && ![object objects]);
    } else {
        return NO;
    }
}

@end

@implementation IGTestReorderableSection

- (instancetype)initWithSectionObject:(IGTestReorderableSectionObject *)sectionObject {
    if (self = [super init]) {
        _sectionObject = sectionObject;
        _size = CGSizeMake(100, 10);
    }
    return self;
}

- (NSArray <Class> *)cellClasses {
    return @[UICollectionViewCell.class];
}

- (NSInteger)numberOfItems {
    return [self.sectionObject.objects count];
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return self.size;
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    return [self.collectionContext dequeueReusableCellOfClass:UICollectionViewCell.class
                                         forSectionController:self
                                                      atIndex:index];
}

- (void)didUpdateToObject:(id)object {
    if ([object isKindOfClass:[IGTestReorderableSection class]]) {
        self.sectionObject = object;
    }
}

- (BOOL)canMoveItemAtIndex:(NSInteger)index {
    return self.isReorderable;
}

- (void)moveObjectFromIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex {
    NSArray *originalObjects = self.sectionObject.objects;
    NSMutableArray *updatedObjects = [originalObjects mutableCopy];
    id object = originalObjects[sourceIndex];
    [updatedObjects removeObjectAtIndex:sourceIndex];
    [updatedObjects insertObject:object atIndex:destinationIndex];
    self.sectionObject.objects = [updatedObjects copy];
}

@end

