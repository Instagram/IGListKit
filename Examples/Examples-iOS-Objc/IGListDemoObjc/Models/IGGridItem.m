//
//  IGGridItem.m
//  IGListDemoObjc
//
//  Created by Charles on 1/23/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "IGGridItem.h"
#import <IGListKit.h>

@interface IGGridItem () <IGListDiffable>

@end

@implementation IGGridItem

- (instancetype)initWithColor:(UIColor *)color itemCount:(NSUInteger)itemCount {
    if (self = [super init]) {
        self.color = color;
        self.itemCount = itemCount;
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
