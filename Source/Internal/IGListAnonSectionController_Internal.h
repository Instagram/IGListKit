#import "IGListAnonSectionController.h"

@interface IGListAnonSectionController ()

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithNumberOfItems:(NSInteger (^)(IGListAnonSectionController *))numberOfItems
                   sizeForItemAtIndex:(CGSize (^)(NSInteger index, IGListAnonSectionController *))sizeForItemsAtIndex
                   cellForItemAtIndex:(UICollectionViewCell * (^)(NSInteger index, IGListAnonSectionController *))cellForItemAtIndex NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy) NSInteger (^numberOfItemsBlock)(IGListAnonSectionController *);
@property (nonatomic, copy) CGSize (^sizeForItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) UICollectionViewCell * (^cellForItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) void (^didSelectItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) void (^didDeselectItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) void (^didHighlightItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) void (^didUnhighlightItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) BOOL (^canMoveItemAtIndexBlock)(NSInteger, IGListAnonSectionController *);
@property (nonatomic, copy) void (^moveObjectFromIndexToIndexBlock)(NSInteger, NSInteger, IGListAnonSectionController *);

@end
