/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "IGListDebuggingUtilities.h"

#import <malloc/malloc.h>

#import <IGListKit/IGListAdapter.h>

NSString *IGListDebugBOOL(BOOL b) {
    return b ? @"Yes" : @"No";
}

NSArray<NSString *> *IGListDebugIndentedLines(NSArray<NSString *> *lines) {
    NSMutableArray *newLines = [NSMutableArray new];
    for (NSString *line in lines) {
        [newLines addObject:[NSString stringWithFormat:@"  %@", line]];
    }
    return newLines;
}

// only compile these helpers into debug builds
#if IGLK_DEBUG_DESCRIPTION_ENABLED

// concept of scanning the heap for IGListAdapter objects borrowed from FLEX
// https://github.com/Flipboard/FLEX/blob/master/Classes/Utility/FLEXHeapEnumerator.m
typedef void (^iglk_object_enumeration_block_t)(__unsafe_unretained id object);

// Mimics the objective-c object stucture for checking if a range of memory is an object.
typedef struct {
    Class isa;
} iglk_maybe_object_t;

static void range_callback(task_t task, void *context, unsigned type, vm_range_t *ranges, unsigned rangeCount) {
    iglk_object_enumeration_block_t block = (__bridge iglk_object_enumeration_block_t)context;
    if (!block) {
        return;
    }

    for (unsigned int i = 0; i < rangeCount; i++) {
        vm_range_t range = ranges[i];
        iglk_maybe_object_t *tryObject = (iglk_maybe_object_t *)range.address;
        Class tryClass = NULL;
#ifdef __arm64__
        // See http://www.sealiesoftware.com/blog/archive/2013/09/24/objc_explain_Non-pointer_isa.html
        extern uint64_t objc_debug_isa_class_mask WEAK_IMPORT_ATTRIBUTE;
        tryClass = (__bridge Class)((void *)((uint64_t)tryObject->isa & objc_debug_isa_class_mask));
#else
        tryClass = tryObject->isa;
#endif
        // If the class pointer matches one in our set of class pointers from the runtime, then we should have an object.
        if (tryClass == [IGListAdapter class]) {
            block((__bridge id)tryObject);
        }
    }
}

static kern_return_t reader(__unused task_t remote_task,
                            vm_address_t remote_address,
                            __unused vm_size_t size,
                            void **local_memory) {
    *local_memory = (void *)remote_address;
    return KERN_SUCCESS;
}

#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED

NSArray<IGListAdapter *> *IGListAllAdpaterInstances(void) {
    NSMutableArray *adapters = [NSMutableArray new];
#if IGLK_DEBUG_DESCRIPTION_ENABLED
    vm_address_t *zones = NULL;
    unsigned int zoneCount = 0;
    kern_return_t result = malloc_get_all_zones(TASK_NULL, reader, &zones, &zoneCount);

    if (result == KERN_SUCCESS) {
        iglk_object_enumeration_block_t block = ^(id adapter) {
            [adapters addObject:adapter];
        };

        for (unsigned int i = 0; i < zoneCount; i++) {
            malloc_zone_t *zone = (malloc_zone_t *)zones[i];
            if (zone->introspect && zone->introspect->enumerator) {
                zone->introspect->enumerator(TASK_NULL,
                                             (__bridge void *)block,
                                             MALLOC_PTR_IN_USE_RANGE_TYPE,
                                             (vm_address_t)zone,
                                             reader,
                                             &range_callback);
            }
        }
    }
#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED
    return adapters;
}
