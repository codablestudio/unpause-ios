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
import RxKeyboard

class AddShiftViewController: UIViewController {
    
    private let addShiftViewModel: AddShiftViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let youArrivedAtLabel = UILabel()
    private let arriveImageView = UIImageView()
    
    private let arrivalDateTextField = UITextField()
    private let arrivalDateTextFieldImageView = UIImageView()
    private let arrivalTimeTextField = UITextField()
    private let arrivalTimeTextFieldImageView = UIImageView()
    
    private let youAreLeavingAtLabel = UILabel()
    private let leavingImageView = UIImageView()
    
    private let leavingDateTextField = UITextField()
    private let leavingDateTextFieldImageView = UIImageView()
    private let leavingTimeTextField = UITextField()
    private let leavingTimeTextFieldImageView = UIImageView()
    
    private let separator = UIView()
    private let descriptionLabel = UILabel()
    
    private let stackView = UIStackView()
    
    private let cancelButton = OrangeButton(title: "Cancel")
    private let continueButton = OrangeButton(title: "Continue")
    
    private let arrivalDatePicker = UIDatePicker()
    private let arrivalTimePicker = UIDatePicker()
    private let leavingDatePicker = UIDatePicker()
    private let leavingTimePicker = UIDatePicker()
    
    private let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
    
    private var workingHours = PublishSubject<String>()
    private var workingMinutes = PublishSubject<String>()
    
    private var arrivalDateAndTime: Date?
    private var leavingDateAndTime: Date?
    
    var cellToEdit: ShiftsTableViewItem?
    
    var arrivalDatePickerEnabled = false
    var navigationFromTableView: Bool
    var navigationFromCustomShift: Bool
    
    init(addShiftViewModel: AddShiftViewModelProtocol, navigationFromTableView: Bool, navigationFromCustomShift: Bool) {
        self.addShiftViewModel = addShiftViewModel
        self.navigationFromTableView = navigationFromTableView
        self.navigationFromCustomShift = navigationFromCustomShift
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        enableOrDisableArrivalDatePicker()
        createPickers()
        addBarButtonItem()
        setUpObservables()
        setUpArrivalAndLeavingDateAndTimePickerInitalValue()
        addGestureRecognizer()
        setUpKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpViewControllerTitle()
    }
    
    private func setUpArrivalAndLeavingDateAndTimePickerInitalValue() {
        if navigationFromTableView {
            setUpArrivalAndLeavingDateAndTimepickerInitialValueOnEditinigShift()
        } else {
            setUpArrivalAndLeavingDateAndTimePickerInitalValueOnAddingNewShift()
        }
    }
    
    private func setUpArrivalAndLeavingDateAndTimePickerInitalValueOnAddingNewShift() {
        if navigationFromCustomShift {
            arrivalTimePicker.rx.value.onNext(Date())
            refreshTextFieldWithNewTime(textField: arrivalTimeTextField, newTime: Date())
            arrivalDatePicker.rx.value.onNext(Date())
            refreshTextFieldWithNewDate(textField: arrivalDateTextField, newDate: Date())
            arrivalDateAndTime = Date()
            
            leavingTimePicker.rx.value.onNext(Date())
            refreshTextFieldWithNewTime(textField: leavingTimeTextField, newTime: Date())
            leavingDatePicker.rx.value.onNext(Date())
            refreshTextFieldWithNewDate(textField: leavingDateTextField, newDate: Date())
            leavingDateAndTime = Date()
            
            showFreshWorkingHoursAndMinutesLabel()
        } else {
            guard let lastCheckInDateAndTime = SessionManager.shared.currentUser?.lastCheckInDateAndTime,
                let lastCheckOutDateAndTime = SessionManager.shared.currentUser?.lastCheckOutDateAndTime else { return }
            
            arrivalTimePicker.rx.value.onNext(lastCheckInDateAndTime)
            refreshTextFieldWithNewTime(textField: arrivalTimeTextField, newTime: lastCheckInDateAndTime)
            arrivalDatePicker.rx.value.onNext(lastCheckInDateAndTime)
            refreshTextFieldWithNewDate(textField: arrivalDateTextField, newDate: lastCheckInDateAndTime)
            arrivalDateAndTime = lastCheckInDateAndTime
            
            leavingTimePicker.rx.value.onNext(lastCheckOutDateAndTime)
            refreshTextFieldWithNewTime(textField: leavingTimeTextField, newTime: lastCheckOutDateAndTime)
            leavingDatePicker.rx.value.onNext(lastCheckOutDateAndTime)
            refreshTextFieldWithNewDate(textField: leavingDateTextField, newDate: lastCheckOutDateAndTime)
            leavingDateAndTime = lastCheckOutDateAndTime
            
            showFreshWorkingHoursAndMinutesLabel()
        }
    }
    
