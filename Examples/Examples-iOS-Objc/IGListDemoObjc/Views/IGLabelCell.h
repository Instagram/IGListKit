//
//  IGLabelCell.h
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGLabelCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) CGFloat singleLineHeight;
- (CGFloat)textHeightWithText:(NSString *)text width:(CGFloat)width;
@end
