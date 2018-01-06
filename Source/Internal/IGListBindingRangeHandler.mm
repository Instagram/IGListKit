/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListBindingRangeHandler.h"

#import <set>

#import <IGListKit/IGListAssert.h>
#import <IGListKit/IGListBindingSectionController.h>

@interface IGListBindingRangeHandler ()

@property (nonatomic, assign, readonly) NSInteger bindingRangeSize;

@end

@implementation IGListBindingRangeHandler {
    std::set<NSInteger> _visibleItemIndices;
    NSRange _bindingRange;
}

- (instancetype)initWithBindingRangeSize:(NSInteger)bindingRangeSize {
    if (self = [super init]) {
        _bindingRangeSize = bindingRangeSize;
        _bindingRange = NSMakeRange(0, 0);
    }
    return self;
}

- (void)willBindItemAtIndex:(NSInteger)index
       forSectionController:(IGListBindingSectionController *)sectionController {
    IGParameterAssert(sectionController != nil);
    
    _visibleItemIndices.insert(index);
    
    [self updateBindingRangesWithSectionController:sectionController];
}

- (void)didEndBindingItemAtIndex:(NSInteger)index
            forSectionController:(IGListBindingSectionController *)sectionController {
    IGParameterAssert(sectionController != nil);
    
    _visibleItemIndices.erase(index);
    
    [self updateBindingRangesWithSectionController:sectionController];
}

#pragma mark - Binding Ranges

- (void)updateBindingRangesWithSectionController:(IGListBindingSectionController *)sectionController {
    IGAssertMainThread();
    
    NSRange bindingRange = NSMakeRange(0, 0);
    if (_visibleItemIndices.size() > 0) {
        NSInteger start = MAX(*_visibleItemIndices.begin() - _bindingRangeSize, 0);
        NSInteger end = MIN(*_visibleItemIndices.rbegin() + 1 + _bindingRangeSize, (NSInteger)sectionController.viewModels.count);
        bindingRange = NSMakeRange(start, end - start);
    }
    
    // Tell any new items that they have entered the binding range
    for (NSInteger idx = _bindingRange.location + _bindingRange.length; idx < bindingRange.location + bindingRange.length; idx++) {
        [sectionController.bindingRangeDelegate sectionController:sectionController itemAtIndexWillEnterBindingRange:idx];
    }
    
    for (NSInteger idx = _bindingRange.location - 1; idx >= 0 && idx >= bindingRange.location; idx--) {
        [sectionController.bindingRangeDelegate sectionController:sectionController itemAtIndexWillEnterBindingRange:idx];
    }
    
    // Tell any removed items that they have exited the binding range
    for (NSInteger idx = _bindingRange.location + _bindingRange.length - 1; idx >= 0 && idx >= bindingRange.location + bindingRange.length; idx--) {
        [sectionController.bindingRangeDelegate sectionController:sectionController itemAtIndexDidExitBindingRange:idx];
    }
    
    for (NSInteger idx = _bindingRange.location; idx < bindingRange.location; idx++) {
        [sectionController.bindingRangeDelegate sectionController:sectionController itemAtIndexDidExitBindingRange:idx];
    }
    
    _bindingRange = bindingRange;
}

@end
