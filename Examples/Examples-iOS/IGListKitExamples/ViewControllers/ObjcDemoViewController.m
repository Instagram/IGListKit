/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "ObjcDemoViewController.h"
#import <IGListKit/IGListKit.h>

#import "UserInfoSectionController.h"
#import "ImageSectionController.h"
#import "InteractiveSectionController.h"
#import "CommentSectionController.h"

#import "UserInfo.h"
#import "PhotoCell.h"

@interface ObjcDemoViewController () <IGListAdapterDataSource>
@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) NSArray *data;
@end

@implementation ObjcDemoViewController

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
    return self.data;
}

- (IGListSectionController<IGListSectionType> *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@"Image-Placeholder-String"]) {
            return [[ImageSectionController alloc] init];
        } else if ([object length]) {
            return [[CommentSectionController alloc] init];
        } else {
            return [[InteractiveSectionController alloc] init];
        }
    } else {
        return [[UserInfoSectionController alloc] init];
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
        UserInfo *userA = [[UserInfo alloc] initWithName:@"userA"];
        UserInfo *userB = [[UserInfo alloc] initWithName:@"userB"];
        UserInfo *userC = [[UserInfo alloc] initWithName:@"userC"];
        UserInfo *userD = [[UserInfo alloc] initWithName:@"userD"];
        
        _data = @[userA,
                  @"Image-Placeholder-String",
                  @"", @"Luminous triangle",
                  @"Awesome",
                  @"Super clean",
                  @"Stunning shot",
                  userB,
                  @"Image-Placeholder-String",
                  @"",
                  @"The simplicity here is superb",
                  @"thanks!", @"That's always so kind of you!",
                  @"I think you might like this",
                  userC,
                  @"Image-Placeholder-String",
                  @"",
                  @"So good comment",
                  userD,
                  @"Image-Placeholder-String",
                  @"",
                  @"hope she might like it.",
                  @"I love it."];
    }
    return _data;
}

@end
