//
//  IGListDiffExecutor.m
//  IGActionRowViewProvider
//
//  Created by Maxime Ollivier on 8/1/24.
//

#import "IGListPerformDiff.h"

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListDiff.h"
#else
#import <IGListDiffKit/IGListDiff.h>
#endif

#import "IGListTransitionData.h"

void IGListPerformDiffWithData(IGListTransitionData *_Nullable data,
                               BOOL allowsBackground,
                               IGListDiffExecutorCompletion completion) {
    if (!completion) {
        return;
    }

    if (allowsBackground) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            IGListIndexSetResult *result = IGListDiff(data.fromObjects, data.toObjects, IGListDiffEquality);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result, allowsBackground);
            });
        });
    } else {
        IGListIndexSetResult *result = IGListDiff(data.fromObjects, data.toObjects, IGListDiffEquality);
        completion(result, allowsBackground);
    }
}