    private func setUpArrivalAndLeavingDateAndTimepickerInitialValueOnEditinigShift() {
        let checkInDateAndTime = Formatter.shared.convertTimeStampIntoDate(timeStamp: cellToEdit?.shift?.arrivalTime)
        let checkOutDateAndTime = Formatter.shared.convertTimeStampIntoDate(timeStamp: cellToEdit?.shift?.exitTime)
        
        guard let checkInDateAndTimeInDateFormat = checkInDateAndTime,
            let checkOutDateAndTimeInDateFormat = checkOutDateAndTime else { return }
        
        
        arrivalTimePicker.rx.value.onNext(checkInDateAndTimeInDateFormat)
        refreshTextFieldWithNewTime(textField: arrivalTimeTextField, newTime: checkInDateAndTimeInDateFormat)
        arrivalDatePicker.rx.value.onNext(checkInDateAndTimeInDateFormat)
        refreshTextFieldWithNewDate(textField: arrivalDateTextField, newDate: checkInDateAndTimeInDateFormat)
        arrivalDateAndTime = checkInDateAndTimeInDateFormat
        
        leavingTimePicker.rx.value.onNext(checkOutDateAndTimeInDateFormat)
        refreshTextFieldWithNewTime(textField: leavingTimeTextField, newTime: checkOutDateAndTimeInDateFormat)
        leavingDatePicker.rx.value.onNext(checkOutDateAndTimeInDateFormat)
        refreshTextFieldWithNewDate(textField: leavingDateTextField, newDate: checkOutDateAndTimeInDateFormat)
        leavingDateAndTime = checkOutDateAndTimeInDateFormat
        
        showFreshWorkingHoursAndMinutesLabel()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderArrivedAtLabelAndArriveImageView()
        renderArrivalPickersAndLabelsForDateAndTime()
        renderArrivalDateAndTimePickerImageView()
        renderLeavingAtLabelAndLeavingImageView()
        renderLeavingPickersAndLabelsForDateAndTime()
        renderLeavingDateAndTimePickerImageView()
        renderSeparatorAndDescription()
        renderCancleAndContinueButton()
    }
    
    private func enableOrDisableArrivalDatePicker() {
        if navigationFromTableView || navigationFromCustomShift {
            arrivalDatePicker.isEnabled = true
        } else {
            arrivalDatePicker.isEnabled = false
        }
    }
    
