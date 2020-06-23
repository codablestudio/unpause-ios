//
//  HomeViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 18/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyStoreKit
import Charts

class HomeViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let homeViewModel: HomeViewModelProtocol
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let userImageView = UIImageView()
    private let usernameLabel = UILabel()
    
    private let usernameSeparator = UIView()
    
    private let companyImageView = UIImageView()
    private let companyNameLabel = UILabel()
    
    private let companySeparator = UIView()
    
    let checkInButton = UIButton()
    
    private let lastCheckInTimeLabel = UILabel()
    private let workingHoursLabel = UILabel()
    
    private let chartContainerView = UIView()
    private let barChartView = BarChartView()
    
    var userChecksIn = PublishSubject<Bool>()
    
    init(homeViewModel: HomeViewModelProtocol) {
        self.homeViewModel = homeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpObservables()
        showTitleInNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayFreshUserData()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderUserImageViewAndUsernameLabel()
        renderUsernameSeparator()
        renderCompanyImageViewAndCompanyNameLabel()
        renderCompanySeparator()
        renderCheckInButton()
        renderLastCheckInTimeLabel()
        renderWorkingHoursLabel()
        renderChartContainerView()
    }
    
    func setUpObservables() {
        userChecksIn
            .do(onNext: { [weak self] (userChecksIn) in
                guard let `self` = self else { return }
                if !userChecksIn {
                    Coordinator.shared.presentShiftViewController(from: self)
                }
            })
            .bind(to: homeViewModel.userChecksIn)
            .disposed(by: disposeBag)
        
        homeViewModel.fetchingLastShift
            .bind(to: checkInButton.rx.animating)
            .disposed(by: disposeBag)
        
        checkInButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                vibratePhoneOnTouch()
                if self.checkInButton.title(for: .normal) == "Check in" {
                    self.checkInButton.setTitle("Check out", for: .normal)
                    self.userChecksIn.onNext(true)
                } else {
                    self.userChecksIn.onNext(false)
                }
            }).disposed(by: disposeBag)
        
        NotificationManager.shared.userChecksIn
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.checkInButton.sendActions(for: .touchUpInside)
            }).disposed(by: disposeBag)
        
        homeViewModel.checkInResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    self.displayFreshLastCheckInTime()
                    self.displayFreshWorkingHoursData()
                    NotificationManager.shared.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["notifyOnEntry"])
                    NotificationManager.shared.scheduleExitNotification()
                    NotificationManager.shared.scheduleTwelveHourDelayNotification()
                case .error(let error):
                    self.showOneOptionAlert(title: "Error", message: "\(error.errorMessage)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        homeViewModel.usersLastCheckInTimeRequest
            .subscribe(onNext: { [weak self] lastCheckInResponse in
                guard let `self` = self else { return }
                switch lastCheckInResponse {
                case .success(let lastCheckInDate):
                    SessionManager.shared.currentUser?.lastCheckInDateAndTime = lastCheckInDate
                    self.displayFreshLastCheckInTime()
                    self.displayFreshWorkingHoursData()
                    if lastCheckInDate != nil {
                        NotificationManager.shared.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["notifyOnEntry"])
                        NotificationManager.shared.scheduleExitNotification()
                        self.checkInButton.setTitle("Check out", for: .normal)
                    } else {
                        NotificationManager.shared.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["notifyOnExit"])
                        NotificationManager.shared.scheduleEntranceNotification()
                        self.checkInButton.setTitle("Check in", for: .normal)
                    }
                case .error(let error):
                    print("\(error)")
                }
            }).disposed(by: disposeBag)
        
        homeViewModel.lastWeekWorkingTimeFetchingResponse
            .subscribe(onNext: { [weak self] shiftsResponse in
                guard let `self` = self else { return }
                switch shiftsResponse {
                case .succes(let workingTimesFromThisWeek):
                    SessionManager.shared.currentUser?.workingTimeFromThisWeek = workingTimesFromThisWeek
                    self.setChart(workingTime: workingTimesFromThisWeek)
                case .error(let error):
                    self.showOneOptionAlert(title: "Error", message: "\(error.errorMessage)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.displayFreshWorkingHoursData()
            }).disposed(by: disposeBag)
    }
    
    private func showTitleInNavigationBar() {
        self.title = "Home"
    }
    
    private func displayFreshUserData() {
        displayFreshUsernameData()
        displayFreshCompanyData()
        displayFreshChartData()
    }
    
    private func displayFreshUsernameData() {
        if let firstName = SessionManager.shared.currentUser?.firstName,
            let lastName = SessionManager.shared.currentUser?.lastName {
            usernameLabel.text = "\(firstName) \(lastName)"
        } else {
            usernameLabel.text = "No user info"
        }
    }
    
    private func displayFreshCompanyData() {
        companyNameLabel.text = SessionManager.shared.currentUser?.company?.name ?? "No company"
    }
    
    private func displayFreshChartData() {
        guard let workingTimesFromThisWeek = SessionManager.shared.currentUser?.workingTimeFromThisWeek else {
            return
        }
        setChart(workingTime: workingTimesFromThisWeek)
    }
    
    private func displayFreshLastCheckInTime() {
        guard let lastCheckInTime = SessionManager.shared.currentUser?.lastCheckInDateAndTime else {
            fadeOut(viewToAnimate: lastCheckInTimeLabel, withDuration: 0.4)
            return
        }
        fadeIn(viewToAnimate: lastCheckInTimeLabel, withDuration: 0.4)
        let lastCheckInTimeInStringFormat = Formatter.shared.convertDateIntoStringWithTime(from: lastCheckInTime)
        lastCheckInTimeLabel.text = "Last check in time: \(lastCheckInTimeInStringFormat)"
    }
    
    private func displayFreshWorkingHoursData() {
        guard let lastCheckInTime = SessionManager.shared.currentUser?.lastCheckInDateAndTime else {
            fadeOut(viewToAnimate: workingHoursLabel, withDuration: 0.4)
            return
        }
        fadeIn(viewToAnimate: workingHoursLabel, withDuration: 0.4)
        let timeNowWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: Date())
        let lastCheckInTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: lastCheckInTime)
        let workingTime = Formatter.shared.findTimeDifference(firstDate: lastCheckInTimeWithZeroSeconds,
                                                              secondDate: timeNowWithZeroSeconds)
        workingHoursLabel.text = "Working time: \(workingTime.0) h \(workingTime.1) min"
        makeWorkingHoursAndMinutesPartOfStringOrangeAndBold(workingTime: workingTime)
    }
    
    private func makeWorkingHoursAndMinutesPartOfStringOrangeAndBold(workingTime: (String, String)) {
        let orangeString = "\(workingTime.0) h \(workingTime.1) min"
        let range = ((workingHoursLabel.text)! as NSString).range(of: orangeString)
        
        let attributedText = NSMutableAttributedString.init(string: (workingHoursLabel.text)!)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.unpauseOrange, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .bold)], range: range)
        workingHoursLabel.attributedText = attributedText
    }
}

