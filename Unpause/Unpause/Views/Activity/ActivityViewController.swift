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
    
    private let activityViewModel: ActivityViewModelProtocol
    private let disposeBag = DisposeBag()
    private let shiftNetworking = ShiftNetworking()
    
    private let refresherControl = UIRefreshControl()
    
    private let containerView = UIView()
    
    private let datesContainer = UIView()
    
    private let fromDateContainerView = UIView()
    private let fromDateLabel = UILabel()
    private let fromDateArrowImageView = UIImageView()
    private let fromDateTextField = PaddedTextField()
    private let fromDateTextFieldDoneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                                              target: self,
                                                              action: nil)
    
    private let arrowSeparator = UIImageView()
    
    private let toDateContainerView = UIView()
    private let toDateLabel = UILabel()
    private let toDateArrowImageView = UIImageView()
    private let toDateTextField = PaddedTextField()
    private let toDateTextFieldDoneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: nil)
    
    private let tableView = UITableView()
    
    private let dotsButton = DotsUIBarButtonItem()
    
    let documentController = UIDocumentInteractionController()
    
    private let fromDatePicker = UIDatePicker()
    private let toDatePicker = UIDatePicker()
    
    private let shiftToDelete = PublishSubject<Shift>()
    private let activityStarted = PublishSubject<Void>()
    
    private var dataSource: [ShiftsTableViewItem] = [.loading]
    
    var selectedCell: ShiftTableViewCell?
    var selectedCellContainerViewSnapshot: UIView?
    
    var animator: Animator?
    
    init(activityViewModel: ActivityViewModelProtocol) {
        self.activityViewModel = activityViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpDocumentInteractionController()
        setFromPickerAndTextFieldInitialDate()
        showTitleInNavigationBar()
        createPickers()
        setUpTableView()
        setUpObservables()
        addBarButtonItem()
        activityStarted.onNext(())
    }
    
    private func render() {
        configureContainerView()
        configureDatesContainer()
        configureTableView()
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
        
        fromDateTextFieldDoneButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                ActivityViewModel.forceRefresh.onNext(())
                self.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        toDateTextFieldDoneButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            ActivityViewModel.forceRefresh.onNext(())
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected
        .subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else { return }
            self.selectedCell = self.tableView.cellForRow(at: indexPath) as? ShiftTableViewCell
            self.selectedCellContainerViewSnapshot = self.selectedCell?.containerView.snapshotView(afterScreenUpdates: false)
            Coordinator.shared.presentAddShiftViewController(from: self, with: self.dataSource[indexPath.row])
        }).disposed(by: disposeBag)
        
        observeDeletions()
    }
    
    private func observeDeletions() {
        activityViewModel.deleteRequest
            .subscribe(onNext: { [weak self] shiftDeletionsResponse in
                guard let `self` = self else { return }
                UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                
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
    
    private func rotateViewBy(viewToRotate: UIView, by rotationAngle: Double) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
                        viewToRotate.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        },
                       completion: nil)
    }
    
    private func createPickers() {
        createDatePickerAndBarForPicker(for: fromDateTextField, with: fromDatePicker, barButton: fromDateTextFieldDoneButton)
        createDatePickerAndBarForPicker(for: toDateTextField, with: toDatePicker, barButton: toDateTextFieldDoneButton)
    }
    
    private func createDatePickerAndBarForPicker(for textField: UITextField, with picker: UIDatePicker, barButton: UIBarButtonItem) {
        picker.datePickerMode = UIDatePicker.Mode.date
        textField.inputView = picker
        picker.backgroundColor = UIColor.unpauseWhite
        addBarAndBarButtonOnTopOfPicker(for: textField, barButton: barButton)
    }
    
    private func addBarAndBarButtonOnTopOfPicker(for textField: UITextField, barButton: UIBarButtonItem) {
        let bar = UIToolbar()
        bar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        bar.setItems([flexibleSpace, barButton], animated: false)
        bar.isUserInteractionEnabled = true
        textField.inputAccessoryView = bar
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ShiftTableViewCell.self, forCellReuseIdentifier: "ShiftTableViewCell")
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: "EmptyTableViewCell")
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: "LoadingTableViewCell")
        
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refresherControl
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    private func setFromPickerAndTextFieldInitialDate() {
        fromDatePicker.date = Formatter.shared.getDateOneMontBeforeTodaysDate()
        let lastMonthDate = Formatter.shared.getDateOneMontBeforeTodaysDate()
        fromDateTextField.text = Formatter.shared.convertDateIntoString(from: lastMonthDate)
    }
    
    private func addBarButtonItem() {
        navigationItem.rightBarButtonItem = dotsButton
        
        dotsButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.showActionSheet()
        }).disposed(by: disposeBag)
    }
    
    private func setUpDocumentInteractionController() {
        documentController.delegate = self
    }
    
    private func showActionSheet() {
        let alert = UIAlertController(title: "Please select an option", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add custom shift", style: .default , handler:{ [weak self] _ in
            guard let `self` = self else { return }
            Coordinator.shared.presentAddShiftViewController(from: self, navigationFromCustomShift: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Send as email", style: .default, handler:{ _ in
            self.handleSendAsEmailTapped()
        }))
        
        alert.addAction(UIAlertAction(title: "Open CSV", style: .default, handler:{ _ in
            self.handleOpenCSVTapped()
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
            mail.setPreferredSendingEmailAddress(SessionManager.shared.getCurrentUserEmail())
            mail.setToRecipients(["\(companyEmail)"])
            mail.setSubject("Working hours")
            mail.setMessageBody("<b>Hello,<br>Here are my working hours,<br>Cheers :)</b>", isHTML: true)
            
            let csvMakingResponse = self.activityViewModel.makeNewCSVFileWithShiftsData(shiftsData: self.dataSource)
            let data = activityViewModel.makeDataFrom(csvMakingResponse: csvMakingResponse)
            switch data {
            case .success(let data):
                mail.addAttachmentData(data, mimeType: "text/csv", fileName: "\(currentUserFirstName) \(currentuserLastName)")
            case .error(let error):
                self.showOneOptionAlert(title: "Alert", message: error.errorMessage, actionTitle: "OK")
            }
            self.present(mail, animated: true)
        } else {
            self.showOneOptionAlert(title: "Alert", message: "Can not send email.", actionTitle: "OK")
        }
    }
    
    func showTwoOptionsAlert(title: String, message: String, firstActionTitle: String, secondActionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: firstActionTitle, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: secondActionTitle, style: .default, handler: { uiAlertAction in
            Coordinator.shared.presentAddCompanyViewController(from: self)
        }))
        self.present(alert, animated: true)
    }
}

