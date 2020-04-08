//
//  ChangePasswordViewModelTest.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 07/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

@testable import Unpause
import XCTest
import RxSwift
import RxTest

class ChangePasswordViewModelTest: XCTestCase {

    var sut: ChangePasswordViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    private let changePasswordNetworking = ChangePasswordNetworkingMock()
    
    override func setUp() {
        super.setUp()
        sut = ChangePasswordViewModel(changePasswordNetworking: changePasswordNetworking)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        sut = nil
        scheduler = nil
    }
    
    func testChangePasswordResponse_withValidData_ShouldBeValid() {
        let sutEvents: TestableObserver<Response> = scheduler.createObserver(Response.self)
        let expectedResult: [Recorded<Event<Response>>] = [Recorded.next(2, Response.success)]
        
        sut.changePasswordResponse
            .subscribe(sutEvents)
            .disposed(by: disposeBag)
        
        let correctTextForCurrentPaswwordTextField = scheduler.createHotObservable([.next(0, "123456")])
        correctTextForCurrentPaswwordTextField
            .bind(to: sut.textInCurrentPasswordTextFieldChanges)
            .disposed(by: disposeBag)
        
        let correctTextForNewPaswwordTextField = scheduler.createHotObservable([.next(1, "00000000")])
        correctTextForNewPaswwordTextField
            .bind(to: sut.textInNewPasswordTextFieldChanges)
            .disposed(by: disposeBag)
        
        let changePasswordButtonTapEvent = scheduler.createHotObservable([.next(2, ())])
        changePasswordButtonTapEvent
            .bind(to: sut.changePasswordButtonTapped)
            .disposed(by: disposeBag)
        
        scheduler.start()
        XCTAssertEqual(expectedResult, sutEvents.events)
    }
}
