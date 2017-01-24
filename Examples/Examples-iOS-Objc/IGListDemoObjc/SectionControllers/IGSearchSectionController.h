//
//  IGSearchSectionController.h
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <IGListKit/IGListKit.h>

@class IGSearchSectionController;

@protocol IGSearchSectionControllerDelegate <NSObject>

- (void)searchSectionController:(IGSearchSectionController *)searchSectionController didChangeText:(NSString *)text;

@end

@interface IGSearchSectionController : IGListSectionController <IGListSectionType>
@property (nonatomic, weak) id<IGSearchSectionControllerDelegate> delegate;
@end
