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

class ActivityViewController: UIViewController {
    
    private let activityViewModel: ActivityViewModel
    private let disposeBag = DisposeBag()
    
    private let refresherControl = UIRefreshControl()
    
    private let containerView = UIView()
    
    private let datesAndSearchContainer = UIView()
    
    private let datesContainer = UIView()
    
    private let fromDateLabel = UILabel()
    private let fromDateTextField = UITextField()
    
    private let toDateLabel = UILabel()
    private let toDateTextField = UITextField()
    
    private let searchButton = OrangeButton(title: "Search")
    
    private let separator = UIView()
    
    private let tableView = UITableView()
    
    private let fromDatePicker = UIDatePicker()
    private let toDatePicker = UIDatePicker()
    
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
    }
    
    private func render() {
        configureContainerView()
        configureDatesAndSearchContainer()
        configureDatesContainer()
        renderFromDateLabelAndFromDateTextField()
        renderToDateLabelAndToDateTextField()
        renderSearchButton()
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
        
        Observable.merge(refresherControl.rx.controlEvent(.valueChanged).asObservable(),
                         searchButton.rx.tap.asObservable())
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
            guard let `self` = self else { return }
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
    }
    
    private func setFromPickerAndTextFieldInitialDate() {
        fromDatePicker.date = Formatter.shared.getDateOneMontBeforeTodaysDate()
        let lastMonthDate = Formatter.shared.getDateOneMontBeforeTodaysDate()
        fromDateTextField.text = Formatter.shared.convertDateIntoString(from: lastMonthDate)
    }
}


// MARK: - UI rendering

private extension ActivityViewController {
    func configureContainerView() {
        view.backgroundColor = UIColor.whiteUnpauseTextAndBackgroundColor
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.topMargin.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
    }
    
    func configureDatesAndSearchContainer() {
        containerView.addSubview(datesAndSearchContainer)
        
        datesAndSearchContainer.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        datesAndSearchContainer.addBottomBorder(.lightGray)
    }
    
    func configureDatesContainer() {
        datesAndSearchContainer.addSubview(datesContainer)
        
        datesContainer.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func renderFromDateLabelAndFromDateTextField() {
        datesContainer.addSubview(fromDateLabel)
        
        fromDateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(15)
        }
        fromDateLabel.text = "From:"
        fromDateLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        datesContainer.addSubview(fromDateTextField)
        
        fromDateTextField.snp.makeConstraints { make in
            make.topMargin.equalToSuperview().offset(32)
            make.left.equalTo(fromDateLabel.snp.right).offset(5)
            make.right.equalToSuperview()
        }
    }
    
    func renderToDateLabelAndToDateTextField() {
        datesContainer.addSubview(toDateLabel)
        
        toDateLabel.snp.makeConstraints { make in
            make.top.equalTo(fromDateLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
        }
        toDateLabel.text = "To:"
        toDateLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        datesContainer.addSubview(toDateTextField)
        
        toDateTextField.snp.makeConstraints { make in
            make.top.equalTo(fromDateTextField.snp.bottom).offset(17)
            make.left.equalTo(toDateLabel.snp.right).offset(5)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    func renderSearchButton() {
        datesAndSearchContainer.addSubview(searchButton)
        
        searchButton.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview().offset(38)
            make.left.equalTo(datesContainer.snp.right).offset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(48)
            //make.width.equalTo(100)
        }
    }
    
    func configureTableView() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        containerView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(datesAndSearchContainer.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
    }
}

//MARK: - Table View Delegate

extension ActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
