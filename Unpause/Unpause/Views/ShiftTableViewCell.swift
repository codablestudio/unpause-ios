//
//  ShiftTableViewCell.swift
//  Unpause
//
//  Created by Krešimir Baković on 13/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit

class ShiftTableViewCell: UITableViewCell {
    
    private let fromLabel = UILabel()
    private let arrivalDateAndTimeLabel = UILabel()
    
    private let toLabel = UILabel()
    private let exitDateAndTimeLabel = UILabel()
    
    private let onThatDayLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        fromLabel.text = nil
        arrivalDateAndTimeLabel.text = nil
        toLabel.text = nil
        exitDateAndTimeLabel.text = nil
        onThatDayLabel.text = nil
        descriptionLabel.text = nil
    }
    
    private func render() {
        renderFromLabelAndArrivalDateAndTimeLabel()
        renderToLabelAndExitDateAndTimeLabel()
        renderOnThatDayLabelAndDescriptionLabel()
    }
    
    func configure() {
        
    }
}

// MARK: - UI rendering
private extension ShiftTableViewCell {
    func renderFromLabelAndArrivalDateAndTimeLabel() {
        
    }
    
    func renderToLabelAndExitDateAndTimeLabel() {
        
    }
    
    func renderOnThatDayLabelAndDescriptionLabel() {
        
    }
}
