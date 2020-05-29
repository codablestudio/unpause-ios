//
//  UserTypeCollectionViewCell.swift
//  Unpause
//
//  Created by Krešimir Baković on 29/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit

class UserTypeCollectionViewCell: UICollectionViewCell {
    private let cellImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func render() {
        renderCellImageView()
        renderTitleLabel()
    }
    
    func configure(name: String, cellImageName: String) {
        titleLabel.text = name
        cellImageView.image = UIImage(named: cellImageName)
    }
}

// MARK: - UI rendering
private extension UserTypeCollectionViewCell {
    private func renderCellImageView() {
        contentView.addSubview(cellImageView)
        cellImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
            make.height.width.equalTo(100)
        }
    }
    
    private func renderTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(cellImageView.snp.bottom).offset(7)
            make.centerX.equalTo(cellImageView.snp.centerX)
        }
    }
}
