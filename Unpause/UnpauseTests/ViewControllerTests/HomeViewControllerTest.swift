//
//  HomeViewControllerTest.swift
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

class HomeViewControllerTest: XCTestCase {
    
    var sut: HomeViewController!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var homeViewModel: HomeViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        homeViewModel = HomeViewModelMock()
        sut = HomeViewController(homeViewModel: homeViewModel)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        homeViewModel = nil
        disposeBag = nil
        sut = nil
        scheduler = nil
    }
    
    func testSignedInLabelText_shouldBe_Signed_in_as() {
        sut.viewDidLoad()
        XCTAssertEqual(sut.signedInLabel.text, "Signed in as:")
    }
    
    func testCheckInButtonText_withCheckedOutUserAfterThreeTaps_shouldBeCheckOut() {
        sut.viewDidLoad()
        XCTAssertEqual(sut.checkInButton.currentTitle, "Check in")
        
        
        sut.checkInButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(sut.checkInButton.currentTitle, "Check out")
        
        sut.checkInButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(sut.checkInButton.currentTitle, "Check out")
    }
}
