//
//  ForgotPasswordViewModelTest.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 06/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

@testable import Unpause
import XCTest
import RxSwift
import RxTest

class ForgotPasswordViewModelTest: XCTestCase {
    
    var sut: ForgotPasswordViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    private let loginNetworking = LoginNetworkingMock()
    
    override func setUp() {
        super.setUp()
        sut = ForgotPasswordViewModel(loginNetworking: loginNetworking)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        sut = nil
        scheduler = nil
    }
    
    func testRecoveryMailSendingResponse_shouldBeInValid() {
        let sutEvents: TestableObserver<Response> = scheduler.createObserver(Response.self)
        let expectedResult: [Recorded<Event<Response>>] = [Recorded.next(1, Response.error(UnpauseError.defaultError))]
        
        sut.recoveryMailSendingResponse
            .subscribe(sutEvents)
            .disposed(by: disposeBag)
        
        let correctEmailInputEvent = scheduler.createHotObservable([.next(0, "\(MockUser.existingUser.email ?? "")")])
        correctEmailInputEvent
            .bind(to: sut.textInEmailTextFieldChanges)
            .disposed(by: disposeBag)
        
        let sendRecoveryEmailButtonTappedEvent = scheduler.createHotObservable([.next(1, ())])
        sendRecoveryEmailButtonTappedEvent
            .bind(to: sut.sendRecoveryEmailButtonTapped)
            .disposed(by: disposeBag)
        
        scheduler.start()
        XCTAssertEqual(expectedResult, sutEvents.events)
    }
    
}
