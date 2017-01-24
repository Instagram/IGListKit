//
//  IGLabelSectionController.h
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <IGListKit/IGListKit.h>

@interface IGLabelSectionController : IGListSectionController <IGListSectionType>
@property (nonatomic, copy) NSString *object;
@end
