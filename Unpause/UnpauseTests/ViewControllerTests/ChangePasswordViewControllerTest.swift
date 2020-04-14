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
    var disposeBag: DisposeBag!
    
    var changePasswordNetworkingMock: ChangePasswordNetworkingProtocol!
    var changePasswordViewModelMock: ChangePasswordViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        let changePasswordNetworkingMock = ChangePasswordNetworkingMock()
        changePasswordViewModelMock = ChangePasswordViewModelMock(changePasswordNetworking: changePasswordNetworkingMock)
        sut = ChangePasswordViewController(changePasswordViewModel: changePasswordViewModelMock)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        changePasswordNetworkingMock = nil
        changePasswordViewModelMock = nil
        disposeBag = nil
        sut = nil
    }
    
    func testChangePasswordLabelText_OnViewDidLoad_shouldBeChangePassword() {
        sut.viewDidLoad()
        XCTAssertEqual(sut.changePasswordLabel.text, "Change password")
    }
    
    func testNewPasswordTextField_onViewDidLoad_shouldBeFalse() {
        sut.viewDidLoad()
        XCTAssertEqual(sut.newPasswordTextField.isFirstResponder, false)
    }
}
