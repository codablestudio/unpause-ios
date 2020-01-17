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
    private let arrivalTimeLabel = UILabel()
    private let renameArrivalTimeButton = UIButton()
    
    private let youAreLeavingAtLabel = UILabel()
    private let leavingImageView = UIImageView()
    
    private let leavingDateLabel = UILabel()
    private let leavingTimeLabel = UILabel()
    
    private let separator = UIView()
    private let descriptionLabel = UILabel()
    
    private let stackView = UIStackView()
    
    private let cancleButton = OrangeButton(title: "Cancle")
    private let continueButton = OrangeButton(title: "Continue")
    
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
        renderArrivalPickersAndLabelsForDateAndTime()
        renderLeavingAtLabelAndLeavingImageView()
        renderLeavingPickersAndLabelsForDateAndTime()
        renderSeparatorAndDescription()
        renderCancleAndContinueButton()
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
        
        containerView.addSubview(arriveImageView)
        arriveImageView.snp.makeConstraints { (make) in
            make.top.equalTo(youArrivedAtLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(18)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        arriveImageView.image = UIImage(named: "enter_500x500")
        arriveImageView.contentMode = .scaleAspectFit
    }
    
    func renderArrivalPickersAndLabelsForDateAndTime() {
        containerView.addSubview(arrivalDateLabel)
        arrivalDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(youArrivedAtLabel.snp.bottom).offset(40)
            make.left.equalTo(arriveImageView.snp.right).offset(30)
        }
        arrivalDateLabel.text = "13.01.2020"
        
        containerView.addSubview(arrivalTimeLabel)
        arrivalTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(arrivalDateLabel.snp.bottom).offset(15)
            make.left.equalTo(arriveImageView.snp.right).offset(30)
        }
        arrivalTimeLabel.text = "10:59"
    }
    
    func renderLeavingAtLabelAndLeavingImageView() {
        containerView.addSubview(youAreLeavingAtLabel)
        youAreLeavingAtLabel.snp.makeConstraints { (make) in
            make.top.equalTo(arrivalTimeLabel.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(15)
        }
        youAreLeavingAtLabel.text = "You are leaving at:"
        youAreLeavingAtLabel.font = youAreLeavingAtLabel.font.withSize(20)
        
        containerView.addSubview(leavingImageView)
        leavingImageView.snp.makeConstraints { (make) in
            make.top.equalTo(youAreLeavingAtLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(3)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        leavingImageView.image = UIImage(named: "exit_500x500")
        leavingImageView.contentMode = .scaleAspectFit
    }
    
    func renderLeavingPickersAndLabelsForDateAndTime() {
        containerView.addSubview(leavingDateLabel)
        leavingDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(youAreLeavingAtLabel.snp.bottom).offset(40)
            make.left.equalTo(leavingImageView.snp.right).offset(45)
        }
        leavingDateLabel.text = "13.01.2020"
        
        containerView.addSubview(leavingTimeLabel)
        leavingTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(leavingDateLabel.snp.bottom).offset(15)
            make.left.equalTo(leavingImageView.snp.right).offset(45)
        }
        leavingTimeLabel.text = "19:08"
    }
    
    func renderSeparatorAndDescription() {
        containerView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(leavingTimeLabel.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(1)
        }
        separator.backgroundColor = UIColor.orange
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(separator.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
        }
        descriptionLabel.text = "You have been working for 3 hours and 15 minutes, would you like to continue?"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
    }

    func renderCancleAndContinueButton() {
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(60)
            make.bottom.equalToSuperview()
        }
        stackView.addArrangedSubview(cancleButton)
        stackView.addArrangedSubview(continueButton)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
    }
}