    private func setUpObservables() {
        cancelButton.rx.tap.subscribe(onNext: { _ in
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(arrivalDatePicker.rx.value, arrivalTimePicker.rx.value)
            .subscribe(onNext: { [weak self] arrivalDate, arrivalTime in
                guard let `self` = self else { return }
                
                if self.navigationFromTableView {
                    self.handleArrivalFieldsWhenEditingShift(arrivalDate: arrivalDate, arrivalTime: arrivalTime)
                } else {
                    self.handleArrivalFieldsWhenAddingShift(arrivalDate: arrivalDate, arrivalTime: arrivalTime)
                }
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(leavingDatePicker.rx.value, leavingTimePicker.rx.value)
            .subscribe(onNext: { [weak self] leavingDate, leavingTime in
                guard let `self` = self else { return }
                
                if self.navigationFromTableView {
                    self.handleLeavingFieldsWhenEditingShift(leavingDate: leavingDate, leavingTime: leavingTime)
                } else {
                    self.handleLeavingFieldsWhenAddingShift(leavingDate: leavingDate, leavingTime: leavingTime)
                }
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
        
        continueButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            
            if self.navigationFromTableView {
                self.handleContinueButtonWhenEditingShift()
            } else {
                self.handleContinueButtonWhenAddingShift()
            }
        }).disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { _ in
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        arrivalDateTextFieldImageView.rx.tapGesture()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.arrivalDateTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        arrivalTimeTextFieldImageView.rx.tapGesture()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.arrivalTimeTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        leavingDateTextFieldImageView.rx.tapGesture()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.leavingDateTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        leavingTimeTextFieldImageView.rx.tapGesture()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.leavingTimeTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
    }
    
    func handleArrivalFieldsWhenAddingShift(arrivalDate: Date, arrivalTime: Date) {
        guard let leavingDateAndTime = leavingDateAndTime else { return }
        
        refreshTextFieldWithNewDate(textField: arrivalDateTextField, newDate: arrivalDate)
        refreshTextFieldWithNewTime(textField: arrivalTimeTextField, newTime: arrivalTime)
        
        let arrivalDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: arrivalDate)
        let leavingDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: leavingDateAndTime)
        
        if arrivalDateWithStartingDayTime == leavingDateWithStartingDayTime {
            leavingTimePicker.minimumDate = arrivalTime
        } else {
            leavingTimePicker.minimumDate = nil
        }
        
        guard let newArrivalDateAndTime = addShiftViewModel.makeNewDateAndTimeInDateFormat(
            dateInDateFormat: arrivalDate,
            timeInDateFormat: arrivalTime) else { return }
        
        arrivalDateAndTime = newArrivalDateAndTime
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: newArrivalDateAndTime)
        let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: leavingDateAndTime)
        
        let timeDifference = Formatter.shared.findTimeDifference(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                 secondDate: leavingDateAndTimeWithZeroSeconds)
        
        workingHours.onNext(timeDifference.0)
        workingMinutes.onNext(timeDifference.1)
    }
    
    func handleArrivalFieldsWhenEditingShift(arrivalDate: Date, arrivalTime: Date) {
        guard let leavingDateAndTimeInDateFormat = leavingDateAndTime else { return }
        
        refreshTextFieldWithNewDate(textField: arrivalDateTextField, newDate: arrivalDate)
        refreshTextFieldWithNewTime(textField: arrivalTimeTextField, newTime: arrivalTime)
        
        let arrivalDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: arrivalDate)
        let leavingDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: leavingDateAndTimeInDateFormat)
        
        if arrivalDateWithStartingDayTime == leavingDateWithStartingDayTime {
            leavingTimePicker.minimumDate = arrivalTime
        } else {
            leavingTimePicker.minimumDate = nil
        }
        
        guard let newArrivalDateAndTime = addShiftViewModel.makeNewDateAndTimeInDateFormat(
            dateInDateFormat: arrivalDate,
            timeInDateFormat: arrivalTime) else { return }
        
