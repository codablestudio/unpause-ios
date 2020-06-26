//
//  EditShiftViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import RxKeyboard

class EditShiftViewController: UIViewController {
    
    private let editShiftViewModel: EditShiftViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    // MARK:  Arrival
    private let arrivalInfoLabel = UILabel()
    private let stackView = UIStackView()
    private let arrivalStackView = UIStackView()
    private let arrivalImageView = UIImageView()
    
    private let arrivalDateView = IconAndTextVerticalView()
    private let arrivalTimeView = IconAndTextVerticalView()
    
    private let arrivalSeparator = UIView()
    
    // MARK: Description
    private let jobDescriptionLabel = UILabel()
    private let jobDescriptionTextView = UITextView()
    
    private let jobDescriptionSeparator = UIView()
    
    // MARK: Leaving
    private let leavingInfoLabel = UILabel()
    private let leavingStackView = UIStackView()
    private let leavingImageView = UIImageView()
    private let leavingDateView = IconAndTextVerticalView()
    private let leavingTimeView = IconAndTextVerticalView()
    
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
    private var textInDescriptionTextViewChanges = PublishSubject<String?>()
    
    var shiftToEdit: ShiftsTableViewItem
    
    init(editShiftViewModel: EditShiftViewModelProtocol, shiftToEdit: ShiftsTableViewItem) {
        self.editShiftViewModel = editShiftViewModel
        self.shiftToEdit = shiftToEdit
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
        setUpJobDescriptionText()
        addGestureRecogniser()
        setUpKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpViewControllerTitle()
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
                self.handleArrivalFieldsWhenEditingShift(arrivalDate: arrivalDate, arrivalTime: arrivalTime)
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(leavingDatePicker.rx.value, leavingTimePicker.rx.value)
            .subscribe(onNext: { [weak self] leavingDate, leavingTime in
                guard let `self` = self else { return }
                self.handleLeavingFieldsWhenEditingShift(leavingDate: leavingDate, leavingTime: leavingTime)
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(workingHours, workingMinutes)
            .subscribe(onNext: { [weak self] (workingHours, workingMinutes) in
                guard let `self` = self else { return }
                self.workingTimeLabel.text = "\(workingHours) h \(workingMinutes) min"
            }).disposed(by: disposeBag)
        
        textInDescriptionTextViewChanges
            .bind(to: editShiftViewModel.textInDescriptionTextViewChanges)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { _ in
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        arrivalDateView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.arrivalDateView.textField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        arrivalTimeView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.arrivalTimeView.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        leavingDateView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.leavingDateView.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        leavingTimeView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.leavingTimeView.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        arrivalDateAndTimeChanges.bind(to: editShiftViewModel.arrivalDateAndTimeChanges)
            .disposed(by: disposeBag)
        
        leavingDateAndTimeChanges.bind(to: editShiftViewModel.leavingDateAndTimeChanges)
            .disposed(by: disposeBag)
        
        jobDescriptionTextView.rx.text
            .bind(to: editShiftViewModel.textInDescriptionTextViewChanges)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                UnpauseActivityIndicatorView.shared.show(on: self.view)
            })
            .bind(to: editShiftViewModel.saveButtonTapped)
            .disposed(by: disposeBag)
        
        editShiftViewModel.shiftEditingResponse
        .subscribe(onNext: { [weak self] response in
            guard let `self` = self else { return }
            switch response {
            case .success:
                UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                ActivityViewModel.forceRefresh.onNext(())
                self.dismiss(animated: true)
            case .error(let error):
                UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                self.showOneOptionAlert(title: "Error", message: "\(error.errorMessage)", actionTitle: "OK")
            }
        }).disposed(by: disposeBag)
    }
    
    func handleArrivalFieldsWhenEditingShift(arrivalDate: Date, arrivalTime: Date) {
        guard let leavingDateAndTimeInDateFormat = leavingDateAndTime else { return }
        
        refreshTextFieldWithNewDate(textField: arrivalDateView.textField, newDate: arrivalDate)
        refreshTextFieldWithNewTime(textField: arrivalTimeView.textField, newTime: arrivalTime)
        
        let arrivalDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: arrivalDate)
        let leavingDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: leavingDateAndTimeInDateFormat)
        
        if arrivalDateWithStartingDayTime == leavingDateWithStartingDayTime {
            leavingTimePicker.minimumDate = arrivalTime
        } else {
            leavingTimePicker.minimumDate = nil
        }
        
        guard let newArrivalDateAndTime = Formatter.shared.makeNewDateAndTimeInDateFormat(
            dateInDateFormat: arrivalDate,
            timeInDateFormat: arrivalTime) else { return }
        
