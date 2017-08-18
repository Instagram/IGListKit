//
//  ImageCell.swift
//  ModelingAndBinding
//
//  Created by Ryan Nystrom on 8/18/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit
import SDWebImage
import IGListKit

final class ImageCell: UICollectionViewCell, ListBindable {
    
    @IBOutlet weak var imageView: UIImageView!

    // MARK: ListBindable

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ImageViewModel else { return }
        imageView.sd_setImage(with: viewModel.url)
    }

}
