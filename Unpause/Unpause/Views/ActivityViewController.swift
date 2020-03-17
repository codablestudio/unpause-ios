//
//  ActivityViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 19/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import DifferenceKit
import MessageUI

class ActivityViewController: UIViewController {
    
    private let activityViewModel: ActivityViewModel
    private let disposeBag = DisposeBag()
    private let shiftNetworking = ShiftNetworking()
    
    private let refresherControl = UIRefreshControl()
    
    private let containerView = UIView()
    
    private let datesContainer = UIView()
    
    private let workingIntervalLabel = UILabel()
    
    private let fromDateStackView = UIStackView()
    private let fromDateLabel = UILabel()
    private let fromDateArrowImageView = UIImageView()
    private let fromDateTextField = PaddedTextField()
    
    private let toDateStackView = UIStackView()
    private let toDateLabel = UILabel()
    private let toDateArrowImageView = UIImageView()
    private let toDateTextField = PaddedTextField()
    
    private let separator = UIView()
    
    private let tableView = UITableView()
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    
    let documentController = UIDocumentInteractionController()
    
    private let fromDatePicker = UIDatePicker()
    private let toDatePicker = UIDatePicker()
    
    private let shiftToDelete = PublishSubject<Shift>()
    private let activityStarted = PublishSubject<Void>()
    
    private var dataSource: [ShiftsTableViewItem] = [.loading]
    
    init(activityViewModel: ActivityViewModel) {
        self.activityViewModel = activityViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setFromPickerAndTextFieldInitialDate()
        showTitleInNavigationBar()
        createPickers()
        setUpTableView()
        setUpObservables()
        addBarButtonItem()
        makeNavigationBarOpaque()
        activityStarted.onNext(())
    }
    
    private func render() {
        configureContainerView()
        configureDatesContainer()
        renderFromDateLabelAndFromDateTextField()
        renderToDateLabelAndToDateTextField()
        configureTableView()
        setUpDocumentInteractionController()
    }
    
    private func setUpObservables() {
        activityViewModel.shiftsRequest
            .subscribe(onNext: { [weak self] items in
                guard let `self` = self else { return }
                let changeset = StagedChangeset(source: self.dataSource, target: items)
                self.tableView.reload(using: changeset, with: .fade) { data in
                    self.dataSource = data
                }
                self.refresherControl.endRefreshing()
            }).disposed(by: disposeBag)
        
        refresherControl.rx.controlEvent(.valueChanged)
            .bind(to: activityViewModel.refreshTrigger)
            .disposed(by: disposeBag)
        
        fromDatePicker.rx.date
            .do(onNext: { fromDate in
                self.fromDateTextField.text = Formatter.shared.convertDateIntoString(from: fromDate)
                self.toDatePicker.minimumDate = fromDate
            })
            .bind(to: activityViewModel.dateInFromDatePickerChanges)
            .disposed(by: disposeBag)
        
        toDatePicker.rx.date
            .do(onNext: { toDate in
                self.toDateTextField.text = Formatter.shared.convertDateIntoString(from: toDate)
            })
            .bind(to: activityViewModel.dateInToDatePickerChanges)
            .disposed(by: disposeBag)
        
        shiftToDelete.bind(to: activityViewModel.shiftToDelete)
            .disposed(by: disposeBag)
        
        activityStarted
            .bind(to: activityViewModel.activityStarted)
            .disposed(by: disposeBag)
        
        observeDeletions()
    }
    
    private func observeDeletions() {
        activityViewModel.deleteRequest
            .subscribe(onNext: { [weak self] shiftDeletionsResponse in
                guard let `self` = self else { return }
                ActivityIndicatorView.shared.dissmis()
                
                switch shiftDeletionsResponse {
                case .success(let deletedShift):
                    guard let rowToDelete = self.dataSource.firstIndex(where: { $0.shift == deletedShift }) else { return }
                    self.dataSource.remove(at: rowToDelete)
                    self.tableView.deleteRows(at: [IndexPath(row: rowToDelete, section: 0)], with: .automatic)
                    ActivityViewModel.forceRefresh.onNext(())
                    
                case .error(let error):
                    print("ERROR: \(error)")
                }
            }).disposed(by: disposeBag)
    }
    
    private func showTitleInNavigationBar() {
        self.title = "Activity"
    }
    
    private func createPickers() {
        createDatePickerAndBarForPicker(for: fromDateTextField, with: fromDatePicker)
        createDatePickerAndBarForPicker(for: toDateTextField, with: toDatePicker)
    }
    