        arrivalDateAndTime = newArrivalDateAndTime
        arrivalDateAndTimeChanges.onNext(newArrivalDateAndTime)
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: newArrivalDateAndTime)
        let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: leavingDateAndTimeInDateFormat)
        
        let timeDifference = Formatter.shared.findTimeDifference(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                 secondDate: leavingDateAndTimeWithZeroSeconds)
        
        workingHours.onNext(timeDifference.0)
        workingMinutes.onNext(timeDifference.1)
    }
    
    func handleLeavingFieldsWhenEditingShift(leavingDate: Date, leavingTime: Date) {
        guard let arrivalDateAndTimeInDateFormat = arrivalDateAndTime else { return }
        
        refreshTextFieldWithNewDate(textField: leavingDateView.textField, newDate: leavingDate)
        refreshTextFieldWithNewTime(textField: leavingTimeView.textField, newTime: leavingTime)
        
        let arrivalDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: arrivalDateAndTimeInDateFormat)
        let leavingDateWithStartingDayTime = Formatter.shared.getDateWithStartingDayTime(fromDate: leavingDate)
        
        if arrivalDateWithStartingDayTime == leavingDateWithStartingDayTime {
            leavingTimePicker.minimumDate = arrivalDateAndTimeInDateFormat
        } else {
            leavingTimePicker.minimumDate = nil
        }
        
        guard let newLeavingDateAndTime = Formatter.shared.makeNewDateAndTimeInDateFormat(
            dateInDateFormat: leavingDate,
            timeInDateFormat: leavingTime) else { return }
        
        leavingDateAndTime = newLeavingDateAndTime
        leavingDateAndTimeChanges.onNext(newLeavingDateAndTime)
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: arrivalDateAndTimeInDateFormat)
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
        createDatePickerAndBarForPicker(for: arrivalDateView.textField, with: arrivalDatePicker)
        createTimePickerAndBarForPicker(for: arrivalTimeView.textField, with: arrivalTimePicker)
        createDatePickerAndBarForPicker(for: leavingDateView.textField, with: leavingDatePicker)
        createTimePickerAndBarForPicker(for: leavingTimeView.textField, with: leavingTimePicker)
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
        let checkInDateAndTime = Formatter.shared.convertTimeStampIntoDate(timeStamp: shiftToEdit.shift?.arrivalTime)
        let checkOutDateAndTime = Formatter.shared.convertTimeStampIntoDate(timeStamp: shiftToEdit.shift?.exitTime)
        
        guard let checkInDateAndTimeInDateFormat = checkInDateAndTime,
            let checkOutDateAndTimeInDateFormat = checkOutDateAndTime else { return }
        
        
        arrivalTimePicker.rx.value.onNext(checkInDateAndTimeInDateFormat)
        refreshTextFieldWithNewTime(textField: arrivalTimeView.textField, newTime: checkInDateAndTimeInDateFormat)
        arrivalDatePicker.rx.value.onNext(checkInDateAndTimeInDateFormat)
        refreshTextFieldWithNewDate(textField: arrivalDateView.textField, newDate: checkInDateAndTimeInDateFormat)
        arrivalDateAndTime = checkInDateAndTimeInDateFormat
        arrivalDateAndTimeChanges.onNext(checkInDateAndTimeInDateFormat)
        
        leavingTimePicker.rx.value.onNext(checkOutDateAndTimeInDateFormat)
        refreshTextFieldWithNewTime(textField: leavingTimeView.textField, newTime: checkOutDateAndTimeInDateFormat)
        leavingDatePicker.rx.value.onNext(checkOutDateAndTimeInDateFormat)
        refreshTextFieldWithNewDate(textField: leavingDateView.textField, newDate: checkOutDateAndTimeInDateFormat)
        leavingDateAndTime = checkOutDateAndTimeInDateFormat
        leavingDateAndTimeChanges.onNext(checkOutDateAndTimeInDateFormat)
        
        showFreshWorkingHoursAndMinutesLabel()
    }
    
    private func showFreshWorkingHoursAndMinutesLabel() {
        let arrivalDateAndTime = Formatter.shared.convertTimeStampIntoDate(timeStamp: shiftToEdit.shift?.arrivalTime)
        let leavingDateAndTime = Formatter.shared.convertTimeStampIntoDate(timeStamp: shiftToEdit.shift?.exitTime)
        
        guard let arrivalDateAndTimeInDateFormat = arrivalDateAndTime,
            let leavingDateAndTimeInDateFormat = leavingDateAndTime else { return }
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: arrivalDateAndTimeInDateFormat)
        let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: leavingDateAndTimeInDateFormat)
        
        let timeDifference = Formatter.shared.findTimeDifference(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                 secondDate: leavingDateAndTimeWithZeroSeconds)
        
        workingHours.onNext(timeDifference.0)
        workingMinutes.onNext(timeDifference.1)
    }
    
    private func setUpJobDescriptionText() {
        jobDescriptionTextView.text = shiftToEdit.shift?.description
        textInDescriptionTextViewChanges.onNext(shiftToEdit.shift?.description)
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
    
    private func setUpViewControllerTitle() {
        self.title = "Editing shift"
    }
}

// MARK: - UI rendering
private extension EditShiftViewController {
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
        arrivalStackView.addArrangedSubview(arrivalDateView)
        arrivalDateView.setup(icon: UIImage(named: "calendar_75x75_black"))
    }
    
    func renderArrivalTimeStackView() {
        arrivalStackView.addArrangedSubview(arrivalTimeView)
        arrivalTimeView.setup(icon: UIImage(named: "time_75x75_black"))
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
        jobDescriptionTextView.backgroundColor = .unpauseVeryLightGray
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
        leavingStackView.addArrangedSubview(leavingDateView)
        leavingDateView.setup(icon: UIImage(named: "calendar_75x75_black"))
    }
    
    func renderLeavingTimeStackView() {
        leavingStackView.addArrangedSubview(leavingTimeView)
        leavingTimeView.setup(icon: UIImage(named: "time_75x75_black"))
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