// MARK: - Email
private extension ActivityViewController {
    func handleSendAsEmailTapped() {
        if SessionManager.shared.currentUser?.company?.email == nil {
            let messsage = "It looks like you didn‘t add your company. Would you like too add it?"
            self.showTwoOptionsAlert(title: "Alert", message: messsage, firstActionTitle: "Cancel", secondActionTitle: "Add")
        } else if let user = SessionManager.shared.currentUser {
            UnpauseActivityIndicatorView.shared.show(on: self.view)
            user.checkIfUserHasValidSubscription(onCompleted: { [weak self] hasValidSubscription in
                guard let `self` = self else { return }
                UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                if hasValidSubscription {
                    self.sendEmailWithExcelSheetToCompany()
                } else {
                    Coordinator.shared.presentUpgradeToProViewController(from: self)
                }
            })
        }
    }
}

// MARK: - CSV
private extension ActivityViewController {
    func handleOpenCSVTapped() {
        guard let user = SessionManager.shared.currentUser else { return }
        let fileURL = self.activityViewModel.makeNewCSVFileWithShiftsData(shiftsData: self.dataSource)
        switch fileURL {
        case .success(let url):
            UnpauseActivityIndicatorView.shared.show(on: self.view)
            user.checkIfUserHasValidSubscription { [weak self] hasValidSubscription in
                guard let `self` = self else { return }
                UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                if hasValidSubscription {
                    self.documentController.url = url
                    self.documentController.presentPreview(animated: true)
                } else {
                    Coordinator.shared.presentUpgradeToProViewController(from: self)
                }
            }
        case .error(let error):
            self.showOneOptionAlert(title: "Alert", message: "\(error.errorMessage)", actionTitle: "OK")
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
        datesContainer.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        renderArrowSeparatorView()
        renderFromDateContainerViewAndItsSubviews()
        renderToDateContainerViewAndItsSubviews()
    }
    
    func renderArrowSeparatorView() {
        datesContainer.addSubview(arrowSeparator)
        arrowSeparator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.width.equalTo(15)
        }
        arrowSeparator.image = UIImage(named: "arrow_15x15_white")
    }
    