    private func createDatePickerAndBarForPicker(for textField: UITextField, with picker: UIDatePicker) {
        picker.datePickerMode = UIDatePicker.Mode.date
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
            guard let `self` = self else { return }
            ActivityViewModel.forceRefresh.onNext(())
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ShiftTableViewCell.self, forCellReuseIdentifier: "ShiftTableViewCell")
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: "EmptyTableViewCell")
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: "LoadingTableViewCell")
        
        tableView.refreshControl = refresherControl
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    private func setFromPickerAndTextFieldInitialDate() {
        fromDatePicker.date = Formatter.shared.getDateOneMontBeforeTodaysDate()
        let lastMonthDate = Formatter.shared.getDateOneMontBeforeTodaysDate()
        fromDateTextField.text = Formatter.shared.convertDateIntoString(from: lastMonthDate)
    }
    
    private func addBarButtonItem() {
        navigationItem.rightBarButtonItem = addButton
        
        addButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.showActionSheet()
        }).disposed(by: disposeBag)
    }
    
    private func makeNavigationBarOpaque() {
        navigationController?.navigationBar.isTranslucent = false
    }
    
    private func setUpDocumentInteractionController() {
        documentController.delegate = self
    }
    
    private func showActionSheet() {
        let alert = UIAlertController(title: "Please select an option", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add custom shift", style: .default , handler:{ _ in
            Coordinator.shared.presentAddShiftViewController(from: self, navigationFromCustomShift: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Send as email", style: .default, handler:{ [weak self] _ in
            guard let `self` = self else { return }
            if SessionManager.shared.currentUser?.company?.email == nil {
                self.showAlert(title: "Alert", message: "There is no company associated with you.", actionTitle: "OK")
            } else {
                self.sendEmailWithExcelSheetToCompany()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Open CSV", style: .default, handler:{ [weak self] _ in
            guard let `self` = self else { return }
            let fileURL = self.activityViewModel.makeNewCSVFileWithShiftsData(shiftsData: self.dataSource)
            switch fileURL {
            case .success(let url):
                self.documentController.url = url
                self.documentController.presentPreview(animated: true)
            case .error(let error):
                self.showAlert(title: "Alert", message: "\(error.localizedDescription)", actionTitle: "OK")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func sendEmailWithExcelSheetToCompany() {
        guard let companyEmail = SessionManager.shared.currentUser?.company?.email,
            let currentUserFirstName = SessionManager.shared.currentUser?.firstName,
            let currentuserLastName = SessionManager.shared.currentUser?.lastName else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["\(companyEmail)"])
            mail.setSubject("Working hours")
            mail.setMessageBody("<b>Hello,<br>Here are my working hours,<br>Cheers :)</b>", isHTML: true)
            
            let csvMakingResponse = self.activityViewModel.makeNewCSVFileWithShiftsData(shiftsData: self.dataSource)
            let data = activityViewModel.makeDataFrom(csvMakingResponse: csvMakingResponse)
            switch data {
            case .success(let data):
                mail.addAttachmentData(data, mimeType: "text/csv", fileName: "\(currentUserFirstName) \(currentuserLastName)")
            case .error(let error):
                self.showAlert(title: "Alert", message: error.localizedDescription, actionTitle: "OK")
            }
            self.present(mail, animated: true)
        } else {
            self.showAlert(title: "Alert", message: "Can not send email.", actionTitle: "OK")
        }
    }
}


// MARK: - UI rendering
private extension ActivityViewController {
    func configureContainerView() {
        view.backgroundColor = UIColor.unpauseWhite
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
    }
    
    func configureDatesContainer() {
        containerView.addSubview(datesContainer)
        
        datesContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        datesContainer.backgroundColor = .unpauseOrange
        datesContainer.layer.cornerRadius = 25
        datesContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func renderFromDateLabelAndFromDateTextField() {
        datesContainer.addSubview(fromDateStackView)
        
        fromDateStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().inset(15)
            make.left.equalToSuperview().offset(50)
        }
        
        fromDateStackView.axis = .vertical
        fromDateStackView.alignment = .center
        fromDateStackView.distribution = .equalSpacing
        fromDateStackView.spacing = 5
        
        fromDateStackView.addArrangedSubview(fromDateLabel)
        fromDateLabel.text = "From"
        fromDateLabel.font = UIFont.boldSystemFont(ofSize: 20)
        fromDateLabel.textColor = .unpauseWhite
        
        fromDateStackView.addArrangedSubview(fromDateTextField)
        fromDateTextField.textColor = .unpauseWhite
    }
    
    func renderToDateLabelAndToDateTextField() {
        datesContainer.addSubview(toDateStackView)
        
        toDateStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().inset(15)
            make.right.equalToSuperview().inset(50)
        }
        
        toDateStackView.axis = .vertical
        toDateStackView.alignment = .center
        toDateStackView.distribution = .equalSpacing
        toDateStackView.spacing = 5
        
        toDateStackView.addArrangedSubview(toDateLabel)
        toDateLabel.text = "To"
        toDateLabel.font = UIFont.boldSystemFont(ofSize: 20)
        toDateLabel.textColor = .unpauseWhite
        
        toDateStackView.addArrangedSubview(toDateTextField)
        toDateTextField.textColor = .unpauseWhite
    }
    
    func configureTableView() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        containerView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(datesContainer.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

//MARK: - Table View Delegate
extension ActivityViewController: UITableViewDelegate {    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Coordinator.shared.presentAddShiftViewController(from: self, with: dataSource[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        ActivityIndicatorView.shared.show(on: self.view)
        
        switch dataSource[indexPath.row] {
        case .shift(let shift):
            shiftToDelete.onNext(shift)
        default:
            ActivityIndicatorView.shared.dissmis()
        }
    }
}

//MARK: - Table View DataSource
extension ActivityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch dataSource[indexPath.row] {
        case .shift(let shift):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ShiftTableViewCell.self),
                                                     for: indexPath) as! ShiftTableViewCell
            cell.configure(shift)
            return cell
            
        case .empty:
            tableView.separatorStyle = .none
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EmptyTableViewCell.self),
                                                     for: indexPath) as! EmptyTableViewCell
            return cell
            
        case .loading:
            tableView.separatorStyle = .none
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LoadingTableViewCell.self),
                                                     for: indexPath) as! LoadingTableViewCell
            return cell
        }
    }
}

