/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "IGListAdapter+DebugDescription.h"

#import "IGListAdapterInternal.h"
#import "IGListAdapterUpdater+DebugDescription.h"
#import "IGListDebuggingUtilities.h"
#import "IGListSectionMap+DebugDescription.h"
#import "UICollectionView+DebugDescription.h"

@implementation IGListAdapter (DebugDescription)

- (NSString *)debugDescription {
    NSMutableArray *lines = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"IGListAdapter %p:", self]];
    [lines addObjectsFromArray:IGListDebugIndentedLines([self debugDescriptionLines])];
    return [lines componentsJoinedByString:@"\n"];
}

- (NSArray<NSString *> *)debugDescriptionLines {
    NSMutableArray *debug = [NSMutableArray new];
#if IGLK_DEBUG_DESCRIPTION_ENABLED
    [debug addObject:[NSString stringWithFormat:@"Updater type: %@", NSStringFromClass(self.updater.class)]];
    [debug addObject:[NSString stringWithFormat:@"Data source: %@", self.dataSource]];
    [debug addObject:[NSString stringWithFormat:@"Collection view delegate: %@", self.collectionViewDelegate]];
    [debug addObject:[NSString stringWithFormat:@"Scroll view delegate: %@", self.scrollViewDelegate]];
    [debug addObject:[NSString stringWithFormat:@"Is in update block: %@", IGListDebugBOOL(self.isInUpdateBlock)]];
    [debug addObject:[NSString stringWithFormat:@"View controller: %@", self.viewController]];
    if (@available(iOS 10.0, tvOS 10, *)) {
        [debug addObject:[NSString stringWithFormat:@"Is prefetching enabled: %@", IGListDebugBOOL(self.collectionView.isPrefetchingEnabled)]];
    }

    if (self.registeredCellIdentifiers.count > 0) {
        [debug addObject:@"Registered cell identifiers:"];
        [debug addObject:[self.registeredCellIdentifiers description]];
    }

    if (self.registeredNibNames.count > 0) {
        [debug addObject:@"Registered nib names:"];
        [debug addObject:[self.registeredNibNames description]];
    }

    if (self.registeredSupplementaryViewIdentifiers.count > 0) {
        [debug addObject:@"Registered supplementary view identifiers:"];
        [debug addObject:[self.registeredSupplementaryViewIdentifiers description]];
    }

    if (self.registeredSupplementaryViewNibNames.count > 0) {
        [debug addObject:@"Registered supplementary view nib names:"];
        [debug addObject:self.registeredSupplementaryViewNibNames];
    }

    if ([self.updater isKindOfClass:[IGListAdapterUpdater class]]) {
        [debug addObject:[NSString stringWithFormat:@"IGListAdapterUpdater instance %p:", self.updater]];
        [debug addObjectsFromArray:IGListDebugIndentedLines([(IGListAdapterUpdater *)self.updater debugDescriptionLines])];
    }

    [debug addObject:@"Section map details:"];
    [debug addObjectsFromArray:IGListDebugIndentedLines([self.sectionMap debugDescriptionLines])];

    if (self.previousSectionMap != nil) {
        [debug addObject:@"Previous section map details:"];
        [debug addObjectsFromArray:IGListDebugIndentedLines([self.previousSectionMap debugDescriptionLines])];
    }

    [debug addObject:@"Collection view details:"];
    [debug addObjectsFromArray:IGListDebugIndentedLines([self.collectionView debugDescriptionLines])];
#endif // #if IGLK_DEBUG_DESCRIPTION_ENABLED
    return debug;
}

@end
