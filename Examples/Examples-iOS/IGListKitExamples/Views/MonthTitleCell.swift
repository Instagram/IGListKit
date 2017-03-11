//
//  MonthTitleCell.swift
//  IGListKitExamples
//
//  Created by Ryan Nystrom on 3/11/17.
//  Copyright © 2017 Instagram. All rights reserved.
//

import UIKit
import IGListKit

final class MonthTitleCell: UICollectionViewCell {
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = UIColor(white: 0.7, alpha: 1)
        view.font = .boldSystemFont(ofSize: 13)
        self.contentView.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
}

extension MonthTitleCell: IGListBindable {
    
    func bindViewModel(_ viewModel: Any!) {
        guard let viewModel = viewModel as? MonthTitleViewModel else { return }
        label.text = viewModel.name.uppercased()
    }
    
}
