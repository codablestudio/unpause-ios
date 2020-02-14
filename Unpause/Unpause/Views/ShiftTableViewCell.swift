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
    
    private let toLabel = UILabel()
    
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
        fromLabel.text = "From xx:xx on xx.xx.xxxx"
        fromLabel.text = "From xx:xx on xx.xx.xxxx"
        descriptionLabel.text = nil
    }
    
    private func render() {
        renderFromLabel()
        renderToLabel()
        renderOnThatDayLabelAndDescriptionLabel()
    }
    
    func configure(_ shift: Shift) {
        let arrivalDateAndTimeInDateFormat = Formatter.shared.convertTimeStampIntoDate(timeStamp: shift.arrivalTime)
        let exitDateAndTimeInDateFormat = Formatter.shared.convertTimeStampIntoDate(timeStamp: shift.exitTime)
        guard let arrivalDateAndTime = arrivalDateAndTimeInDateFormat,
              let exitDateAndTime = exitDateAndTimeInDateFormat else {
                return
        }
        let arrivalTimeInStringFormat = Formatter.shared.convertTimeIntoString(from: arrivalDateAndTime)
        let arrivalDateInStringFormat = Formatter.shared.convertDateIntoString(from: arrivalDateAndTime)
        fromLabel.text = "From \(arrivalTimeInStringFormat) on \(arrivalDateInStringFormat)"
        
        let exitTimeInStringFormat = Formatter.shared.convertTimeIntoString(from: exitDateAndTime)
        let exitDateInStringFormat = Formatter.shared.convertDateIntoString(from: exitDateAndTime)
        toLabel.text = "To \(exitTimeInStringFormat) on \(exitDateInStringFormat)"
        
        descriptionLabel.text = shift.description
    }
}

// MARK: - UI rendering
private extension ShiftTableViewCell {
    func renderFromLabel() {
        contentView.addSubview(fromLabel)
        
        fromLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(15)
        }
        fromLabel.text = "From:"
        fromLabel.textColor = UIColor.green
    }
    
    func renderToLabel() {
        contentView.addSubview(toLabel)
        
        toLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fromLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(15)
        }
        toLabel.text = "To:"
        toLabel.textColor = UIColor.red
    }
    
    func renderOnThatDayLabelAndDescriptionLabel() {
        contentView.addSubview(onThatDayLabel)
        
        onThatDayLabel.snp.makeConstraints { (make) in
            make.top.equalTo(toLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
        }
        onThatDayLabel.text = "On that day you did:"
        onThatDayLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        contentView.addSubview(descriptionLabel)
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(onThatDayLabel.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
        descriptionLabel.text = "Today I did a lot of great things and it was fenomenal."
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
    }
}
