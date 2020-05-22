//
//  SettingsTableViewCell.swift
//  Unpause
//
//  Created by Krešimir Baković on 20/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    private let thumbNailImageView = UIImageView()
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
        renderThumbnailImageView()
        renderTitleLabel()
    }
    
    func configure(name: String, thumbnailImageName: String) {
        titleLabel.text = name
        thumbNailImageView.image = UIImage(named: thumbnailImageName)
    }
}

// MARK: - UI rendering
private extension SettingsTableViewCell {
    func renderThumbnailImageView() {
        contentView.addSubview(thumbNailImageView)
        thumbNailImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().inset(10)
            make.height.width.equalTo(30)
        }
    }
    
    func renderTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(thumbNailImageView.snp.right).offset(7)
            make.centerY.equalToSuperview()
        }
    }
}
