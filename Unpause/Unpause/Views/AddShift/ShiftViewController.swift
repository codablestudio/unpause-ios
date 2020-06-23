//
//  ShiftViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import RxKeyboard

class ShiftViewController: UIViewController {
    
    private let shiftViewModel: ShiftViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let arrivalInfoLabel = UILabel()
    
    private let stackView = UIStackView()
    
    private let arrivalStackView = UIStackView()
    
    private let arrivalImageView = UIImageView()
    
    private let arrivalDateStackView = UIStackView()
    private let arrivalDateImageView = UIImageView()
    private let arrivalDateTextField = UITextField()
    
    private let arrivalTimeStackView = UIStackView()
    private let arrivalTimeImageView = UIImageView()
    private let arrivalTimeTextField = UITextField()
    
    private let arrivalSeparator = UIView()
    
    private let jobDescriptionLabel = UILabel()
    private let jobDescriptionTextView = UITextView()
    
    private let jobDescriptionSeparator = UIView()
    
    private let leavingInfoLabel = UILabel()
    
    private let leavingStackView = UIStackView()
    
    private let leavingImageView = UIImageView()
    
    private let leavingDateStackView = UIStackView()
    private let leavingDateImageView = UIImageView()
    private let leavingDateTextField = UITextField()
    
    private let leavingTimeStackView = UIStackView()
    private let leavingTimeImageView = UIImageView()
    private let leavingTimeTextField = UITextField()
    
    private let workingTimeStackView = UIStackView()
    private let workingTimeTitleLabel = UILabel()
    private let workingTimeLabel = UILabel()
    
    private let saveButton = UIButton()
    
    private let arrivalDatePicker = UIDatePicker()
    private let arrivalTimePicker = UIDatePicker()
    private let leavingDatePicker = UIDatePicker()
    private let leavingTimePicker = UIDatePicker()
    
    private let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
    
    private var arrivalDateAndTime: Date?
    private var leavingDateAndTime: Date?
    
    private var workingHours = PublishSubject<String>()
    private var workingMinutes = PublishSubject<String>()
    private var arrivalDateAndTimeChanges = PublishSubject<Date?>()
    private var leavingDateAndTimeChanges = PublishSubject<Date?>()
    
    init(shiftViewModel: ShiftViewModelProtocol) {
        self.shiftViewModel = shiftViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        createPickers()
        addBarButtonItem()
        setUpObservables()
        setUpArrivalAndLeavingDateAndTimePickerInitialValue()
        addGestureRecogniser()
        setUpKeyboard()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderArrivalInfoLabel()
        configureArrivalStackView()
        renderArrivalImageView()
        renderArrivalDateStackView()
        renderArrivalTimeStackView()
        renderArrivalSeparator()
        renderJobDescriptionLabel()
        renderJobDescriptionTextView()
        renderJobDescriptionSeparator()
        renderLeavingInfoLabel()
        configureLeavingStackView()
        renderLeavingImageView()
        renderLeavingDateStackView()
        renderLeavingTimeStackView()
        renderWorkingTimeStackView()
        renderSaveButton()
    }
    
