/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListWorkingRangeHandler.h"

#import <set>
#import <unordered_set>
#import <vector>

#import <IGListKit/IGListAssert.h>
#import <IGListKit/IGListAdapter.h>
#import <IGListKit/IGListSectionController.h>
#import <IGListKit/IGListWorkingRangeDelegate.h>

#import "IGListWorkingRangeDelegate.h"

struct _IGListWorkingRangeHandlerIndexPath {
    NSInteger section;
    NSInteger row;
    size_t hash;

    bool operator==(const _IGListWorkingRangeHandlerIndexPath &other) const {
        return (section == other.section && row == other.row);
    }
};

struct _IGListWorkingRangeHandlerSectionControllerWrapper {
    IGListSectionController *sectionController;

    bool operator==(const _IGListWorkingRangeHandlerSectionControllerWrapper &other) const {
        return (sectionController == other.sectionController);
    }
};

struct _IGListWorkingRangeHandlerIndexPathHash {
    size_t operator()(const _IGListWorkingRangeHandlerIndexPath& o) const {
        return (size_t)o.hash;
    }
};

struct _IGListWorkingRangeHashID {
    size_t operator()(const _IGListWorkingRangeHandlerSectionControllerWrapper &o) const {
        return (size_t)[o.sectionController hash];
    }
};

typedef std::unordered_set<_IGListWorkingRangeHandlerSectionControllerWrapper, _IGListWorkingRangeHashID> _IGListWorkingRangeSectionControllerSet;
typedef std::unordered_set<_IGListWorkingRangeHandlerIndexPath, _IGListWorkingRangeHandlerIndexPathHash> _IGListWorkingRangeIndexPathSet;

@interface IGListWorkingRangeHandler ()

@property (nonatomic, assign, readonly) NSInteger workingRangeSize;

@end

@implementation IGListWorkingRangeHandler {
    _IGListWorkingRangeIndexPathSet _visibleSectionIndices;
    _IGListWorkingRangeSectionControllerSet _workingRangeSectionControllers;
}

- (instancetype)initWithWorkingRangeSize:(NSInteger)workingRangeSize {
    if (self = [super init]) {
        _workingRangeSize = workingRangeSize;
    }
    return self;
}

- (void)willDisplayItemAtIndexPath:(NSIndexPath *)indexPath
                    forListAdapter:(IGListAdapter *)listAdapter {
    IGParameterAssert(indexPath != nil);
    IGParameterAssert(listAdapter != nil);

    _visibleSectionIndices.insert({
        .section = indexPath.section,
        .row = indexPath.row,
        .hash = indexPath.hash
    });

    [self updateWorkingRangesWithListAdapter:listAdapter];
}

- (void)didEndDisplayingItemAtIndexPath:(NSIndexPath *)indexPath
                         forListAdapter:(IGListAdapter *)listAdapter {
    IGParameterAssert(indexPath != nil);
    IGParameterAssert(listAdapter != nil);

    _visibleSectionIndices.erase({
        .section = indexPath.section,
        .row = indexPath.row,
        .hash = indexPath.hash
    });

    [self updateWorkingRangesWithListAdapter:listAdapter];
}

#pragma mark - Working Ranges

- (void)updateWorkingRangesWithListAdapter:(IGListAdapter *)listAdapter {
    IGAssertMainThread();
    // This method is optimized C++ to improve straight-line speed of these operations. Change at your peril.

    // We use a std::set because it is ordered.
    std::set<NSInteger> visibleSectionSet = std::set<NSInteger>();
    for (const _IGListWorkingRangeHandlerIndexPath &indexPath : _visibleSectionIndices) {
        visibleSectionSet.insert(indexPath.section);
    }

    NSInteger start;
    NSInteger end;
    if (visibleSectionSet.size() == 0) {
        // We're now devoid of any visible sections. Bail
        start = 0;
        end = 0;
    } else {
        start = MAX(*visibleSectionSet.begin() - _workingRangeSize, 0);
        end = MIN(*visibleSectionSet.rbegin() + 1 + _workingRangeSize, (NSInteger)listAdapter.objects.count);
    }

    // Build the current set of working range section controllers
    _IGListWorkingRangeSectionControllerSet workingRangeSectionControllers (visibleSectionSet.size());
    for (NSInteger idx = start; idx < end; idx++) {
        id item = [listAdapter objectAtSection:idx];
        IGListSectionController *sectionController = [listAdapter sectionControllerForObject:item];
        workingRangeSectionControllers.insert({sectionController});
    }

    IGAssert(workingRangeSectionControllers.size() < 1000, @"This algorithm is way too slow with so many objects:%lu", workingRangeSectionControllers.size());

    // Tell any new section controllers that they have entered the working range
    for (const _IGListWorkingRangeHandlerSectionControllerWrapper &wrapper : workingRangeSectionControllers) {
        // Check if the item exists in the old working range item array.
        auto it = _workingRangeSectionControllers.find(wrapper);
        if (it == _workingRangeSectionControllers.end()) {
            // The section controller isn't in the existing list, so it's new.
            id <IGListWorkingRangeDelegate> workingRangeDelegate = wrapper.sectionController.workingRangeDelegate;
            [workingRangeDelegate listAdapter:listAdapter sectionControllerWillEnterWorkingRange:wrapper.sectionController];
        }
    }

    // Tell any removed section controllers that they have exited the working range
    for (const _IGListWorkingRangeHandlerSectionControllerWrapper &wrapper : _workingRangeSectionControllers) {
        // Check if the item exists in the new list of section controllers
        auto it = workingRangeSectionControllers.find(wrapper);
        if (it == workingRangeSectionControllers.end()) {
            // If the item does not exist in the new list, then it's been removed.
            id <IGListWorkingRangeDelegate> workingRangeDelegate = wrapper.sectionController.workingRangeDelegate;
            [workingRangeDelegate listAdapter:listAdapter sectionControllerDidExitWorkingRange:wrapper.sectionController];
        }
    }

    _workingRangeSectionControllers = workingRangeSectionControllers;
}

@end