// MARK: - UI rendering
private extension HomeViewController {
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
            make.width.equalToSuperview()
        }
    }
    
    func renderUserImageViewAndUsernameLabel() {
        containerView.addSubview(userImageView)
        userImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(30)
            make.height.width.equalTo(27)
        }
        userImageView.image = UIImage(named: "user_30x30_black")
        
        containerView.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.bottom.equalTo(userImageView.snp.bottom).offset(1)
        }
        displayFreshUsernameData()
        usernameLabel.textColor = .unpauseBlack
        usernameLabel.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    func renderUsernameSeparator() {
        containerView.addSubview(usernameSeparator)
        usernameSeparator.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(65)
            make.right.equalToSuperview().inset(25)
            make.height.equalTo(1)
        }
        usernameSeparator.backgroundColor = .unpauseVeryLightGray
    }
    
    func renderCompanyImageViewAndCompanyNameLabel() {
        containerView.addSubview(companyImageView)
        companyImageView.snp.makeConstraints { make in
            make.top.equalTo(usernameSeparator.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(30)
            make.height.width.equalTo(27)
        }
        companyImageView.image = UIImage(named: "company_30x30_black")
        
        containerView.addSubview(companyNameLabel)
        companyNameLabel.snp.makeConstraints { make in
            make.left.equalTo(companyImageView.snp.right).offset(10)
            make.bottom.equalTo(companyImageView.snp.bottom).offset(-1)
        }
        displayFreshCompanyData()
        companyNameLabel.textColor = .unpauseBlack
        companyNameLabel.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    func renderCompanySeparator() {
        containerView.addSubview(companySeparator)
        companySeparator.snp.makeConstraints { make in
            make.top.equalTo(companyImageView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(65)
            make.right.equalToSuperview().inset(25)
            make.height.equalTo(1)
        }
        companySeparator.backgroundColor = .unpauseVeryLightGray
    }
    
    func renderCheckInButton() {
        containerView.addSubview(checkInButton)
        checkInButton.snp.makeConstraints { (make) in
            make.top.equalTo(companySeparator.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(140)
            make.width.equalTo(140)
        }
        checkInButton.backgroundColor = UIColor.unpauseOrange
        checkInButton.layer.cornerRadius = 70
        checkInButton.titleLabel?.font = .systemFont(ofSize: 25)
        checkInButton.setTitleColor(.white, for: UIControl.State())
        checkInButton.dropShadow(color: .unpauseLightGray, opacity: 0.5, offSet: .zero, radius: 5)
    }
    
    func renderLastCheckInTimeLabel() {
        containerView.addSubview(lastCheckInTimeLabel)
        lastCheckInTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(checkInButton.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        lastCheckInTimeLabel.font = .systemFont(ofSize: 13, weight: .light)
        displayFreshLastCheckInTime()
    }
    
    func renderWorkingHoursLabel() {
        containerView.addSubview(workingHoursLabel)
        workingHoursLabel.snp.makeConstraints { make in
            make.top.equalTo(lastCheckInTimeLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        workingHoursLabel.font = .systemFont(ofSize: 13, weight: .light)
        displayFreshWorkingHoursData()
    }
    
    func renderChartContainerView() {
        containerView.addSubview(barChartView)
        barChartView.snp.makeConstraints { make in
            make.top.equalTo(workingHoursLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(220)
            make.bottom.equalToSuperview()
        }
        barChartView.noDataText = "Loading chart data..."
    }
    
    private func setChart(workingTime: [Double]) {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var dataEntries: [BarChartDataEntry] = []
        for i in 0 ..< days.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: workingTime[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Working hours")
        chartDataSet.valueFont = .systemFont(ofSize: 10)
        chartDataSet.setColor(UIColor.unpauseOrange, alpha: 1)
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false
        barChartView.isUserInteractionEnabled = false
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        barChartView.extraBottomOffset = 7
        barChartView.animate(yAxisDuration: 0.6, easingOption: .linear)
    }
}

// MARK: - Animations
private extension HomeViewController {
    func fadeIn(viewToAnimate: UIView, withDuration duration: Double) {
        UIView.animate(withDuration: duration, animations: {
            viewToAnimate.alpha = 1.0
        })
    }
    
    func fadeOut(viewToAnimate: UIView, withDuration duration: Double) {
        UIView.animate(withDuration: duration, animations: {
            viewToAnimate.alpha = 0.0
        })
    }
}

// MARK: - Haptic feedback
func vibratePhoneOnTouch() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}
