/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListAdapterProxy.h"

#import <IGListKit/IGListAssert.h>
#import "IGListCollectionViewDelegateLayout.h"

/**
 Define messages that you want the IGListAdapter object to intercept. Pattern copied from
 https://github.com/facebook/AsyncDisplayKit/blob/7b112a2dcd0391ddf3671f9dcb63521f554b78bd/AsyncDisplayKit/ASCollectionView.mm#L34-L53
 */
static BOOL isInterceptedSelector(SEL sel) {
    return (
            // UIScrollViewDelegate
            sel == @selector(scrollViewDidScroll:) ||
            sel == @selector(scrollViewWillBeginDragging:) ||
            sel == @selector(scrollViewDidEndDragging:willDecelerate:) ||
            sel == @selector(scrollViewDidEndDecelerating:) ||
            // UICollectionViewDelegate
            sel == @selector(collectionView:willDisplayCell:forItemAtIndexPath:) ||
            sel == @selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:) ||
            sel == @selector(collectionView:didSelectItemAtIndexPath:) ||
            sel == @selector(collectionView:didHighlightItemAtIndexPath:) ||
            sel == @selector(collectionView:didUnhighlightItemAtIndexPath:) ||
            // UICollectionViewDelegateFlowLayout
            sel == @selector(collectionView:layout:sizeForItemAtIndexPath:) ||
            sel == @selector(collectionView:layout:insetForSectionAtIndex:) ||
            sel == @selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:) ||
            sel == @selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:) ||
            sel == @selector(collectionView:layout:referenceSizeForFooterInSection:) ||
            sel == @selector(collectionView:layout:referenceSizeForHeaderInSection:) ||
            sel == @selector(collectionView:layout:referenceSizeForHeaderInSection:) ||
            // UIScrollViewDelegate
            sel == @selector(scrollViewDidScroll:) ||
            sel == @selector(scrollViewWillBeginDragging:) ||
            sel == @selector(scrollViewDidEndDragging:willDecelerate:) ||
            sel == @selector(scrollViewDidEndDecelerating:) ||
            // IGListCollectionViewDelegateLayout
            sel == @selector(collectionView:layout:customizedInitialLayoutAttributes:atIndexPath:) ||
            sel == @selector(collectionView:layout:customizedFinalLayoutAttributes:atIndexPath:)
            );
}

@interface IGListAdapterProxy () {
    __weak id _collectionViewTarget;
    __weak id _scrollViewTarget;
    __weak IGListAdapter *_interceptor;
}

@end

@implementation IGListAdapterProxy

- (instancetype)initWithCollectionViewTarget:(nullable id<UICollectionViewDelegate>)collectionViewTarget
                            scrollViewTarget:(nullable id<UIScrollViewDelegate>)scrollViewTarget
                                 interceptor:(IGListAdapter *)interceptor {
    IGParameterAssert(interceptor != nil);
    // -[NSProxy init] is undefined
    if (self) {
        _collectionViewTarget = collectionViewTarget;
        _scrollViewTarget = scrollViewTarget;
        _interceptor = interceptor;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return isInterceptedSelector(aSelector)
    || [_collectionViewTarget respondsToSelector:aSelector]
    || [_scrollViewTarget respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (isInterceptedSelector(aSelector)) {
        return _interceptor;
    }

    // since UICollectionViewDelegate is a superset of UIScrollViewDelegate, first check if the method exists in
    // _scrollViewTarget, otherwise use the _collectionViewTarget
    return [_scrollViewTarget respondsToSelector:aSelector] ? _scrollViewTarget : _collectionViewTarget;
}

// handling unimplemented methods and nil target/interceptor
// https://github.com/Flipboard/FLAnimatedImage/blob/76a31aefc645cc09463a62d42c02954a30434d7d/FLAnimatedImage/FLAnimatedImage.m#L786-L807
- (void)forwardInvocation:(NSInvocation *)invocation {
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

@end
