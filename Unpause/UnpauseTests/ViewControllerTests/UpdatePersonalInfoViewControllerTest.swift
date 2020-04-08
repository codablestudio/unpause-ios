//
//  UpdatePersonalInfoViewControllerTest.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 08/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

@testable import Unpause
import XCTest
import RxSwift
import RxCocoa
import RxTest

class UpdatePersonalInfoViewControllerTest: XCTestCase {
    
    var sut: UpdatePersonalInfoViewController!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var updatePersonalInfoViewModel: UpdatePersonalInfoViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        updatePersonalInfoViewModel = UpdatePersonalInfoViewModelMock()
        sut = UpdatePersonalInfoViewController(updatePersonalInfoViewModel: updatePersonalInfoViewModel)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        updatePersonalInfoViewModel = nil
        disposeBag = nil
        sut = nil
        scheduler = nil
    }
    
    func testNewFirstNameTextFieldText_withNewTextAdded_choludBeEasy() {
        sut.viewDidLoad()
        XCTAssertEqual(sut.newFirstNameTextField.placeholder, "Enter new first name")
        sut.newFirstNameTextField.text = "Easy"
        XCTAssertEqual(sut.newFirstNameTextField.text, "Easy")
    }
}
