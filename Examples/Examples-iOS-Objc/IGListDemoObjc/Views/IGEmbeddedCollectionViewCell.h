//
//  IGEmbeddedCollectionViewCell.h
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IGListCollectionView;

@interface IGEmbeddedCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) IGListCollectionView *collectionView;
@end
