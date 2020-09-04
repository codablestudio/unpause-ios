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
    
    private let calendar = FSCalendar()
    
    private let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
    
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
        setUpObservables()
        addBarButtonItem()
        setUpCalendar()
        
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderCalendar()
    }
    
    private func setUpObservables() {
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    private func addBarButtonItem() {
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setUpCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.allowsMultipleSelection = true
    }
}

// MARK: - UI rendering
private extension CalendarViewController {
    func configureScrollViewAndContainerView() {
        view.backgroundColor = .gray
        
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
    }
}

// MARK: - FSCalendarDataSource
extension CalendarViewController: FSCalendarDataSource {
    
}

// MARK: - FSCalendarDelegate
extension CalendarViewController: FSCalendarDelegate {
    
}
