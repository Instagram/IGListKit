//
//  IGRemoveSectionController.h
//  IGListDemoObjc
//
//  Created by Charles on 1/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <IGListKit/IGListKit.h>

@class IGRemoveSectionController;

@protocol IGRemoveSectionControllerDelegate <NSObject>

- (void)removeSectionControllerwantsRemove:(IGRemoveSectionController *)removeSectionControlller;

@end

@interface IGRemoveSectionController : IGListSectionController <IGListSectionType>
@property (nonatomic, weak) id<IGRemoveSectionControllerDelegate> delegate;
@end
