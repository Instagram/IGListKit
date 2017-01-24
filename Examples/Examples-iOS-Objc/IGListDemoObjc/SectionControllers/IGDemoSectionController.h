//
//  IGDemoSectionController.h
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <IGListKit/IGListKit.h>

@class IGDemoItem;

@interface IGDemoSectionController : IGListSectionController <IGListSectionType>
@property (nonatomic, strong) IGDemoItem *object;
@end
