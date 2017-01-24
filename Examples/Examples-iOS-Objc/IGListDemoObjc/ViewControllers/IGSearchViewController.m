//
//  IGSearchViewController.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGSearchViewController.h"
#import <IGListKit.h>
#import "IGSearchSectionController.h"
#import "IGLabelSectionController.h"

@interface IGSearchViewController () <IGListAdapterDataSource, IGSearchSectionControllerDelegate>
@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) NSMutableArray *words;
@property (nonatomic, copy) NSString *filterString;
@property (nonatomic, copy) NSString *searchToken;
@end

@implementation IGSearchViewController

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
    
    [self.view addSubview:self.collectionView];
    
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    NSMutableArray *items = [@[self.searchToken] mutableCopy];
    for (NSString *word in self.words) {
        if ([self.filterString isEqualToString:@""] || [[word lowercaseString] containsString:[self.filterString lowercaseString]]) {
            [items addObject:word];
        }
    }
    return items;
}

- (IGListSectionController<IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    if ([object isEqual:self.searchToken]) {
        IGSearchSectionController *sectionController = [[IGSearchSectionController alloc] init];
        sectionController.delegate = self;
        return sectionController;
    } else {
        return [[IGLabelSectionController alloc] init];
    }
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

#pragma mark - IGSearchSectionControllerDelegate

- (void)searchSectionController:(IGSearchSectionController *)searchSectionController didChangeText:(NSString *)text {
    self.filterString = text;
    [self.adapter performUpdatesAnimated:YES completion:nil];
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

- (NSMutableArray *)words {
    if (!_words) {
        NSString *str = @"Humblebrag skateboard tacos viral small batch blue bottle, schlitz fingerstache etsy squid. Listicle tote bag helvetica XOXO literally, meggings cardigan kickstarter roof party deep v selvage scenester venmo truffaut. You probably haven't heard of them fanny pack austin next level 3 wolf moon. Everyday carry offal brunch 8-bit, keytar banjo pinterest leggings hashtag wolf raw denim butcher. Single-origin coffee try-hard echo park neutra, cornhole banh mi meh austin readymade tacos taxidermy pug tattooed. Cold-pressed +1 ethical, four loko cardigan meh forage YOLO health goth sriracha kale chips. Mumblecore cardigan humblebrag, lo-fi typewriter truffaut leggings health goth.";
        _words = [@[] mutableCopy];
        NSRange range = NSMakeRange(0, str.length);
        [str enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            [_words addObject:substring];
        }];
    }
    return _words;
}

- (NSString *)filterString {
    if (!_filterString) {
        _filterString = @"";
    }
    return _filterString;
}

- (NSString *)searchToken {
    if (!_searchToken) {
        _searchToken = @"";
    }
    return _searchToken;
}

@end
