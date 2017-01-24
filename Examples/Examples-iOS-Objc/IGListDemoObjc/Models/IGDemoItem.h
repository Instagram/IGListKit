//
//  IGDemoItem.h
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <IGListKit.h>

@interface IGDemoItem : NSObject <IGListDiffable>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIViewController *controller;
- (instancetype)initWithName:(NSString *)name controller:(UIViewController *)controller;
@end
