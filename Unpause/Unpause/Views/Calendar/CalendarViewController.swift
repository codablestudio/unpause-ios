//
//  CalendarViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 04/09/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import FSCalendar
import RxSwift

class CalendarViewController: UIViewController {
    
    private let viewModel: CalendarViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    let calendar = FSCalendar()
    
    private let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
    
    private var firstDate: Date?
    private var lastDate: Date?
    
    var datesRangeChanges = PublishSubject<[Date]>()
    
    private var datesRange: [Date]?
    
    init(viewModel: CalendarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpCalendar()
        addBarButtonItems()
        showTitleInNavigationBar()
        setUpObservables()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderCalendar()
    }
    
    private func setUpObservables() {
        doneButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func addBarButtonItems() {
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func showTitleInNavigationBar() {
        self.title = "Filter"
    }
    
    private func setUpCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.scrollDirection = .vertical
        calendar.allowsMultipleSelection = true
        calendar.appearance.selectionColor = .unpauseOrange
        calendar.appearance.borderSelectionColor = .unpauseOrange
        calendar.appearance.todayColor = .unpauseGray
        calendar.appearance.headerTitleColor = .unpauseBlack
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 16, weight: .semibold)
        calendar.appearance.titleDefaultColor = .unpauseBlack
        calendar.appearance.weekdayTextColor = .unpauseDarkGray
    }
    
    func datesRange(from: Date, to: Date) -> [Date] {
        if from > to { return [Date]() }
        var tempDate = from
        var array = [tempDate]

        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }
        return array
    }
    
    func getCalendar() -> FSCalendar {
        return calendar
    }
}

// MARK: - UI rendering
private extension CalendarViewController {
    func configureScrollViewAndContainerView() {
        view.backgroundColor = .unpauseWhite
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        scrollView.alwaysBounceVertical = true
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    func renderCalendar() {
        containerView.addSubview(calendar)
        calendar.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(UIScreen.getHeight() * 0.8)
        }
        calendar.backgroundColor = .unpauseWhite
    }
}

// MARK: - FSCalendarDelegate
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            datesRangeChanges.onNext([firstDate!])
            return
        }
        
        if firstDate != nil && lastDate == nil {
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                datesRangeChanges.onNext([firstDate!])
                return
            }

            let range = datesRange(from: firstDate!, to: date)

            lastDate = range.last

            for date in range {
                calendar.select(date)
            }

            datesRange = range
            datesRangeChanges.onNext(range)
            return
        }

        if firstDate != nil && lastDate != nil {
            for date in calendar.selectedDates {
                calendar.deselect(date)
            }

            lastDate = nil
            firstDate = nil

            datesRange = []
            datesRangeChanges.onNext([])
        }
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if firstDate != nil && lastDate != nil {
            for date in calendar.selectedDates {
                calendar.deselect(date)
            }

            lastDate = nil
            firstDate = nil

            datesRange = []
            datesRangeChanges.onNext([])
        }
    }
}
