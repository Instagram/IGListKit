/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant 
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListTestUICollectionViewDataSource.h"

@implementation IGSectionObject

+ (instancetype)sectionWithObjects:(NSArray *)objects {
    IGSectionObject *object = [[IGSectionObject alloc] init];
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
    } else if ([object isKindOfClass:IGSectionObject.class]) {
        return (self.objects && [self.objects isEqualToArray:[object objects]])
        || (!self.objects && ![object objects]);
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
