//
//  AddShiftViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 15/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture

class AddShiftViewController: UIViewController {
    
    private let addShiftViewModel: AddShiftViewModel
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let addingShiftLabel = UILabel()
    private let addingShiftSeparator = UIView()
    
    private let youArrivedAtLabel = UILabel()
    private let arriveImageView = UIImageView()
    
    private let arrivalDateLabel = UILabel()
    private let arrivalTimeTextField = UITextField()
    
    private let youAreLeavingAtLabel = UILabel()
    private let leavingImageView = UIImageView()
    
    private let leavingDateTextField = UITextField()
    private let leavingTimeTextField = UITextField()
    
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
        createPickers()
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
    
    private func createPickers() {
        createTimePickerAndBarForPicker(for: arrivalTimeTextField)
        createPickerAndBarForPicker(for: leavingDateTextField)
        createTimePickerAndBarForPicker(for: leavingTimeTextField)
    }
    
    private func createPickerAndBarForPicker(for textField: UITextField) {
        let picker = UIDatePicker()
        textField.inputView = picker
        picker.backgroundColor = UIColor.white
        addBarOnTopOfPicker(for: textField)
    }
    
    private func createTimePickerAndBarForPicker(for textField: UITextField) {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        textField.inputView = picker
        picker.backgroundColor = UIColor.white
        addBarOnTopOfPicker(for: textField)
    }
    
    private func addBarOnTopOfPicker(for textField: UITextField) {
        let bar = UIToolbar()
        bar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        bar.setItems([flexibleSpace,doneButton], animated: false)
        bar.isUserInteractionEnabled = true
        textField.inputAccessoryView = bar
        
        doneButton.rx.tap.subscribe(onNext: { [weak self] _ in
        self?.view.endEditing(true)
         }).disposed(by: disposeBag)
    }
}

// MARK: - UI rendering

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
        
        containerView.addSubview(arrivalTimeTextField)
        arrivalTimeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(arrivalDateLabel.snp.bottom).offset(15)
            make.left.equalTo(arriveImageView.snp.right).offset(30)
        }
        arrivalTimeTextField.text = "10:59"
    }
    
    func renderLeavingAtLabelAndLeavingImageView() {
        containerView.addSubview(youAreLeavingAtLabel)
        youAreLeavingAtLabel.snp.makeConstraints { (make) in
            make.top.equalTo(arrivalTimeTextField.snp.bottom).offset(35)
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
        containerView.addSubview(leavingDateTextField)
        leavingDateTextField.snp.makeConstraints { (make) in
            make.top.equalTo(youAreLeavingAtLabel.snp.bottom).offset(40)
            make.left.equalTo(leavingImageView.snp.right).offset(45)
        }
        leavingDateTextField.text = "13.01.2020"
        
        containerView.addSubview(leavingTimeTextField)
        leavingTimeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(leavingDateTextField.snp.bottom).offset(15)
            make.left.equalTo(leavingImageView.snp.right).offset(45)
        }
        leavingTimeTextField.text = "19:08"
    }
    
    func renderSeparatorAndDescription() {
        containerView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(leavingTimeTextField.snp.bottom).offset(35)
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

// MARK: - Picker delegate functions

extension AddShiftViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        if pickerView == dateTextField.inputView {
//            return 3
//        } else {
//            return 1
//        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if pickerView == membershipTextField.inputView {
//            return membershipPickerArray.count
//        } else if pickerView == phoneNumberTextField.inputView {
//            return phoneNumberPickerArray.count
//        } else if pickerView == statusTextView.inputView {
//            return statusPickerArray.count
//        } else {
//            if component == 0 {
//                return dayArray.count
//            } else if component == 1 {
//                return monthsArray.count
//            } else {
//                return yearArray.count
//            }
//        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if pickerView == membershipTextField.inputView {
//            return membershipPickerArray[row]
//        } else if pickerView == phoneNumberTextField.inputView {
//            return phoneNumberPickerArray[row]
//        } else if pickerView == statusTextView.inputView {
//            return statusPickerArray[row]
//        } else {
//            if component == 0 {
//                return dayArray[row]
//            } else if component == 1 {
//                return monthsArray[row]
//            } else {
//                return yearArray[row]
//            }
//        }
        return "aaa"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if pickerView == membershipTextField.inputView {
//            chosenMembership = membershipPickerArray[row]
//            membershipTextField.text = chosenMembership
//        } else if pickerView == phoneNumberTextField.inputView {
//            preNumber = phoneNumberPickerArray[row]
//            phoneNumberTextField.text = preNumber
//        } else if pickerView == statusTextView.inputView {
//            chosenStatus = statusPickerArray[row]
//            if [1,2,3,4,5,6].contains(row) {
//                schoolStackView.isHidden = false
//            } else {
//                schoolStackView.isHidden = true
//            }
//            statusTextView.text = chosenStatus
//        } else {
//            if component == 0 {
//                chosenDay = dayArray[row]
//            } else if component == 1 {
//                chosenMonth = monthsArray[row]
//            } else {
//                chosenYear = yearArray[row]
//            }
//            guard let day = chosenDay, let month = chosenMonth, let year = chosenYear else {
//                return
//            }
//            dateTextField.text = "\(day) \(month) \(year)"
//            if day == "" || month == "" || year == "" {
//                dateTextField.text =  nil
//            }
//        }
    }
}
