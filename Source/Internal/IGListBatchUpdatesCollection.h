//
//  IGListBatchUpdatesCollection.h
//  IGListKit
//
//  Created by Ryan Nystrom on 1/26/17.
//  Copyright © 2017 Instagram. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IGListMoveIndex;
@class IGListMoveIndexPath;

@interface IGListBatchUpdatesCollection : NSObject

//@property (nonatomic, strong, readonly) NSMutableIndexSet *sectionInserts;
@property (nonatomic, strong, readonly) NSMutableIndexSet *sectionReloads;
//@property (nonatomic, strong, readonly) NSMutableIndexSet *sectionDeletes;
//@property (nonatomic, strong, readonly) NSMutableSet<IGListMoveIndex *> *sectionMoves;
@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *itemInserts;
@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *itemDeletes;
@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *itemReloads;
@property (nonatomic, strong, readonly) NSMutableSet<IGListMoveIndexPath *> *itemMoves;
@property (nonatomic, strong, readonly) NSMutableArray<void (^)(BOOL)> *completionBlocks;

//- (BOOL)hasChanges;

@end