        arrivalDateAndTime = newArrivalDateAndTime
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: newArrivalDateAndTime)
        let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: leavingDateAndTimeInDateFormat)
        
        let timeDifference = Formatter.shared.findTimeDifference(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                 secondDate: leavingDateAndTimeWithZeroSeconds)
        
        workingHours.onNext(timeDifference.0)
        workingMinutes.onNext(timeDifference.1)
    }
    
    func handleLeavingFieldsWhenAddingShift(leavingDate: Date, leavingTime: Date) {
        guard let arrivalDateAndTime = arrivalDateAndTime else { return }
        
        refreshTextFieldWithNewDate(textField: leavingDateTextField, newDate: leavingDate)
        refreshTextFieldWithNewTime(textField: leavingTimeTextField, newTime: leavingTime)
        
        let arrivalDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: arrivalDateAndTime)
        let leavingDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: leavingDate)
        
        if arrivalDateWithStartingDayTime == leavingDateWithStartingDayTime {
            leavingTimePicker.minimumDate = arrivalTimePicker.date
        } else {
            leavingTimePicker.minimumDate = nil
        }
        
        guard let newLeavingDateAndTime = addShiftViewModel.makeNewDateAndTimeInDateFormat(
            dateInDateFormat: leavingDate,
            timeInDateFormat: leavingTime) else { return }
        
        leavingDateAndTime = newLeavingDateAndTime
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: arrivalDateAndTime)
        let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: newLeavingDateAndTime)
        
        let timeDifference = Formatter.shared.findTimeDifference(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                 secondDate: leavingDateAndTimeWithZeroSeconds)
        
        workingHours.onNext(timeDifference.0)
        workingMinutes.onNext(timeDifference.1)
    }
    
    func handleLeavingFieldsWhenEditingShift(leavingDate: Date, leavingTime: Date) {
        guard let arrivalDateAndTimeInDateFormat = arrivalDateAndTime else { return }
        
        refreshTextFieldWithNewDate(textField: leavingDateTextField, newDate: leavingDate)
        refreshTextFieldWithNewTime(textField: leavingTimeTextField, newTime: leavingTime)
        
        let arrivalDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: arrivalDateAndTimeInDateFormat)
        let leavingDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: leavingDate)
        
        if arrivalDateWithStartingDayTime == leavingDateWithStartingDayTime {
            leavingTimePicker.minimumDate = arrivalDateAndTimeInDateFormat
        } else {
            leavingTimePicker.minimumDate = nil
        }
        
        guard let newLeavingDateAndTime = addShiftViewModel.makeNewDateAndTimeInDateFormat(
            dateInDateFormat: leavingDate,
            timeInDateFormat: leavingTime) else { return }
        
        leavingDateAndTime = newLeavingDateAndTime
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: arrivalDateAndTimeInDateFormat)
        let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: newLeavingDateAndTime)
        
        let timeDifference = Formatter.shared.findTimeDifference(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                 secondDate: leavingDateAndTimeWithZeroSeconds)
        
        workingHours.onNext(timeDifference.0)
        workingMinutes.onNext(timeDifference.1)
    }
    
    private func handleContinueButtonWhenAddingShift() {
        guard let arrivalDateAndTimeInDateFormat = arrivalDateAndTime,
            let exitDateAndTimeInDateFormat = leavingDateAndTime else {
                return
        }
        
        SessionManager.shared.currentUser?.lastCheckInDateAndTime = arrivalDateAndTimeInDateFormat
        SessionManager.shared.currentUser?.lastCheckOutDateAndTime = exitDateAndTimeInDateFormat
        
        if arrivalDateAndTimeInDateFormat <= exitDateAndTimeInDateFormat {
            Coordinator.shared.navigateToDescriptionViewController(from: self,
                                                                  arrivalTime: arrivalDateAndTimeInDateFormat,
                                                                  leavingTime: exitDateAndTimeInDateFormat,
                                                                  navigationFromCustomShift: navigationFromCustomShift)
        } else {
            showOneOptionAlert(title: "Alert", message: "Please enter correct dates and times.", actionTitle: "OK")
        }
    }
    
    private func handleContinueButtonWhenEditingShift() {
        let arrivalDateAndTime = addShiftViewModel.makeNewDateAndTimeInDateFormat(dateInDateFormat: arrivalDatePicker.date,
                                                                                  timeInDateFormat: arrivalTimePicker.date)
        let leavingDateAndTime = addShiftViewModel.makeNewDateAndTimeInDateFormat(dateInDateFormat: leavingDatePicker.date,
                                                                                  timeInDateFormat: leavingTimePicker.date)
        
        guard let arrivalDateAndTimeInDateFormat = arrivalDateAndTime,
            let leavingDateAndTimeInDateFormat = leavingDateAndTime,
            let shiftData = cellToEdit else { return }
        if arrivalDateAndTimeInDateFormat <= leavingDateAndTimeInDateFormat {
            Coordinator.shared.navigateToDescriptionViewController(from: self,
                                                                  arrivalTime: arrivalDateAndTimeInDateFormat,
                                                                  leavingTime: leavingDateAndTimeInDateFormat,
                                                                  with: shiftData)
        } else {
            showOneOptionAlert(title: "Alert", message: "Please enter correct dates and times.", actionTitle: "OK")
        }
    }
    
    private func refreshTextFieldWithNewDate(textField: UITextField, newDate: Date) {
        let dateInStringFormat = Formatter.shared.convertDateIntoString(from: newDate)
        textField.text = dateInStringFormat
    }
    
    private func refreshTextFieldWithNewTime(textField: UITextField, newTime: Date) {
        let timeInStringFormat = Formatter.shared.convertTimeIntoString(from: newTime)
        textField.text = timeInStringFormat
    }
    
    private func createPickers() {
        createDatePickerAndBarForPicker(for: arrivalDateTextField, with: arrivalDatePicker)
        createTimePickerAndBarForPicker(for: arrivalTimeTextField, with: arrivalTimePicker)
        createDatePickerAndBarForPicker(for: leavingDateTextField, with: leavingDatePicker)
        createTimePickerAndBarForPicker(for: leavingTimeTextField, with: leavingTimePicker)
    }
    
    private func addBarButtonItem() {
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func createDatePickerAndBarForPicker(for textField: UITextField, with picker: UIDatePicker) {
        picker.datePickerMode = UIDatePicker.Mode.date
        textField.inputView = picker
        picker.backgroundColor = UIColor.unpauseWhite
        addBarOnTopOfPicker(for: textField)
    }
    
    private func createTimePickerAndBarForPicker(for textField: UITextField, with picker: UIDatePicker) {
        picker.datePickerMode = UIDatePicker.Mode.time
        textField.inputView = picker
        picker.backgroundColor = UIColor.unpauseWhite
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
    
    private func setUpKeyboard() {
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyboardVisibleHeight in
            guard let `self` = self else { return }
            var bottomInset: CGFloat = 15
            bottomInset += keyboardVisibleHeight
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }).disposed(by: disposeBag)
    }
    
    private func showFreshWorkingHoursAndMinutesLabel() {
        if navigationFromTableView {
            showFreshWorkingHoursAndMinutesLabelWhenEditing()
        } else {
            showFreshWorkingHoursAndMinutesLabelWhenAdding()
        }
    }
    
    private func showFreshWorkingHoursAndMinutesLabelWhenAdding() {
        if navigationFromCustomShift {
            let timeDifference = Formatter.shared.findTimeDifference(firstDate: Date(),
                                                                     secondDate: Date())
            
            workingHours.onNext(timeDifference.0)
            workingMinutes.onNext(timeDifference.1)
        } else {
            guard let lastCheckInDateAndTime = SessionManager.shared.currentUser?.lastCheckInDateAndTime,
                let lastCheckOutDateAndTime = SessionManager.shared.currentUser?.lastCheckOutDateAndTime else { return }
            
            let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: lastCheckInDateAndTime)
            let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: lastCheckOutDateAndTime)
            
            let timeDifference = Formatter.shared.findTimeDifference(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                     secondDate: leavingDateAndTimeWithZeroSeconds)
            
            workingHours.onNext(timeDifference.0)
            workingMinutes.onNext(timeDifference.1)
        }
    }
    
    private func showFreshWorkingHoursAndMinutesLabelWhenEditing() {
        let arrivalDateAndTime = Formatter.shared.convertTimeStampIntoDate(timeStamp: cellToEdit?.shift?.arrivalTime)
        let leavingDateAndTime = Formatter.shared.convertTimeStampIntoDate(timeStamp: cellToEdit?.shift?.exitTime)
        
        guard let arrivalDateAndTimeInDateFormat = arrivalDateAndTime,
            let leavingDateAndTimeInDateFormat = leavingDateAndTime else { return }
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: arrivalDateAndTimeInDateFormat)
        let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: leavingDateAndTimeInDateFormat)
        
        let timeDifference = Formatter.shared.findTimeDifference(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                 secondDate: leavingDateAndTimeWithZeroSeconds)
        
        workingHours.onNext(timeDifference.0)
        workingMinutes.onNext(timeDifference.1)
    }
    
    private func setUpViewControllerTitle() {
        if navigationFromTableView {
            self.title = "Editing shift"
        } else {
            self.title = "Adding shift"
        }
    }
}

