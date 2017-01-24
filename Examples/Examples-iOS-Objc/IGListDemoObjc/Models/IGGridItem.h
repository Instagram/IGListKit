//
//  IGGridItem.h
//  IGListDemoObjc
//
//  Created by Charles on 1/23/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IGGridItem : NSObject
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) NSUInteger itemCount;
- (instancetype)initWithColor:(UIColor *)color itemCount:(NSUInteger)itemCount;
@end
