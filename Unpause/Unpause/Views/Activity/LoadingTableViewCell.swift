//
//  LoadingTableViewCell.swift
//  Unpause
//
//  Created by Krešimir Baković on 17/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    private let activityIndicatorView = UIActivityIndicatorView()

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
        renderActivityIndicatorView()
    }
    
    private func setUpCellSelectionStyle() {
        self.selectionStyle = .none
    }
}

// MARK: - UI rendering
private extension LoadingTableViewCell {
    func renderActivityIndicatorView() {
        contentView.addSubview(activityIndicatorView)
        
        activityIndicatorView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(15)
        }
        activityIndicatorView.startAnimating()
    }
}
