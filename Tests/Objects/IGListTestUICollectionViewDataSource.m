/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListTestUICollectionViewDataSource.h"

#import <IGListDiffKit/IGListAssert.h>

@implementation IGSectionObject {
    NSString *_identifier;
    BOOL _usesIdentifierForDiffable;
}

+ (instancetype)sectionWithObjects:(NSArray *)objects {
    return [IGSectionObject sectionWithObjects:objects identifier:[NSUUID UUID].UUIDString usesIdentifierForDiffable:NO];
}

+ (instancetype)sectionWithObjects:(NSArray *)objects identifier:(NSString *)identifier {
    return [IGSectionObject sectionWithObjects:objects identifier:identifier usesIdentifierForDiffable:NO];
}

+ (instancetype)sectionWithObjects:(NSArray *)objects identifier:(NSString *)identifier usesIdentifierForDiffable:(BOOL)usesIdentifierForDiffable {
    IGSectionObject *object = [[IGSectionObject alloc] init];
    object.objects = objects;
    object->_identifier = [identifier copy];
    object->_usesIdentifierForDiffable = usesIdentifierForDiffable;
    return object;
}

#pragma mark - IGListDiffable

- (id<NSObject>)diffIdentifier {
    return _identifier;
}

- (BOOL)isEqualToDiffableObject:(id)object {
    if (object == self) {
        return YES;
    } else if ([object isKindOfClass:IGSectionObject.class]) {
        IGSectionObject *sectionObject = (IGSectionObject *)object;
        if (_usesIdentifierForDiffable) {
            return [_identifier isEqualToString:sectionObject->_identifier];
        } else {
            return [self isEqual:object];
        }
    } else {
        return NO;
    }
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    } else if ([object isKindOfClass:IGSectionObject.class]) {
        IGSectionObject *sectionObject = (IGSectionObject *)object;
        return ([self.objects isEqualToArray:sectionObject.objects]
                && [_identifier isEqualToString:sectionObject->_identifier]);
    } else {
        return NO;
    }
}

@end

@implementation IGListTestUICollectionViewDataSource

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    if (self = [super init]) {
        collectionView.dataSource = self;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.sections[section] objects] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    return cell;
}

@end
