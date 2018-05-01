/**
 * Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListTestCase.h"

@implementation IGListTestCase

- (void)setUp {
    [super setUp];

    IGAssert(self.dataSource != nil, @"Data source must be set in -setUp before testing %@", NSStringFromClass(self.class));

    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        self.frame = CGRectMake(0, 0, 100, 100);
    }

    self.window = [[UIWindow alloc] initWithFrame:self.frame];
    self.layout = [UICollectionViewFlowLayout new];
    self.collectionView = self.collectionView ?: [[UICollectionView alloc] initWithFrame:self.frame
                                                                    collectionViewLayout:self.layout];
    [self.window addSubview:self.collectionView];
    self.updater = self.updater ?: [IGListAdapterUpdater new];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:self.updater
                                           viewController:self.viewController
                                         workingRangeSize:self.workingRangeSize];
}

- (void)tearDown {
    self.window = nil;
    self.collectionView = nil;
    self.adapter = nil;
    self.dataSource = nil;
    self.updater = nil;
    self.viewController = nil;
    self.workingRangeSize = 0;

    [super tearDown];
}

- (void)setupWithObjects:(NSArray *)objects {
    self.dataSource.objects = objects;
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self.dataSource;
    [self.collectionView layoutIfNeeded];
}

@end