//MARK: - UIDocumentInteractionController delegate
extension ActivityViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

//MARK: - MFMailComposeViewController delegate
extension ActivityViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
            
        case MFMailComposeResult.saved.rawValue:
            ActivityIndicatorView.shared.dissmis()
            
        case MFMailComposeResult.sent.rawValue:
            ActivityIndicatorView.shared.dissmis()
            
        case MFMailComposeResult.failed.rawValue:
            showAlert(title: "Alert", message: error!.localizedDescription, actionTitle: "OK")
            
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UIScrollView delegate
extension ActivityViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0{
            changeTabBarVisibility(hidden: true, animated: true)
            changeNavigatioBarVisibility(hidden: true)
            changeDatesContainerVisibility(hidden: true, animated: true)
            
        }
        else{
            changeTabBarVisibility(hidden: false, animated: true)
            changeNavigatioBarVisibility(hidden: false)
            changeDatesContainerVisibility(hidden: false, animated: true)
            
        }
    }
}

//MARK: - Animations
private extension ActivityViewController {
    func changeTabBarVisibility(hidden: Bool, animated: Bool){
        let tabBar = self.tabBarController?.tabBar
        let offset = (hidden ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.height - (tabBar?.frame.size.height)!)
        if offset == tabBar?.frame.origin.y { return }
        let duration: TimeInterval = (animated ? 0.2 : 0.0)
        UIView.animate(withDuration: duration,
                       animations: { tabBar!.frame.origin.y = offset },
                       completion: nil)
    }
    
    func changeDatesContainerVisibility(hidden: Bool, animated: Bool) {
        let offset = (hidden ? view.safeAreaInsets.top - datesContainer.bounds.height : view.safeAreaInsets.top)
        if offset == datesContainer.frame.origin.y { return }
        let duration: TimeInterval = (animated ? 0.2 : 0.0)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
                        guard let `self` = self else { return }
                        self.datesContainer.frame.origin.y = offset
                        self.remakeTableViewConstraints(hidden: hidden)
            },
                       completion: nil)
    }
    
    func remakeTableViewConstraints(hidden: Bool) {
        if hidden {
            tableView.snp.remakeConstraints { make in
                make.top.equalTo(view.safeAreaInsets.top - datesContainer.bounds.height - 25)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        } else {
            tableView.snp.remakeConstraints { make in
                make.top.equalTo(self.datesContainer.snp.bottom)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
    }
    
    func changeNavigatioBarVisibility(hidden: Bool) {
        navigationController?.navigationBar.isHidden = hidden
    }
}