    private func setUpObservables() {
        Observable.combineLatest(arrivalDatePicker.rx.value, arrivalTimePicker.rx.value)
            .subscribe(onNext: { [weak self] arrivalDate, arrivalTime in
                guard let `self` = self else { return }
                self.handleArrivalFieldsWhenAddingShift(arrivalDate: arrivalDate, arrivalTime: arrivalTime)
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(leavingDatePicker.rx.value, leavingTimePicker.rx.value)
            .subscribe(onNext: { [weak self] leavingDate, leavingTime in
                guard let `self` = self else { return }
                self.handleLeavingFieldsWhenAddingShift(leavingDate: leavingDate, leavingTime: leavingTime)
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(workingHours, workingMinutes)
            .subscribe(onNext: { [weak self] (workingHours, workingMinutes) in
                guard let `self` = self else { return }
                self.workingTimeLabel.text = "\(workingHours) h \(workingMinutes) min"
            }).disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { _ in
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        arrivalDateImageView.rx.tapGesture()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.arrivalDateTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        arrivalTimeImageView.rx.tapGesture()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.arrivalTimeTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        leavingDateImageView.rx.tapGesture()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.leavingDateTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        leavingTimeImageView.rx.tapGesture()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.leavingTimeTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        arrivalDateAndTimeChanges.bind(to: shiftViewModel.arrivalDateAndTimeChanges)
            .disposed(by: disposeBag)
        
        leavingDateAndTimeChanges.bind(to: shiftViewModel.leavingDateAndTimeChanges)
            .disposed(by: disposeBag)
        
        jobDescriptionTextView.rx.text
            .bind(to: shiftViewModel.textInDescriptionTextViewChanges)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                UnpauseActivityIndicatorView.shared.show(on: self.view)
            })
            .bind(to: shiftViewModel.saveButtonTapped)
            .disposed(by: disposeBag)
        
        shiftViewModel.shiftSavingResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    NotificationManager.shared.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["notifyOnExit"])
                    NotificationManager.shared.scheduleEntranceNotification()
                    UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                    ActivityViewModel.forceRefresh.onNext(())
                    HomeViewModel.forceRefresh.onNext(())
                    self.dismiss(animated: true)
                case .error(let error):
                    UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                    self.showOneOptionAlert(title: "Alert", message: "\(error.errorMessage)", actionTitle: "OK")
                }
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
        
        guard let newArrivalDateAndTime = shiftViewModel.makeNewDateAndTimeInDateFormat(
            dateInDateFormat: arrivalDate,
            timeInDateFormat: arrivalTime) else { return }
        
        arrivalDateAndTime = newArrivalDateAndTime
        arrivalDateAndTimeChanges.onNext(arrivalDateAndTime)
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: newArrivalDateAndTime)
        let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: leavingDateAndTime)
        
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
        
        guard let newLeavingDateAndTime = shiftViewModel.makeNewDateAndTimeInDateFormat(
            dateInDateFormat: leavingDate,
            timeInDateFormat: leavingTime) else { return }
        
        leavingDateAndTime = newLeavingDateAndTime
        leavingDateAndTimeChanges.onNext(newLeavingDateAndTime)
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: arrivalDateAndTime)
        let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: newLeavingDateAndTime)
        
        let timeDifference = Formatter.shared.findTimeDifference(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                 secondDate: leavingDateAndTimeWithZeroSeconds)
        
        workingHours.onNext(timeDifference.0)
        workingMinutes.onNext(timeDifference.1)
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
    
    private func addBarButtonItem() {
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setUpArrivalAndLeavingDateAndTimePickerInitialValue() {
        guard let lastCheckInDateAndTime = SessionManager.shared.currentUser?.lastCheckInDateAndTime,
            let lastCheckOutDateAndTime = SessionManager.shared.currentUser?.lastCheckOutDateAndTime else { return }
        
        arrivalTimePicker.rx.value.onNext(lastCheckInDateAndTime)
        refreshTextFieldWithNewTime(textField: arrivalTimeTextField, newTime: lastCheckInDateAndTime)
        arrivalDatePicker.rx.value.onNext(lastCheckInDateAndTime)
        refreshTextFieldWithNewDate(textField: arrivalDateTextField, newDate: lastCheckInDateAndTime)
        arrivalDateAndTime = lastCheckInDateAndTime
        arrivalDateAndTimeChanges.onNext(lastCheckInDateAndTime)
        
        leavingTimePicker.rx.value.onNext(lastCheckOutDateAndTime)
        refreshTextFieldWithNewTime(textField: leavingTimeTextField, newTime: lastCheckOutDateAndTime)
        leavingDatePicker.rx.value.onNext(lastCheckOutDateAndTime)
        refreshTextFieldWithNewDate(textField: leavingDateTextField, newDate: lastCheckOutDateAndTime)
        leavingDateAndTime = lastCheckOutDateAndTime
        leavingDateAndTimeChanges.onNext(leavingDateAndTime)
        
        showFreshWorkingHoursAndMinutesLabel()
    }
    
    private func showFreshWorkingHoursAndMinutesLabel() {
        guard let lastCheckInDateAndTime = SessionManager.shared.currentUser?.lastCheckInDateAndTime,
            let lastCheckOutDateAndTime = SessionManager.shared.currentUser?.lastCheckOutDateAndTime else { return }
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: lastCheckInDateAndTime)
        let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: lastCheckOutDateAndTime)
        
        let timeDifference = Formatter.shared.findTimeDifference(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                 secondDate: leavingDateAndTimeWithZeroSeconds)
        
        workingHours.onNext(timeDifference.0)
        workingMinutes.onNext(timeDifference.1)
    }
    
    private func addGestureRecogniser() {
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
}

