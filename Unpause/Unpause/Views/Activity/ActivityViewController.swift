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
import FSCalendar

class ActivityViewController: UIViewController {
    
    private let activityViewModel: ActivityViewModelProtocol
    private var calendarViewController: CalendarViewController
    private let shiftNetworking = ShiftNetworking()
    private let disposeBag = DisposeBag()

    private let refresherControl = UIRefreshControl()
    
    private let containerView = UIView()
    
    private let datesContainer = UIView()
    private let firstFilterDateLabel = UILabel()
    
    private let separator = UIView()
    
    private let secondFilterDateLabel = UILabel()
    
    private let calendarImageView = UIImageView()
    
    private let tableView = UITableView()
    
    private let dotsButton = DotsUIBarButtonItem()
    
    let documentController = UIDocumentInteractionController()
    
    private let shiftToDelete = PublishSubject<Shift>()
    private let activityStarted = PublishSubject<Void>()
    
    private var dataSource: [ShiftsTableViewItem] = [.loading]
    
    var selectedCell: ShiftTableViewCell?
    var selectedCellContainerViewSnapshot: UIView?
    
    var animator: Animator?
    
    var firstFilterDateChanges = PublishSubject<Date>()
    var secondFilterDateChanges = PublishSubject<Date>()
    
    init(activityViewModel: ActivityViewModelProtocol, calendarViewController: CalendarViewController) {
        self.calendarViewController = calendarViewController
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
        setFirstFilterDateLabelInitialDate()
        showTitleInNavigationBar()
        setUpTableView()
        setUpObservables()
        addBarButtonItems()
        activityStarted.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ActivityViewModel.forceRefresh.onNext(())
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
        
        firstFilterDateChanges
        .startWith(Formatter.shared.getDateOneMontBeforeTodaysDate())
            .bind(to: activityViewModel.firstFilterDateChanges)
            .disposed(by: disposeBag)
        
        secondFilterDateChanges
        .startWith(Date())
            .bind(to: activityViewModel.secondFilterDateChanges)
            .disposed(by: disposeBag)
        
        shiftToDelete
            .bind(to: activityViewModel.shiftToDelete)
            .disposed(by: disposeBag)
        
        activityStarted
            .bind(to: activityViewModel.activityStarted)
            .disposed(by: disposeBag)
        
        calendarViewController.datesRangeChanges
            .subscribe(onNext: { newDatesRange in
                let firstFilterDate = newDatesRange.first ?? Date()
                let secondFilterDate = newDatesRange.last ?? Date()
                self.firstFilterDateChanges.onNext(firstFilterDate)
                self.secondFilterDateChanges.onNext(secondFilterDate)
                self.firstFilterDateLabel.text = Formatter.shared.convertDateIntoString(from: firstFilterDate)
                self.secondFilterDateLabel.text = Formatter.shared.convertDateIntoString(from: secondFilterDate)
                ActivityViewModel.forceRefresh.onNext(())
            }).disposed(by: disposeBag)
        
        datesContainer.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                Coordinator.shared.presentCalendarViewController(from: self, calendarViewController: self.calendarViewController)
            }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected
        .subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else { return }
            self.selectedCell = self.tableView.cellForRow(at: indexPath) as? ShiftTableViewCell
            self.selectedCellContainerViewSnapshot = self.selectedCell?.containerView.snapshotView(afterScreenUpdates: false)
            Coordinator.shared.presentEditShiftViewController(from: self, shiftToEdit: self.dataSource[indexPath.row])
        }).disposed(by: disposeBag)
        
        observeDeletions()
    }
    
    private func observeDeletions() {
        activityViewModel.deleteRequest
            .subscribe(onNext: { [weak self] shiftDeletionsResponse in
                guard let `self` = self else { return }
                UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                
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
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ShiftTableViewCell.self, forCellReuseIdentifier: "ShiftTableViewCell")
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: "EmptyTableViewCell")
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: "LoadingTableViewCell")
        
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.refreshControl = refresherControl
    }
    
    private func setFirstFilterDateLabelInitialDate() {
        let lastMonthDate = Formatter.shared.getDateOneMontBeforeTodaysDate()
        firstFilterDateLabel.text = Formatter.shared.convertDateIntoString(from: lastMonthDate)
    }
    
    private func addBarButtonItems() {
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
            Coordinator.shared.presentCustomShiftViewController(from: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Send as email", style: .default, handler:{ _ in
            self.handleSendAsEmailTapped()
        }))
        
        alert.addAction(UIAlertAction(title: "Open CSV", style: .default, handler:{ _ in
            self.handleOpenCSVTapped()
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.pruneNegativeWidthConstraints()
        alert.popoverPresentationController?.barButtonItem = dotsButton
        self.present(alert, animated: true)
    }
    
    private func sendEmailWithExcelSheetToCompany() {
        guard let companyEmail = SessionManager.shared.currentUser?.company?.email,
            let currentUserFirstName = SessionManager.shared.currentUser?.firstName,
            let currentUserLastName = SessionManager.shared.currentUser?.lastName else { return }
        
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
                mail.addAttachmentData(data, mimeType: "text/csv", fileName: "\(currentUserFirstName) \(currentUserLastName)")
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
            let message = "It looks like you didn‘t add your company. Would you like to add it?"
            self.showTwoOptionsAlert(title: "Alert", message: message, firstActionTitle: "Cancel", secondActionTitle: "Add")
        } else if let user = SessionManager.shared.currentUser {
            UnpauseActivityIndicatorView.shared.show(on: self.view)
            user.checkIfUserHasValidSubscription(onCompleted: { [weak self] hasValidSubscription in
                guard let `self` = self else { return }
                UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
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
                UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
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
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func configureDatesContainer() {
        containerView.addSubview(datesContainer)
        datesContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        datesContainer.layer.borderWidth = 1.2
        datesContainer.layer.borderColor = UIColor.unpauseLightGray.cgColor
        datesContainer.layer.cornerRadius = 10

        renderFromDateContainerViewAndItsSubviews()
    }

    func renderFromDateContainerViewAndItsSubviews() {
        datesContainer.addSubview(firstFilterDateLabel)
        firstFilterDateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
        firstFilterDateLabel.text = Formatter.shared.convertDateIntoString(from: Date())
        firstFilterDateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        firstFilterDateLabel.textColor = .unpauseDarkGray
        
        datesContainer.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.equalTo(firstFilterDateLabel.snp.right).offset(3)
            make.centerY.equalTo(firstFilterDateLabel.snp.centerY)
            make.height.equalTo(1)
            make.width.equalTo(5)
        }
        separator.backgroundColor = .unpauseDarkGray
        
        datesContainer.addSubview(secondFilterDateLabel)
        secondFilterDateLabel.snp.makeConstraints { make in
            make.left.equalTo(separator.snp.right).offset(3)
            make.centerY.equalTo(separator.snp.centerY)
        }
        secondFilterDateLabel.text = Formatter.shared.convertDateIntoString(from: Date())
        secondFilterDateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        secondFilterDateLabel.textColor = .unpauseDarkGray
        
        datesContainer.addSubview(calendarImageView)
        calendarImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(secondFilterDateLabel.snp.centerY)
            make.height.width.equalTo(21)
        }
        calendarImageView.image = UIImage(named: "calendar_30x30_grey")
    }
    
    func configureTableView() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
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
            UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
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
            UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
            
        case MFMailComposeResult.sent.rawValue:
            UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
            
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
