/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "PostSectionController.h"

#import "CommentCell.h"
#import "InteractiveCell.h"
#import "PhotoCell.h"
#import "Post.h"
#import "UserInfoCell.h"

static NSInteger cellsBeforeComments = 3;

@implementation PostSectionController {
    Post *_post;
}

#pragma mark - IGListSectionController Overrides

- (NSInteger)numberOfItems {
    return cellsBeforeComments + _post.comments.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    const CGFloat width = self.collectionContext.containerSize.width;
    CGFloat height;
    if (index == 0 || index == 2) {
        height = 41.0;
    } else if (index == 1) {
        height = width; // square
    } else {
        height = 25.0;
    }
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    Class cellClass;
    if (index == 0) {
        cellClass = [UserInfoCell class];
    } else if (index == 1) {
        cellClass = [PhotoCell class];
    } else if (index == 2) {
        cellClass = [InteractiveCell class];
    } else {
        cellClass = [CommentCell class];
    }
    id cell = [self.collectionContext dequeueReusableCellOfClass:cellClass forSectionController:self atIndex:index];
    if ([cell isKindOfClass:[CommentCell class]]) {
        [(CommentCell *)cell setComment:_post.comments[index - cellsBeforeComments]];
    } else if ([cell isKindOfClass:[UserInfoCell class]]) {
        [(UserInfoCell *)cell setName:_post.username];
    }
    return cell;
}

- (void)didUpdateToObject:(id)object {
    _post = object;
}

@end