    func renderFromDateContainerViewAndItsSubviews() {
        datesContainer.addSubview(fromDateContainerView)
        fromDateContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.right.equalTo(arrowSeparator.snp.left).offset(-12)
            make.bottom.equalToSuperview().inset(4)
        }
        fromDateContainerView.layer.borderWidth = 1
        fromDateContainerView.layer.cornerRadius = 10
        fromDateContainerView.layer.borderColor = UIColor.unpauseWhite.cgColor
        
        fromDateContainerView.addSubview(fromDateArrowImageView)
        fromDateArrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.height.width.equalTo(21)
        }
        fromDateArrowImageView.image = UIImage(named: "calendar_30x30_white")
        fromDateArrowImageView.contentMode = .scaleAspectFit
        
        fromDateContainerView.addSubview(fromDateTextField)
        fromDateTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalTo(fromDateArrowImageView.snp.right).offset(2)
            make.right.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(6)
        }
        fromDateTextField.textColor = .unpauseWhite
    }
    
    func renderToDateContainerViewAndItsSubviews() {
        datesContainer.addSubview(toDateContainerView)
        toDateContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalTo(arrowSeparator.snp.right).offset(12)
            make.bottom.equalToSuperview().inset(4)
        }
        toDateContainerView.layer.borderWidth = 1
        toDateContainerView.layer.cornerRadius = 10
        toDateContainerView.layer.borderColor = UIColor.unpauseWhite.cgColor
        
        toDateContainerView.addSubview(toDateArrowImageView)
        toDateArrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.height.width.equalTo(21)
        }
        toDateArrowImageView.image = UIImage(named: "calendar_30x30_white")
        toDateArrowImageView.contentMode = .scaleAspectFit
        
        toDateContainerView.addSubview(toDateTextField)
        toDateTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalTo(toDateArrowImageView.snp.right).offset(2)
            make.right.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(6)
        }
        toDateTextField.textColor = .unpauseWhite
    }
    
    func configureTableView() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        
        containerView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(datesContainer.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

//MARK: - Table View Delegate
extension ActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        UnpauseActivityIndicatorView.shared.show(on: self.view)
        
        switch dataSource[indexPath.row] {
        case .shift(let shift):
            shiftToDelete.onNext(shift)
        default:
            UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
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
            tableView.allowsSelection = true
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ShiftTableViewCell.self),
                                                     for: indexPath) as! ShiftTableViewCell
            cell.configure(shift)
            return cell
        case .empty:
            tableView.allowsSelection = false
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EmptyTableViewCell.self),
                                                     for: indexPath) as! EmptyTableViewCell
            return cell
            
        case .loading:
            tableView.allowsSelection = false
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
            UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
            
        case MFMailComposeResult.sent.rawValue:
            UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
            
        case MFMailComposeResult.failed.rawValue:
            showOneOptionAlert(title: "Alert", message: error!.localizedDescription, actionTitle: "OK")
            
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ActivityViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let firstViewController = presenting as? CustomTabBarController,
            let secondViewController = presented as? UINavigationController,
            let selectedCellContainerViewSnapshot = selectedCellContainerViewSnapshot
            else {
                return nil
        }
        
        animator = Animator(type: .present,
                            firstViewController: firstViewController,
                            secondViewController: secondViewController,
                            selectedCellContainerViewSnapshot: selectedCellContainerViewSnapshot)
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let secondViewController = dismissed as? UINavigationController,
            let selectedCellContainerViewSnapshot = selectedCellContainerViewSnapshot,
            let tabbar = self.tabBarController as? CustomTabBarController else {
                return nil
        }
        
        animator = Animator(type: .dismiss, firstViewController: tabbar, secondViewController: secondViewController, selectedCellContainerViewSnapshot: selectedCellContainerViewSnapshot)
        return animator
    }
}
