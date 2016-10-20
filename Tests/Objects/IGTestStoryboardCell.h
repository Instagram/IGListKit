//
//  IGTestStoryboardCell.h
//  IGListKit
//
//  Created by Bofei Zhu on 10/20/16.
//  Copyright © 2016 Instagram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGTestStoryboardCell : UICollectionViewCell

@property (nonatomic, weak) id delegate;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
