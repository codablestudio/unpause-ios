//
//  UserTypeViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 29/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift

class UserTypeViewController: UIViewController {
    
    private let userTypeViewModel: UserTypeViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let containerView = UIView()
    private let collectionView = UICollectionView()
    
    private let dataSource: [UserTypeCollectionViewItem] = [.privateUser, .businessUser]

    init(userTypeViewModel: UserTypeViewModelProtocol) {
        self.userTypeViewModel = userTypeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpObservables()
        setUpCollectionView()
    }
    
    private func render() {
        configureContainerView()
        configureCollectionView()
    }
    
    private func setUpObservables() {
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                switch self.dataSource[indexPath.row] {
                case .privateUser:
                    Coordinator.shared.navigateToMapViewController(from: self)
                case .businessUser:
                    Coordinator.shared.navigateToAddCompanyViewController(from: self)
                }
            }).disposed(by: disposeBag)
    }
    
    private func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.register(UserTypeCollectionViewCell.self, forCellWithReuseIdentifier: "UserTypeCollectionViewCell")
        collectionView.contentInsetAdjustmentBehavior = .never
    }

}

// MARK: - UI rendering
private extension UserTypeViewController {
    func configureContainerView() {
        view.backgroundColor = UIColor.unpauseWhite
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
    }
    
    func configureCollectionView() {
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension UserTypeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch dataSource[indexPath.row] {
        case .privateUser:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UserTypeCollectionViewCell.self),
                                                     for: indexPath) as! UserTypeCollectionViewCell
            cell.configure(name: "Private user", cellImageName: "privateUser_100x100_black")
            return cell
        case .businessUser:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UserTypeCollectionViewCell.self),
                                                     for: indexPath) as! UserTypeCollectionViewCell
            cell.configure(name: "Business user", cellImageName: "businessUser_100x100_black")
            return cell
        }
    }
    
    
}
