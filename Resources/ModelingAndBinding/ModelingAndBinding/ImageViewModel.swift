//
//  ImageViewModel.swift
//  ModelingAndBinding
//
//  Created by Ryan Nystrom on 8/18/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import Foundation
import IGListKit

final class ImageViewModel: ListDiffable {

    let url: URL

    init(url: URL) {
        self.url = url
    }

    // MARK: ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return "image" as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ImageViewModel else { return false }
        return url == object.url
    }

}
