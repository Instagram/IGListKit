//
//  IGDemoItem.m
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGDemoItem.h"

@interface IGDemoItem ()

@end

@implementation IGDemoItem

#pragma mark - Public

- (instancetype)initWithName:(NSString *)name controller:(UIViewController *)controller {
    if (self = [super init]) {
        self.name = name;
        self.controller = controller;
    }
    return self;
}

#pragma mark - IGListDiffable

- (nonnull id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object {
    return [self isEqualToDiffableObject:object];
}

@end
