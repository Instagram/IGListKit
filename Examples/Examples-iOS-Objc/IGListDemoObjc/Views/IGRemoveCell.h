//
//  IGRemoveCell.h
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IGRemoveCell;

@protocol IGRemoveCellDelegate <NSObject>

- (void)removeCellDidTapButton:(IGRemoveCell *)removeCell;

@end

@interface IGRemoveCell : UICollectionViewCell
@property (nonatomic, weak) id<IGRemoveCellDelegate> delegate;
@property (nonatomic, strong) UILabel *label;
@end
