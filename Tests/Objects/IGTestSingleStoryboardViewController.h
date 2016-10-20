//
//  IGTestSingleStoryboardViewController.h
//  IGListKit
//
//  Created by Bofei Zhu on 10/20/16.
//  Copyright © 2016 Instagram. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IGListCollectionView.h"

#import <IGListKit/IGListAdapterDataSource.h>

#import "IGTestObject.h"

@interface IGTestSingleStoryboardViewController : UIViewController <IGListAdapterDataSource>

@property (nonatomic, strong) NSArray <IGTestObject *> *objects;
@property (weak, nonatomic) IBOutlet IGListCollectionView *collectionView;

@end
