//
//  IGUser.h
//  IGListDemoObjc
//
//  Created by Charles on 1/23/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGUser : NSObject
@property (nonatomic, assign) NSInteger pk;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *handle;
- (instancetype)initWithPk:(NSInteger)pk name:(NSString *)name handle:(NSString *)handle;
@end
