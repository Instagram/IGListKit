/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListBindingSectionController+DebugDescription.h"

#import "IGListDebuggingUtilities.h"

@implementation IGListBindingSectionController (DebugDescription)

- (NSString *)debugDescription {
    NSMutableArray *lines = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"IGListBindingSectionController %p:", self]];
    [lines addObjectsFromArray:IGListDebugIndentedLines([self debugDescriptionLines])];
    return [lines componentsJoinedByString:@"\n"];
}

- (NSArray<NSString *> *)debugDescriptionLines {
    NSMutableArray *debug = [NSMutableArray new];
#if IGLK_DEBUG_DESCRIPTION_ENABLED
    [debug addObject:[NSString stringWithFormat:@"Data source: %@", self.dataSource]];
    [debug addObject:[NSString stringWithFormat:@"Selection delegate: %@", self.selectionDelegate]];
    [debug addObject:[NSString stringWithFormat:@"Object: %@", self.object]];
    [debug addObject:@"View models:"];
    for (id<IGListDiffable> viewModel in self.viewModels) {
        [debug addObject:[NSString stringWithFormat:@"%@: %@", viewModel, viewModel.diffIdentifier]];
    }
    [debug addObject:[NSString stringWithFormat:@"Number of items: %ld", (long)self.numberOfItems]];
    [debug addObject:[NSString stringWithFormat:@"View controller: %@", self.viewController]];
    [debug addObject:[NSString stringWithFormat:@"Collection context: %@", self.collectionContext]];
    [debug addObject:[NSString stringWithFormat:@"Section: %ld", (long)self.section]];
    [debug addObject:[NSString stringWithFormat:@"Is first section: %@", IGListDebugBOOL(self.isFirstSection)]];
    [debug addObject:[NSString stringWithFormat:@"Is last section: %@", IGListDebugBOOL(self.isLastSection)]];
    [debug addObject:[NSString stringWithFormat:@"Supplementary view source: %@", self.supplementaryViewSource]];
    [debug addObject:[NSString stringWithFormat:@"Display delegate: %@", self.displayDelegate]];
    [debug addObject:[NSString stringWithFormat:@"Working range delegate: %@", self.workingRangeDelegate]];
    [debug addObject:[NSString stringWithFormat:@"Scroll delegate: %@", self.scrollDelegate]];
    
#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED
    return debug;
}

@end

