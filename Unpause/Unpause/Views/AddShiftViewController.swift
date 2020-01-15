//
//  AddShiftViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 15/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit

class AddShiftViewController: UIViewController {
    
    private var addShiftViewModel: AddShiftViewModel
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let addingShiftLabel = UILabel()
    private let addingShiftSeparator = UIView()
    
    private let youArrivedAtLabel = UILabel()
    private let arriveImageView = UIImageView()
    
    private let arrivalDateLabel = UILabel()
    private let arrivalTimePicker = UIPickerView()
    private let renameArrivalTimeButton = UIButton()
    
    private let youAreLeavingAt = UILabel()
    private let leavingImageView = UIImageView()
    
    private let leavingDatePicker = UIPickerView()
    private let renameLeavingDateButton = UIButton()
    private let leavingTimePicker = UIPickerView()
    private let renameLeavingTimeButton = UIButton()
    
    private let separator = UIView()
    
    private let descriptionLabel = UILabel()
    
    private let cancleButton = UIButton()
    private let continueButton = UIButton()
    
    init(addShiftViewModel: AddShiftViewModel) {
        self.addShiftViewModel = addShiftViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderAddingShiftLabelAndAddingShiftSeparator()
        renderArrivedAtLabelAndArriveImageView()
    }
    
}

private extension AddShiftViewController {
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
        scrollView.alwaysBounceVertical = true
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
        }
    }
    
    func renderAddingShiftLabelAndAddingShiftSeparator() {
        containerView.addSubview(addingShiftLabel)
        addingShiftLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        addingShiftLabel.text = "Adding shift"
        addingShiftLabel.textColor = UIColor.orange
        addingShiftLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        containerView.addSubview(addingShiftSeparator)
        addingShiftSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(addingShiftLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(1)
        }
        addingShiftSeparator.backgroundColor = UIColor.orange
    }
    
    func renderArrivedAtLabelAndArriveImageView() {
        containerView.addSubview(youArrivedAtLabel)
        youArrivedAtLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addingShiftSeparator.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(15)
        }
        youArrivedAtLabel.text = "You arrived at:"
        youArrivedAtLabel.font = youArrivedAtLabel.font.withSize(20)
    }

}
