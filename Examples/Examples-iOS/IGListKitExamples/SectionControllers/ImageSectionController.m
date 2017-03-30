/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "ImageSectionController.h"
#import "PhotoCell.h"

@interface ImageSectionController () <IGListSupplementaryViewSource>

@end

@implementation ImageSectionController

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, self.collectionContext.containerSize.width);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    PhotoCell *cell = [self.collectionContext dequeueReusableCellOfClass:[PhotoCell class] forSectionController:self atIndex:index];
    return cell;
}

- (void)didUpdateToObject:(id)object {
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    
}

- (id<IGListSupplementaryViewSource>)supplementaryViewSource {
    return self;
}

- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionFooter];
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 30);
}

- (UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    UICollectionReusableView *view = [self.collectionContext dequeueReusableSupplementaryViewOfKind:elementKind forSectionController:self class:[UICollectionReusableView class] atIndex:index];
    view.backgroundColor = [UIColor yellowColor];
    return view;
}

@end
