#import <UIKit/UIKit.h>

@class IGListAnonSectionController;

@interface IGListAnonSectionControllerOptionalBlocks : NSObject

@property (nonatomic, copy) void (^didSelectItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) void (^didDeselectItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) void (^didHighlightItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) void (^didUnhighlightItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) BOOL (^canMoveItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) void (^moveObjectFromIndexToIndexBlock)(NSInteger, NSInteger, IGListAnonSectionController *);

@end
