//
//  IGMixedDataViewController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGMixedDataViewController.h"
#import <IGListKit.h>
#import "IGExpandableSectionController.h"
#import "IGGridSectionController.h"
#import "IGUserSectionController.h"

#import "IGGridItem.h"
#import "IGUser.h"

@interface IGMixedDataViewController () <IGListAdapterDataSource>
@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSArray *allKeys;
@property (nonatomic, strong) NSDictionary *segments;
@property (nonatomic, strong) Class selectedClass;
@end

@implementation IGMixedDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - setupUI

- (void)setupUI {
    
    // Default first index is selected.
    self.selectedClass = [NSNull class];
    
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:self.allKeys];
    control.selectedSegmentIndex = 0;
    [control addTarget:self action:@selector(onControl:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = control;
    
    [self.view addSubview:self.collectionView];
    
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
}

#pragma mark - Action

- (void)onControl:(UISegmentedControl *)sender {
    self.selectedClass = self.segments[self.allKeys[sender.selectedSegmentIndex]];
    [self.adapter performUpdatesAnimated:YES completion:nil];
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    NSMutableArray *items = [@[] mutableCopy];
    for (id obj in self.data) {
        if ([[NSNull null] isKindOfClass:self.selectedClass] || [obj isKindOfClass:self.selectedClass]) {
            [items addObject:obj];
        }
    }
    return items;
}

- (IGListSectionController<IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        return [[IGExpandableSectionController alloc] init];
    } else if ([object isKindOfClass:[IGGridItem class]]) {
        return [[IGGridSectionController alloc] init];
    } else {
        return [[IGUserSectionController alloc] init];
    }
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

#pragma mark - Custom Accessors

- (IGListAdapter *)adapter {
    if (!_adapter) {
        _adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init]
                                           viewController:self
                                         workingRangeSize:0];
    }
    return _adapter;
}

- (IGListCollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[IGListCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    }
    return _collectionView;
}

- (NSArray *)data {
    if (!_data) {
        _data = @[
                  @"Maecenas faucibus mollis interdum. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit.",
                  [[IGGridItem alloc] initWithColor:[UIColor colorWithRed:237/255.0 green:73/255.0 blue:86/255.0 alpha:1] itemCount:6],
                  [[IGUser alloc] initWithPk:2 name:@"Ryan Olson" handle:@"jessie_squires"],
                  @"Praesent commodo cursus magna, vel scelerisque nisl consectetur et.",
                  [[IGGridItem alloc] initWithColor:[UIColor colorWithRed:56/255.0 green:151/255.0 blue:240/255.0 alpha:1] itemCount:5],
                  [[IGUser alloc] initWithPk:2 name:@"Oliver Rickard" handle:@"ocrickard"],
                  @"Nullam quis risus eget urna mollis ornare vel eu leo. Praesent commodo cursus magna, vel scelerisque nisl consectetur et.",
                  [[IGGridItem alloc] initWithColor:[UIColor colorWithRed:112/255.0 green:192/255.0 blue:80/255.0 alpha:1] itemCount:3],
                  [[IGUser alloc] initWithPk:2 name:@"Jessie Squires" handle:@"ryanolson"],
                  @"Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.",
                  [[IGGridItem alloc] initWithColor:[UIColor colorWithRed:163/255.0 green:42/255.0 blue:186/255.0 alpha:1] itemCount:7],
                  [[IGUser alloc] initWithPk:2 name:@"Ryan Nystrom" handle:@"_ryannystrom"]
                  ];
    }
    return _data;
}

- (NSArray *)allKeys {
    if (!_allKeys) {
        _allKeys = @[@"All", @"Colors", @"Text", @"Users"];
    }
    return _allKeys;
}

- (NSDictionary *)segments {
    if (!_segments) {
        _segments = @{
                      @"All" : [NSNull class],
                      @"Colors" : [IGGridItem class],
                      @"Text" : [NSString class],
                      @"Users" : [IGUser class]
                      };
    }
    return _segments;
}

@end
