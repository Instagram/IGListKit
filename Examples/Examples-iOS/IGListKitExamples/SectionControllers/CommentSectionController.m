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

#import "CommentSectionController.h"
#import "CommentCell.h"

@interface CommentSectionController ()
@property (nonatomic, strong) NSString *comment;
@end

@implementation CommentSectionController

#pragma mark - IGListSectionType

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 25);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    CommentCell *cell = [self.collectionContext dequeueReusableCellOfClass:[CommentCell class] forSectionController:self atIndex:index];
    cell.comment = self.comment;
    return cell;
}

- (void)didUpdateToObject:(id)object {
    self.comment = object;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    
}

@end
