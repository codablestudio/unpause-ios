//
//  EmptyTableViewCell.swift
//  Unpause
//
//  Created by Krešimir Baković on 17/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {
    
    private let noShiftsLabel = UILabel()
    private let noShiftImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        render()
        setUpCellSelectionStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func render() {
        renderNoShiftsImageView()
        renderNoShiftsLabel()
    }
    
    private func setUpCellSelectionStyle() {
        self.selectionStyle = .none
    }
}

// MARK: - UI rendering
private extension EmptyTableViewCell {
    func renderNoShiftsImageView() {
        contentView.addSubview(noShiftImageView)
        noShiftImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(70)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(150)
        }
        noShiftImageView.image = UIImage(named: "unpause_white_logo_1024x1024")
    }
    
    func renderNoShiftsLabel() {
        contentView.addSubview(noShiftsLabel)
        noShiftsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(noShiftImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        noShiftsLabel.text = "No shifts for selected dates."
        noShiftsLabel.numberOfLines = 0
    }
}
