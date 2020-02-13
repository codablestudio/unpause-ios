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
    
    private let closeButton = UIButton()
    
    private let arrivalTimePicker = UIDatePicker()
    private let leavingDatePicker = UIDatePicker()
    private let leavingTimePicker = UIDatePicker()
    
    private var workingHours = PublishSubject<String>()
    private var workingMinutes = PublishSubject<String>()
    
    private var arrivalDateAndTime: Date?
    private var leavingDateAndTime: Date?
    
    init(addShiftViewModel: AddShiftViewModel) {
        self.addShiftViewModel = addShiftViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpArrivalTimePickerInitalValue()
        render()
        setUpObservables()
        createPickers()
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
        showFreshWorkingHoursAndMinutesLabel()
    }
    
    private func setUpArrivalTimePickerInitalValue() {
        arrivalTimePicker.date = SessionManager.shared.currentUser?.lastCheckInDateAndTime ?? Date()
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
        renderCloseButton()
    }
    
    private func setUpObservables() {
        cancleButton.rx.tap.subscribe(onNext: { _ in
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { _ in
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        continueButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            Coordinator.shared.navigateToDecriptionViewController(from: self,
                                                                  arrivalTime: self.arrivalDateAndTime,
                                                                  leavingTime: self.leavingDateAndTime)
        }).disposed(by: disposeBag)
        
        arrivalTimePicker.rx.value
            .subscribe(onNext: { [weak self] timeInDateFormat in
                guard let `self` = self else { return }
                let timeInStringFormat = Formatter.shared.convertTimeIntoString(from: timeInDateFormat)
                self.arrivalTimeTextField.text = timeInStringFormat
                
                let newDateAndTime = self.addShiftViewModel.makeNewDateAndTimeWithCheckInDateAnd(timeInDateFormat: timeInDateFormat)
                SessionManager.shared.currentUser?.lastCheckInDateAndTime = newDateAndTime
                
                self.leavingTimePicker.minimumDate = timeInDateFormat
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(leavingDatePicker.rx.value, leavingTimePicker.rx.value)
            .subscribe(onNext: { [weak self] (leavingDateInDateFormat, leavingTimeInDateFormat) in
                guard let `self` = self else { return }
                
                let dateInStringFormat = Formatter.shared.convertDateIntoString(from: leavingDateInDateFormat)
                self.leavingDateTextField.text = dateInStringFormat
                let timeInStringFormat = Formatter.shared.convertTimeIntoString(from: leavingTimeInDateFormat)
                self.leavingTimeTextField.text = timeInStringFormat
                
                let newDateAndTime = self.addShiftViewModel.makeNewDateAndTimeInDateFormat(dateInDateFormat: leavingDateInDateFormat,
                                                                                           timeInDateFormat: leavingTimeInDateFormat)
                SessionManager.shared.currentUser?.lastCheckOutDateAndTime = newDateAndTime
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(arrivalTimePicker.rx.value, leavingDatePicker.rx.value, leavingTimePicker.rx.value)
            .subscribe(onNext: { [weak self] (arrivalTime, leavingDate, leavingTime) in
                guard let `self` = self else { return }
                guard let firstDate = self.addShiftViewModel.makeNewDateAndTimeWithCheckInDateAnd(timeInDateFormat: arrivalTime),
                    let secondDate = self.addShiftViewModel.makeNewDateAndTimeInDateFormat(dateInDateFormat: leavingDate,
                                                                                           timeInDateFormat: leavingTime)
                    else { return }
                
                self.arrivalDateAndTime = firstDate
                self.leavingDateAndTime = secondDate
                
                let timeDifference = self.addShiftViewModel.findTimeDifference(firstDate: firstDate, secondDate: secondDate)
                self.workingHours.onNext(timeDifference.0)
                self.workingMinutes.onNext(timeDifference.1)
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(workingHours, workingMinutes)
            .subscribe(onNext: { [weak self] (workingHours, workingMinutes) in
                guard let `self` = self else { return }
                let firstPartOfString = "You have been working for"
                let hoursPartOfString = "\(workingHours) hours and"
                let minutesPartOfString = "\(workingMinutes)"
                let lastPartOfString = "minutes, would you like to continue?"
                self.descriptionLabel.text = "\(firstPartOfString) \(hoursPartOfString) \(minutesPartOfString) \(lastPartOfString)"
            }).disposed(by: disposeBag)
    }
    
    private func createPickers() {
        createTimePickerAndBarForPicker(for: arrivalTimeTextField, with: arrivalTimePicker)
        createDatePickerAndBarForPicker(for: leavingDateTextField, with: leavingDatePicker)
        createTimePickerAndBarForPicker(for: leavingTimeTextField, with: leavingTimePicker)
    }
    
    private func createDatePickerAndBarForPicker(for textField: UITextField, with picker: UIDatePicker) {
        picker.datePickerMode = UIDatePicker.Mode.date
        textField.inputView = picker
        picker.backgroundColor = UIColor.whiteUnpauseTextAndBackgroundColor
        if textField == leavingDateTextField {
            picker.minimumDate = SessionManager.shared.currentUser?.lastCheckInDateAndTime
        }
        addBarOnTopOfPicker(for: textField)
    }
    
    private func createTimePickerAndBarForPicker(for textField: UITextField, with picker: UIDatePicker) {
        picker.datePickerMode = UIDatePicker.Mode.time
        textField.inputView = picker
        picker.backgroundColor = UIColor.whiteUnpauseTextAndBackgroundColor
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
    
    private func addGestureRecognizer() {
        view.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] (tapGesture) in
            self?.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    private func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func showFreshWorkingHoursAndMinutesLabel() {
        guard let firstDateAndTime = addShiftViewModel.makeNewDateAndTimeWithCheckInDateAnd(timeInDateFormat: arrivalTimePicker.date),
            let secondDateAndTime = addShiftViewModel.makeNewDateAndTimeInDateFormat(dateInDateFormat: leavingDatePicker.date,
                                                                                     timeInDateFormat: leavingTimePicker.date)
            else { return }
        
        let timeIntervalHoursAndMinutes = addShiftViewModel.findTimeDifference(firstDate: firstDateAndTime,
                                                                               secondDate: secondDateAndTime)
        let firstPartOfString = "You have been working for"
        let hoursPartOfString = "\(timeIntervalHoursAndMinutes.0) hours and"
        let minutesPartOfString = "\(timeIntervalHoursAndMinutes.1)"
        let lastPartOfString = "minutes, would you like to continue?"
        descriptionLabel.text = "\(firstPartOfString) \(hoursPartOfString) \(minutesPartOfString) \(lastPartOfString)"
    }
}

// MARK: - UI rendering

private extension AddShiftViewController {
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor.whiteUnpauseTextAndBackgroundColor
        
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
        arrivalDateLabel.text = Formatter.shared.convertDateIntoString(from: Date())
        
        containerView.addSubview(arrivalTimeTextField)
        arrivalTimeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(arrivalDateLabel.snp.bottom).offset(15)
            make.left.equalTo(arriveImageView.snp.right).offset(30)
        }
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
        
        containerView.addSubview(leavingTimeTextField)
        leavingTimeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(leavingDateTextField.snp.bottom).offset(15)
            make.left.equalTo(leavingImageView.snp.right).offset(45)
        }
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
    
    func renderCloseButton() {
        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(25)
            make.left.equalToSuperview().offset(15)
        }
        closeButton.setImage(UIImage(named: "close_25x25"), for: .normal)
    }
}
