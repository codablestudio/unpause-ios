//
//  SettingsTableViewCell.swift
//  Unpause
//
//  Created by Krešimir Baković on 20/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    
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
    
    private func render() {
        renderTitleLabel()
    }
    
    func configure(name: String) {
        titleLabel.text = name
    }
}

// MARK: - UI rendering
private extension SettingsTableViewCell {
    func renderTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().inset(20)
        }
    }
}
