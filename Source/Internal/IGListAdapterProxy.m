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

/**
 Define messages that you want the IGListAdapter object to intercept.
 */
static BOOL isInterceptedSelector(SEL sel) {
    static NSSet<NSString *> *sels;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sels = [NSSet setWithObjects:
                // UICollectionViewDelegate
                NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)),
                NSStringFromSelector(@selector(collectionView:willDisplayCell:forItemAtIndexPath:)),
                NSStringFromSelector(@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)),
                NSStringFromSelector(@selector(collectionView:didHighlightItemAtIndexPath:)),
                NSStringFromSelector(@selector(collectionView:didUnhighlightItemAtIndexPath:)),
                // UICollectionViewDelegateFlowLayout
                NSStringFromSelector(@selector(collectionView:layout:sizeForItemAtIndexPath:)),
                NSStringFromSelector(@selector(collectionView:layout:insetForSectionAtIndex:)),
                NSStringFromSelector(@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)),
                NSStringFromSelector(@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)),
                NSStringFromSelector(@selector(collectionView:layout:referenceSizeForFooterInSection:)),
                NSStringFromSelector(@selector(collectionView:layout:referenceSizeForHeaderInSection:)),
                // UIScrollViewDelegate
                NSStringFromSelector(@selector(scrollViewDidScroll:)),
                NSStringFromSelector(@selector(scrollViewWillBeginDragging:)),
                NSStringFromSelector(@selector(scrollViewDidEndDragging:willDecelerate:)),
                NSStringFromSelector(@selector(scrollViewDidEndDecelerating:)),
                nil];
    });
    return [sels containsObject:NSStringFromSelector(sel)];
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
