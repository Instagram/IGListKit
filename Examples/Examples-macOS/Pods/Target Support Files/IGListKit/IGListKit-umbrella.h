#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "IGListKit/IGListKit.h"
#import "IGListDiffKit/IGListAssert.h"
#import "IGListDiffKit/IGListBatchUpdateData.h"
#import "IGListDiffKit/IGListCompatibility.h"
#import "IGListDiffKit/IGListDiff.h"
#import "IGListDiffKit/IGListDiffable.h"
#import "IGListDiffKit/IGListDiffKit.h"
#import "IGListDiffKit/IGListExperiments.h"
#import "IGListDiffKit/IGListIndexPathResult.h"
#import "IGListDiffKit/IGListIndexSetResult.h"
#import "IGListDiffKit/IGListMacros.h"
#import "IGListDiffKit/IGListMoveIndex.h"
#import "IGListDiffKit/IGListMoveIndexPath.h"
#import "IGListDiffKit/NSNumber+IGListDiffable.h"
#import "IGListDiffKit/NSString+IGListDiffable.h"

FOUNDATION_EXPORT double IGListKitVersionNumber;
FOUNDATION_EXPORT const unsigned char IGListKitVersionString[];

