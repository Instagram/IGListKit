//
//  IGUser.m
//  IGListDemoObjc
//
//  Created by Charles on 1/23/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGUser.h"
#import <IGListKit.h>

@interface IGUser () <IGListDiffable>

@end

@implementation IGUser

- (instancetype)initWithPk:(NSInteger)pk name:(NSString *)name handle:(NSString *)handle {
    if (self = [super init]) {
        self.pk = pk;
        self.name = name;
        self.handle = handle;
    }
    return self;
}

#pragma mark - IGListDiffable

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return [self isEqualToDiffableObject:object];
}

@end
