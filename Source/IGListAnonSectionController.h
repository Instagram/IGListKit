#import "IGListAnonSectionControllerOptionalBlocks.h"

#import <IGListKit/IGListSectionController.h>

NS_ASSUME_NONNULL_BEGIN

@interface IGListAnonSectionController : IGListSectionController

- (instancetype)initWithNumberOfItems:(NSInteger (^)(IGListAnonSectionController *sc))numberOfItems
                   sizeForItemAtIndex:(CGSize (^)(NSInteger index, IGListAnonSectionController *sc))sizeForItemsAtIndex
                   cellForItemAtIndex:(UICollectionViewCell * (^)(NSInteger index, IGListAnonSectionController *sc))cellForItemAtIndex NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNumberOfItems:(NSInteger (^)(IGListAnonSectionController *sc))numberOfItems
                   sizeForItemAtIndex:(CGSize (^)(NSInteger index, IGListAnonSectionController *sc))sizeForItemsAtIndex
                   cellForItemAtIndex:(UICollectionViewCell * (^)(NSInteger index, IGListAnonSectionController *sc))cellForItemAtIndex
              configureOptionalBlocks:(void (^)(IGListAnonSectionControllerOptionalBlocks *builder))configureOptionalBlocks;

- (instancetype)initWithNumberOfItems:(NSInteger (^)(IGListAnonSectionController *sc))numberOfItems
                   sizeForItemAtIndex:(CGSize (^)(NSInteger index, IGListAnonSectionController *sc))sizeForItemsAtIndex
                   cellForItemAtIndex:(UICollectionViewCell * (^)(NSInteger index, IGListAnonSectionController *sc))cellForItemAtIndex
              configureOptionalBlocks:(void (^)(IGListAnonSectionControllerOptionalBlocks *builder))configureOptionalBlocks
                    initialSetupBlock:(void (^)(IGListAnonSectionController *sc))initialSetupBlock;

@property (nonatomic, readonly, strong) id object;

@end

NS_ASSUME_NONNULL_END
