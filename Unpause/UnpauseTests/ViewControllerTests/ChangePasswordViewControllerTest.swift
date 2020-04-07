//
//  ChangePasswordViewControllerTest.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 07/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

@testable import Unpause
import XCTest
import RxSwift
import RxCocoa
import RxTest

class ChangePasswordViewControllerTest: XCTestCase {
    
    var sut: ChangePasswordViewController!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var changePasswordNetworkingMock: ChangePasswordNetworkingProtocol!
    var changePasswordViewModelMock: ChangePasswordViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        let changePasswordNetworkingMock = ChangePasswordNetworkingMock()
        changePasswordViewModelMock = ChangePasswordViewModelMock(changePasswordNetworking: changePasswordNetworkingMock)
        sut = ChangePasswordViewController(changePasswordViewModel: changePasswordViewModelMock)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        changePasswordNetworkingMock = nil
        changePasswordViewModelMock = nil
        disposeBag = nil
        sut = nil
        scheduler = nil
    }
    
    func testChangePasswordLabelText_shouldBe_Change_Password() {
        _ = sut.view
        XCTAssertEqual(sut.changePasswordLabel.text, "Change password")
    }
}
