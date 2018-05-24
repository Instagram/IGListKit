#import "IGListAnonSectionController_Internal.h"

@interface IGListAnonSectionController ()

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

@implementation IGListAnonSectionController

- (instancetype)init {
    @throw nil;
}

- (instancetype)initWithNumberOfItems:(NSInteger (^)(IGListAnonSectionController *))numberOfItems
                   sizeForItemAtIndex:(CGSize (^)(NSInteger index, IGListAnonSectionController *))sizeForItemsAtIndex
                   cellForItemAtIndex:(UICollectionViewCell * (^)(NSInteger index, IGListAnonSectionController *))cellForItemAtIndex {
    if (self = [super init]) {
        self.numberOfItemsBlock = numberOfItems;
        self.sizeForItemAtIndexBlock = sizeForItemsAtIndex;
        self.cellForItemAtIndexBlock = cellForItemAtIndex;
    }
    return self;
}

- (instancetype)initWithNumberOfItems:(NSInteger (^)(IGListAnonSectionController *sc))numberOfItems
                   sizeForItemAtIndex:(CGSize (^)(NSInteger index, IGListAnonSectionController *sc))sizeForItemsAtIndex
                   cellForItemAtIndex:(UICollectionViewCell * (^)(NSInteger index, IGListAnonSectionController *sc))cellForItemAtIndex
              configureOptionalBlocks:(void (^)(IGListAnonSectionControllerOptionalBlocks *builder))configureOptionalBlocks {
    if (self = [self initWithNumberOfItems:numberOfItems
                        sizeForItemAtIndex:sizeForItemsAtIndex
                        cellForItemAtIndex:cellForItemAtIndex]) {
        if (configureOptionalBlocks) {
            IGListAnonSectionControllerOptionalBlocks *builder = [IGListAnonSectionControllerOptionalBlocks new];
            configureOptionalBlocks(builder);
            self.didSelectItemAtIndexBlock = builder.didSelectItemAtIndexBlock;
            self.didDeselectItemAtIndexBlock = builder.didDeselectItemAtIndexBlock;
            self.didHighlightItemAtIndexBlock = builder.didHighlightItemAtIndexBlock;
            self.didUnhighlightItemAtIndexBlock = builder.didUnhighlightItemAtIndexBlock;
            self.canMoveItemAtIndexBlock = builder.canMoveItemAtIndexBlock;
            self.moveObjectFromIndexToIndexBlock = builder.moveObjectFromIndexToIndexBlock;
        }
    }
    return self;
}

- (instancetype)initWithNumberOfItems:(NSInteger (^)(IGListAnonSectionController *sc))numberOfItems
                   sizeForItemAtIndex:(CGSize (^)(NSInteger index, IGListAnonSectionController *sc))sizeForItemsAtIndex
                   cellForItemAtIndex:(UICollectionViewCell * (^)(NSInteger index, IGListAnonSectionController *sc))cellForItemAtIndex
              configureOptionalBlocks:(void (^)(IGListAnonSectionControllerOptionalBlocks *builder))configureOptionalBlocks
                    initialSetupBlock:(void (^)(IGListAnonSectionController *sc))initialSetupBlock {
    if (self = [self initWithNumberOfItems:numberOfItems
                        sizeForItemAtIndex:sizeForItemsAtIndex
                        cellForItemAtIndex:cellForItemAtIndex
                       configureOptionalBlocks:configureOptionalBlocks]) {
        if (initialSetupBlock) {
            initialSetupBlock(self);
        }
    }
    return self;
}

- (void)didUpdateToObject:(id)object {
    _object = object;
}

- (NSInteger)numberOfItems {
    if (self.numberOfItemsBlock) {
        return self.numberOfItemsBlock(self);
    }
    return [super numberOfItems];
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    if (self.sizeForItemAtIndexBlock) {
        return self.sizeForItemAtIndexBlock(index, self);
    }
    return [super sizeForItemAtIndex:index];
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    if (self.cellForItemAtIndexBlock) {
        return self.cellForItemAtIndexBlock(index, self);
    }
    return [super cellForItemAtIndex:index];
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    if (self.didSelectItemAtIndexBlock) {
        self.didSelectItemAtIndexBlock(index, self);
        return;
    }
    [super didSelectItemAtIndex:index];
}

- (void)didDeselectItemAtIndex:(NSInteger)index {
    if (self.didDeselectItemAtIndexBlock) {
        self.didDeselectItemAtIndexBlock(index, self);
        return;
    }
    [super didDeselectItemAtIndex:index];
}

- (void)didHighlightItemAtIndex:(NSInteger)index {
    if (self.didHighlightItemAtIndexBlock) {
        self.didHighlightItemAtIndexBlock(index, self);
        return;
    }
    [super didHighlightItemAtIndex:index];
}

- (void)didUnhighlightItemAtIndex:(NSInteger)index {
    if (self.didUnhighlightItemAtIndexBlock) {
        self.didUnhighlightItemAtIndexBlock(index, self);
        return;
    }
    [super didUnhighlightItemAtIndex:index];
}

- (BOOL)canMoveItemAtIndex:(NSInteger)index {
    if (self.canMoveItemAtIndexBlock) {
        return self.canMoveItemAtIndexBlock(index, self);
    }
    return [super canMoveItemAtIndex:index];
}

- (void)moveObjectFromIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex {
    if (self.moveObjectFromIndexToIndexBlock) {
        self.moveObjectFromIndexToIndexBlock(sourceIndex, destinationIndex, self);
        return;
    }
    [super moveObjectFromIndex:sourceIndex toIndex:destinationIndex];
}

@end
