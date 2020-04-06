//
//  UnpauseTests.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 03/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//
@testable import Unpause
import XCTest
import Firebase
import RxSwift
import RxTest

class LoginViewModelTest: XCTestCase {
    
    var sut: LoginViewModel!
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!
    
    private let loginNetworking = LoginNetworkingMock()
    private let companyNetworking = CompanyNetworkingMock()
    private let registerNetworking = RegisterNetworkingMock()
    
    override func setUp() {
        super.setUp()
        sut = LoginViewModel(loginNetworking: loginNetworking,
                             companyNetworking: companyNetworking,
                             registerNetworking: registerNetworking)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        sut = nil
        scheduler = nil
    }
    
    func testLoginDocument_withInvalidUserInfo_shouldBeInvalid() {
        let sutEvents: TestableObserver<UnpauseResponse> = scheduler.createObserver(UnpauseResponse.self)
        let expectedResult: [Recorded<Event<UnpauseResponse>>] = [Recorded.next(3, UnpauseResponse.error(.wrongUserData))]
        
        sut.loginDocument
            .subscribe(sutEvents)
            .disposed(by: disposeBag)
        
        let correctEmailInputEvent = scheduler.createHotObservable([.next(1, "pero@pedala.hr")])
        correctEmailInputEvent
            .bind(to: sut.textInEmailTextFieldChanges)
            .disposed(by: disposeBag)
        
        let correctPwdInputEvent = scheduler.createHotObservable([.next(2, "aaaaa")])
        correctPwdInputEvent
            .bind(to: sut.textInPasswordTextFieldChanges)
            .disposed(by: disposeBag)
        
        let loginTapEvent = scheduler.createHotObservable([.next(3, ())])
        loginTapEvent
            .bind(to: sut.logInButtonTapped)
            .disposed(by: disposeBag)
        
        scheduler.start()
        XCTAssertEqual(expectedResult, sutEvents.events)
    }
    
    func testTextInPasswordTextFieldChanges() {
        let sutEvents: TestableObserver<String?> = scheduler.createObserver(String?.self)
        let expectedResult: [Recorded<Event<String?>>] = [Recorded.next(0, "TEst123")]
        
        sut.textInPasswordTextFieldChanges
            .subscribe(sutEvents)
            .disposed(by: disposeBag)
        
        let expectedPasswordInputEvent = scheduler.createHotObservable([.next(0, "TEst123")])
        expectedPasswordInputEvent
            .bind(to: sut.textInPasswordTextFieldChanges)
        .disposed(by: disposeBag)
        
        scheduler.start()
        XCTAssertEqual(expectedResult, sutEvents.events)
    }
    
    func testTextInEmailTextFieldChanges() {
        let sutEvents: TestableObserver<String?> = scheduler.createObserver(String?.self)
        let expectedResult: [Recorded<Event<String?>>] = [Recorded.next(0, "Email@email.com")]
        
        sut.textInEmailTextFieldChanges
            .subscribe(sutEvents)
            .disposed(by: disposeBag)
        
        let expectedPasswordInputEvent = scheduler.createHotObservable([.next(0, "Email@email.com")])
        expectedPasswordInputEvent
            .bind(to: sut.textInEmailTextFieldChanges)
            .disposed(by: disposeBag)
        
        scheduler.start()
        XCTAssertEqual(expectedResult, sutEvents.events)
    }
}
