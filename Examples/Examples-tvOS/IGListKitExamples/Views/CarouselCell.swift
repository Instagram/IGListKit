//
//  CarouselCell.swift
//  IGListKitExamples
//
//  Created by Sherlock, James (Apprentice Software Developer) on 29/10/2016.
//  Copyright © 2016 Instagram. All rights reserved.
//

import UIKit

final class CarouselCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        let normalColor = UIColor(red: 174 / 255.0, green: 198 / 255.0, blue: 207 / 255.0, alpha: 1)
        let focusColor = UIColor(red: 117 / 255.0, green: 155 / 255.0, blue: 169 / 255.0, alpha: 1)

        backgroundColor = isFocused ? focusColor : normalColor
    }
}
