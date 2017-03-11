//
//  CalendarDayCell.swift
//  IGListKitExamples
//
//  Created by Ryan Nystrom on 3/11/17.
//  Copyright © 2017 Instagram. All rights reserved.
//

import UIKit
import IGListKit

final class CalendarDayCell: UICollectionViewCell {
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = .black
        view.font = .boldSystemFont(ofSize: 16)
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var dotsLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = .red
        view.font = .boldSystemFont(ofSize: 30)
        self.contentView.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let half = bounds.height / 2
        label.frame = bounds
        label.layer.cornerRadius = half
        dotsLabel.frame = CGRect(x: 0, y: half - 10, width: bounds.width, height: half)
    }
    
}

extension CalendarDayCell: IGListBindable {
    
    func bindViewModel(_ viewModel: Any!) {
        guard let viewModel = viewModel as? DayViewModel else { return }
        label.text = viewModel.day.description
        
        label.layer.borderColor = viewModel.today ? UIColor.red.cgColor : UIColor.clear.cgColor
        label.backgroundColor = viewModel.selected ? UIColor.red.withAlphaComponent(0.3) : UIColor.clear
        
        var dots = ""
        for _ in 0..<viewModel.appointments {
            dots += "."
        }
        dotsLabel.text = dots
    }
    
}
