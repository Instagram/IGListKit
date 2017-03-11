//
//  MonthTitleViewModel.swift
//  IGListKitExamples
//
//  Created by Ryan Nystrom on 3/11/17.
//  Copyright © 2017 Instagram. All rights reserved.
//

import Foundation
import IGListKit

final class MonthTitleViewModel {
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
}

extension MonthTitleViewModel: IGListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return name as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
        if self === object { return true }
        guard object is MonthTitleViewModel else { return false }
        // name is checked in the diffidentifier, so we can assume its equal
        return true
    }
    
}
