/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ObjcGeneratedModelDemoViewController.h"

#import <IGListKit/IGListKit.h>

#import "PersonModel.h"
#import "PersonSectionController.h"

@interface ObjcGeneratedModelDemoViewController () <IGListAdapterDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, copy) NSArray<PersonModel *> *persons;

@end


@implementation ObjcGeneratedModelDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.persons = @[[[PersonModel alloc] initWithFirstName:@"Ryan" lastName:@"Nystrom" uniqueId:@"1"],
                     [[PersonModel alloc] initWithFirstName:@"Jesse" lastName:@"Squires" uniqueId:@"2"],
                     [[PersonModel alloc] initWithFirstName:@"Markus" lastName:@"Emrich" uniqueId:@"3"],
                     [[PersonModel alloc] initWithFirstName:@"James" lastName:@"Sherlock" uniqueId:@"4"],
                     [[PersonModel alloc] initWithFirstName:@"Bofei" lastName:@"Zhu" uniqueId:@"5"],
                     [[PersonModel alloc] initWithFirstName:@"Valeriy" lastName:@"Van" uniqueId:@"6"],
                     [[PersonModel alloc] initWithFirstName:@"Hesham" lastName:@"Salman" uniqueId:@"7"],
                     [[PersonModel alloc] initWithFirstName:@"Bas" lastName:@"Broek" uniqueId:@"8"],
                     [[PersonModel alloc] initWithFirstName:@"Andrew" lastName:@"Monshizadeh" uniqueId:@"9"],
                     [[PersonModel alloc] initWithFirstName:@"Adlai" lastName:@"Holler" uniqueId:@"10"],
                     [[PersonModel alloc] initWithFirstName:@"Ben" lastName:@"Asher" uniqueId:@"11"],
                     [[PersonModel alloc] initWithFirstName:@"Jake" lastName:@"Lin" uniqueId:@"12"],
                     [[PersonModel alloc] initWithFirstName:@"Jeff" lastName:@"Bailey" uniqueId:@"13"],
                     [[PersonModel alloc] initWithFirstName:@"Daniel" lastName:@"Alamo" uniqueId:@"14"],
                     [[PersonModel alloc] initWithFirstName:@"Viktor" lastName:@"Gardart" uniqueId:@"15"],
                     [[PersonModel alloc] initWithFirstName:@"Anton" lastName:@"Sotkov" uniqueId:@"16"],
                     [[PersonModel alloc] initWithFirstName:@"Guilherme" lastName:@"Rambo" uniqueId:@"17"],
                     [[PersonModel alloc] initWithFirstName:@"Rizwan" lastName:@"Ibrahim" uniqueId:@"18"],
                     [[PersonModel alloc] initWithFirstName:@"Ayush" lastName:@"Saraswat" uniqueId:@"19"],
                     [[PersonModel alloc] initWithFirstName:@"Dustin" lastName:@"Shahidehpour" uniqueId:@"20"],
                     ];

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:[UICollectionViewFlowLayout new]];
    [self.view addSubview:self.collectionView];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init]
                                           viewController:self];

    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.persons;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [PersonSectionController new];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
