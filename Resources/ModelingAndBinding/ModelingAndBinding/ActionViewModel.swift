//
//  ActionViewModel.swift
//  ModelingAndBinding
//
//  Created by Ryan Nystrom on 8/18/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import Foundation
import IGListKit

final class ActionViewModel: ListDiffable {

    let likes: Int

    init(likes: Int) {
        self.likes = likes
    }

    // MARK: ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return "action" as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ActionViewModel else { return false }
        return likes == object.likes
    }
    
}