// MARK: - UI rendering
private extension AddShiftViewController {
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor.unpauseWhite
        
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
    
    func renderArrivedAtLabelAndArriveImageView() {
        containerView.addSubview(youArrivedAtLabel)
        youArrivedAtLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
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
        containerView.addSubview(arrivalDateTextField)
        arrivalDateTextField.snp.makeConstraints { (make) in
            make.top.equalTo(youArrivedAtLabel.snp.bottom).offset(40)
            make.left.equalTo(arriveImageView.snp.right).offset(30)
        }
        arrivalDateTextField.tintColor = .clear
        
        containerView.addSubview(arrivalTimeTextField)
        arrivalTimeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(arrivalDateTextField.snp.bottom).offset(15)
            make.left.equalTo(arriveImageView.snp.right).offset(30)
        }
        arrivalTimeTextField.tintColor = .clear
    }
    
    func renderArrivalDateAndTimePickerImageView() {
        containerView.addSubview(arrivalDateTextFieldImageView)
        arrivalDateTextFieldImageView.snp.makeConstraints { make in
            make.left.equalTo(arrivalDateTextField.snp.right).offset(5)
            make.centerY.equalTo(arrivalDateTextField.snp.centerY)
            make.height.width.equalTo(16)
        }
        arrivalDateTextFieldImageView.image = UIImage(named: "click_arrow_30x30")
        
        containerView.addSubview(arrivalTimeTextFieldImageView)
        arrivalTimeTextFieldImageView.snp.makeConstraints { make in
            make.left.equalTo(arrivalTimeTextField.snp.right).offset(5)
            make.centerY.equalTo(arrivalTimeTextField.snp.centerY)
            make.height.width.equalTo(16)
        }
        arrivalTimeTextFieldImageView.image = UIImage(named: "click_arrow_30x30")
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
        leavingDateTextField.tintColor = .clear
        
        containerView.addSubview(leavingTimeTextField)
        leavingTimeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(leavingDateTextField.snp.bottom).offset(15)
            make.left.equalTo(leavingImageView.snp.right).offset(45)
        }
        leavingTimeTextField.tintColor = .clear
    }
    
    func renderLeavingDateAndTimePickerImageView() {
        containerView.addSubview(leavingDateTextFieldImageView)
        leavingDateTextFieldImageView.snp.makeConstraints { make in
            make.left.equalTo(leavingDateTextField.snp.right).offset(5)
            make.centerY.equalTo(leavingDateTextField.snp.centerY)
            make.height.width.equalTo(16)
        }
        leavingDateTextFieldImageView.image = UIImage(named: "click_arrow_30x30")
        
        containerView.addSubview(leavingTimeTextFieldImageView)
        leavingTimeTextFieldImageView.snp.makeConstraints { make in
            make.left.equalTo(leavingTimeTextField.snp.right).offset(5)
            make.centerY.equalTo(leavingTimeTextField.snp.centerY)
            make.height.width.equalTo(16)
        }
        leavingTimeTextFieldImageView.image = UIImage(named: "click_arrow_30x30")
    }
    
    func renderSeparatorAndDescription() {
        containerView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(leavingTimeTextField.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(1)
        }
        separator.backgroundColor = UIColor.unpauseOrange
        
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
            make.bottom.equalToSuperview().inset(15)
        }
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(continueButton)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        cancelButton.layer.cornerRadius = 15
        continueButton.layer.cornerRadius = 15
    }
}
