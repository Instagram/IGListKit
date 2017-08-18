//
//  ActionCell.swift
//  ModelingAndBinding
//
//  Created by Ryan Nystrom on 8/18/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit
import IGListKit

protocol ActionCellDelegate: class {
    func didTapHeart(cell: ActionCell)
}

final class ActionCell: UICollectionViewCell, ListBindable {

    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    weak var delegate: ActionCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        likeButton.addTarget(self, action: #selector(ActionCell.onHeart), for: .touchUpInside)
    }

    func onHeart() {
        delegate?.didTapHeart(cell: self)
    }

    // MARK: ListBindable

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ActionViewModel else { return }
        likesLabel.text = "\(viewModel.likes)"
    }
    
}
