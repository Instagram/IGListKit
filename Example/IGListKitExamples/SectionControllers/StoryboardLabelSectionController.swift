//
//  StoryboardLabelSectionController.swift
//  IGListKitExamples
//
//  Created by Bofei Zhu on 10/20/16.
//  Copyright © 2016 Instagram. All rights reserved.
//

import UIKit
import IGListKit

class StoryboardLabelSectionController: IGListSectionController, IGListSectionType {
    
    var object: String?
    
    func numberOfItems() -> Int {
        return 1
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        //let cell = collectionContext!.dequeueReusableCell(of: LabelCell.self, for: self, at: index) as! LabelCell
        let cell = collectionContext!.dequeueReusableCellFromStoryboard(withIdentifier: "cell", for: self, at: index) as! StoryboardCell
        cell.textLabel.text = object
        return cell
    }
    
    func didUpdate(to object: Any) {
        self.object = object as? String
    }
    
    func didSelectItem(at index: Int) {}
    
}