// MARK: - UI rendering
private extension ShiftViewController {
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor.unpauseWhite
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.topMargin.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
        scrollView.alwaysBounceVertical = true
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    func renderArrivalInfoLabel() {
        containerView.addSubview(arrivalInfoLabel)
        arrivalInfoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
        }
        arrivalInfoLabel.text = "Arrival info"
        arrivalInfoLabel.font = .systemFont(ofSize: 20, weight: .semibold)
    }
    
    func configureArrivalStackView() {
        containerView.addSubview(arrivalStackView)
        arrivalStackView.snp.makeConstraints { make in
            make.top.equalTo(arrivalInfoLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
        }
        arrivalStackView.axis = .horizontal
        arrivalStackView.alignment = .leading
        arrivalStackView.distribution = .equalSpacing
        arrivalStackView.spacing = 35
    }
    
    func renderArrivalImageView() {
        arrivalStackView.addArrangedSubview(arrivalImageView)
        arrivalImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        arrivalImageView.image = UIImage(named: "unpause_white_logo_75x75")
    }
    
    func renderArrivalDateStackView() {
        arrivalStackView.addArrangedSubview(arrivalDateStackView)
        arrivalDateStackView.axis = .vertical
        arrivalDateStackView.alignment = .center
        arrivalDateStackView.distribution = .equalSpacing
        arrivalDateStackView.spacing = 5
        
        arrivalDateStackView.addArrangedSubview(arrivalDateImageView)
        arrivalDateImageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
        }
        arrivalDateImageView.image = UIImage(named: "calendar_75x75_black")
        
        arrivalDateStackView.addArrangedSubview(arrivalDateTextField)
        arrivalDateTextField.font = .systemFont(ofSize: 10)
        arrivalDateTextField.text = "-"
        arrivalDateTextField.tintColor = .clear
    }
    
    func renderArrivalTimeStackView() {
        arrivalStackView.addArrangedSubview(arrivalTimeStackView)
        
        arrivalTimeStackView.axis = .vertical
        arrivalTimeStackView.alignment = .center
        arrivalTimeStackView.distribution = .equalSpacing
        arrivalTimeStackView.spacing = 5
        
        arrivalTimeStackView.addArrangedSubview(arrivalTimeImageView)
        arrivalTimeImageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
        }
        arrivalTimeImageView.image = UIImage(named: "time_75x75_black")
        
        arrivalTimeStackView.addArrangedSubview(arrivalTimeTextField)
        arrivalTimeTextField.font = .systemFont(ofSize: 10)
        arrivalTimeTextField.text = "-"
        arrivalTimeTextField.tintColor = .clear
    }
    
    func renderArrivalSeparator() {
        containerView.addSubview(arrivalSeparator)
        arrivalSeparator.snp.makeConstraints { make in
            make.top.equalTo(arrivalStackView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        arrivalSeparator.backgroundColor = .unpauseLightGray
    }
    
    func renderJobDescriptionLabel() {
        containerView.addSubview(jobDescriptionLabel)
        jobDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(arrivalSeparator.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
        }
        jobDescriptionLabel.text = "Job description:"
        jobDescriptionLabel.font = .systemFont(ofSize: 20, weight: .semibold)
    }
    
    func renderJobDescriptionTextView() {
        containerView.addSubview(jobDescriptionTextView)
        jobDescriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(jobDescriptionLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().inset(25)
            make.height.equalTo(120)
        }
        jobDescriptionTextView.layer.cornerRadius = 10
        jobDescriptionTextView.autocorrectionType = .no
        jobDescriptionTextView.autocapitalizationType = .sentences
    }
    
    func renderJobDescriptionSeparator() {
        containerView.addSubview(jobDescriptionSeparator)
        jobDescriptionSeparator.snp.makeConstraints { make in
            make.top.equalTo(jobDescriptionTextView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        jobDescriptionSeparator.backgroundColor = .unpauseLightGray
    }
    
    func renderLeavingInfoLabel() {
        containerView.addSubview(leavingInfoLabel)
        leavingInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(jobDescriptionSeparator.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
        }
        leavingInfoLabel.text = "Leaving info"
        leavingInfoLabel.font = .systemFont(ofSize: 20, weight: .semibold)
    }
    
    func configureLeavingStackView() {
        containerView.addSubview(leavingStackView)
        leavingStackView.snp.makeConstraints { make in
            make.top.equalTo(leavingInfoLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
        }
        leavingStackView.axis = .horizontal
        leavingStackView.alignment = .leading
        leavingStackView.distribution = .equalSpacing
        leavingStackView.spacing = 35
    }
    
    func renderLeavingImageView() {
        leavingStackView.addArrangedSubview(leavingImageView)
        leavingImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        leavingImageView.image = UIImage(named: "unpause_white_logo_75x75")
    }
    
    func renderLeavingDateStackView() {
        leavingStackView.addArrangedSubview(leavingDateStackView)
        leavingDateStackView.axis = .vertical
        leavingDateStackView.alignment = .center
        leavingDateStackView.distribution = .equalSpacing
        leavingDateStackView.spacing = 5
        
        leavingDateStackView.addArrangedSubview(leavingDateImageView)
        leavingDateImageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
        }
        leavingDateImageView.image = UIImage(named: "calendar_75x75_black")
        
        leavingDateStackView.addArrangedSubview(leavingDateTextField)
        leavingDateTextField.font = .systemFont(ofSize: 10)
        leavingDateTextField.text = "-"
        leavingDateTextField.tintColor = .clear
    }
    
    func renderLeavingTimeStackView() {
        leavingStackView.addArrangedSubview(leavingTimeStackView)
        leavingTimeStackView.axis = .vertical
        leavingTimeStackView.alignment = .center
        leavingTimeStackView.distribution = .equalSpacing
        leavingTimeStackView.spacing = 5
        
        leavingTimeStackView.addArrangedSubview(leavingTimeImageView)
        leavingTimeImageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
        }
        leavingTimeImageView.image = UIImage(named: "time_75x75_black")
        
        leavingTimeStackView.addArrangedSubview(leavingTimeTextField)
        leavingTimeTextField.font = .systemFont(ofSize: 10)
        leavingTimeTextField.text = "-"
        leavingTimeTextField.tintColor = .clear
    }
    
    func renderWorkingTimeStackView() {
        leavingStackView.addArrangedSubview(workingTimeStackView)
        workingTimeStackView.axis = .vertical
        workingTimeStackView.alignment = .center
        workingTimeStackView.distribution = .equalSpacing
        workingTimeStackView.spacing = 5
        
        workingTimeStackView.addArrangedSubview(workingTimeTitleLabel)
        workingTimeTitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        workingTimeTitleLabel.text = "Working time"
        
        workingTimeStackView.addArrangedSubview(workingTimeLabel)
        workingTimeLabel.font = .systemFont(ofSize: 10, weight: .bold)
        workingTimeLabel.textColor = .unpauseOrange
        workingTimeLabel.text = "-"
    }
    
    func renderSaveButton() {
        containerView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(leavingStackView.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        saveButton.backgroundColor = .unpauseOrange
        saveButton.layer.cornerRadius = 25
        saveButton.setTitle("Save", for: .normal)
    }
}
