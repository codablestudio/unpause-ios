//
//  IconAndTextVerticalView.swift
//  Unpause
//
//  Created by Krešimir Baković on 26/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit

class IconAndTextVerticalView: UIView {
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    let textField = UITextField()
    
    init() {
        super.init(frame: .zero)
        render()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(icon: UIImage?, text: String = "-") {
        imageView.image = icon
        textField.text = text
    }
    
    private func render() {
        addSubview(stackView)
        stackView.edgesEqualToSuperview()
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        
        stackView.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
        }
        imageView.image = UIImage(named: "calendar_75x75_black")
        
        stackView.addArrangedSubview(textField)
        textField.font = .systemFont(ofSize: 10)
        textField.text = "-"
        textField.tintColor = .clear
    }
}
