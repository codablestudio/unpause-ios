//
//  HomeViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 18/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol HomeViewModelProtocol {
    var usersLastCheckInTimeRequest: Observable<LastCheckInResponse>! { get }
    var checkInResponse: Observable<Response>! { get }
    var fetchingLastShift: Observable<Bool>! { get }
    var lastWeekWorkingTimeFetchingResponse: Observable<WorkingTimeFetchingRespponse>! { get }
    
    var userChecksIn: PublishSubject<Bool> { get }
}

class HomeViewModel: HomeViewModelProtocol {

    private let disposeBag = DisposeBag()
    private let homeNetworking: HomeNetworkingProtocol
    private let shiftNetworking: ShiftNetworkingProtocol
    
    var usersLastCheckInTimeRequest: Observable<LastCheckInResponse>!
    var checkInResponse: Observable<Response>!
    var fetchingLastShift: Observable<Bool>! {
        return _isFetchingLastShift.asObservable()
    }
    var lastWeekWorkingTimeFetchingResponse: Observable<WorkingTimeFetchingRespponse>!
    
    private let _isFetchingLastShift = ActivityIndicator()
    
    static let forceRefresh = PublishSubject<Void>()
    var userChecksIn = PublishSubject<Bool>()
    
    init(homeNetworking: HomeNetworkingProtocol,
         shiftNetworking: ShiftNetworkingProtocol) {
        self.homeNetworking = homeNetworking
        self.shiftNetworking = shiftNetworking
        
        setUpObservables()
    }
    
    private func setUpObservables() {
        usersLastCheckInTimeRequest = HomeViewModel.forceRefresh
            .startWith(())
            .flatMapLatest({ [weak self] _ -> Observable<LastCheckInResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.homeNetworking.getUsersLastCheckInTime()
                    .trackActivity(self._isFetchingLastShift)
            })
        
        checkInResponse = userChecksIn
            .flatMapLatest({ [weak self] userChecksIn -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                let timeAtThisMoment = Date()
                if userChecksIn {
                    SessionManager.shared.currentUser?.lastCheckInDateAndTime = timeAtThisMoment
                    let newShift = Shift()
                    newShift.arrivalTime = Formatter.shared.convertDateIntoTimeStamp(date: timeAtThisMoment)
                    return self.shiftNetworking.saveNewShift(newShift: newShift)
                } else {
                    SessionManager.shared.currentUser?.lastCheckOutDateAndTime = timeAtThisMoment
                    return Observable.empty()
                }
            })
        
//        lastWeekWorkingTimeFetchingResponse = Observable.combineLatest(HomeViewModel.forceRefresh, ActivityViewModel.forceRefresh)
//            .startWith(((), ()))
        lastWeekWorkingTimeFetchingResponse = Observable.merge([HomeViewModel.forceRefresh, ActivityViewModel.forceRefresh])
        .startWith(())
            .flatMapLatest({ [weak self] _ -> Observable<ShiftsResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.shiftNetworking.fetchShifts()
            })
            .map({ [weak self] shiftsResponse ->  WorkingTimeFetchingRespponse in
                guard let `self` = self else { return WorkingTimeFetchingRespponse.error(.emptyError) }
                switch shiftsResponse {
                case .success(let allShifs):
                    let workingTimesFromThisWeek = self.getArrayOfCurrentWeekWorkingTimes(allShifts: allShifs)
                    return WorkingTimeFetchingRespponse.succes(workingTimesFromThisWeek)
                case .error(let error):
                    return WorkingTimeFetchingRespponse.error(error as! UnpauseError)
                }
            })
    }
    
    private func getArrayOfCurrentWeekWorkingTimes(allShifts: [Shift]) -> [Double]{
        var workingTimesFromThisWeek = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        let shiftsFromThisWeek = getShiftsFromCurrentWeek(allShifts: allShifts)
        for shift in shiftsFromThisWeek {
            guard let arrivalTimeInDateFormat = Formatter.shared.convertTimeStampIntoDate(timeStamp: shift.arrivalTime),
                let leavingTimeInDateFormat = Formatter.shared.convertTimeStampIntoDate(timeStamp: shift.exitTime) else {
                    return []
            }
            let shiftWeekDay = Formatter.shared.getDayOfWeek(from: arrivalTimeInDateFormat)
            let shiftWorkingTime = Formatter.shared.findTimeDifferenceInHours(firstDate: arrivalTimeInDateFormat, secondDate: leavingTimeInDateFormat)
            switch shiftWeekDay {
            case .Monday:
                workingTimesFromThisWeek[0] += shiftWorkingTime
            case .Tuesday:
                workingTimesFromThisWeek[1] += shiftWorkingTime
            case .Wednesday:
                workingTimesFromThisWeek[2] += shiftWorkingTime
            case .Thursday:
                workingTimesFromThisWeek[3] += shiftWorkingTime
            case .Friday:
                workingTimesFromThisWeek[4] += shiftWorkingTime
            case .Saturday:
                workingTimesFromThisWeek[5] += shiftWorkingTime
            case .Sunday:
                workingTimesFromThisWeek[6] += shiftWorkingTime
            case .none:
                log.debug("ERROR")
            }
        }
        return workingTimesFromThisWeek
    }
    
    private func getShiftsFromCurrentWeek(allShifts: [Shift]) -> [Shift] {
        var shiftsFromCurrentWeek = [Shift]()
        let shiftsWithArrivalAndExitTime = removeShiftsWithoutArrivalAndExitTime(allShifts: allShifts)
        for shift in shiftsWithArrivalAndExitTime {
            guard let shiftArrivalTimeInDateFormat = Formatter.shared.convertTimeStampIntoDate(timeStamp: shift.arrivalTime) else { return [] }
            if Formatter.shared.dateIsDayInCurrentWeek(date: shiftArrivalTimeInDateFormat) {
                shiftsFromCurrentWeek.append(shift)
            }
        }
        return shiftsFromCurrentWeek
    }
    
    private func removeShiftsWithoutArrivalAndExitTime(allShifts: [Shift]) -> [Shift] {
        var newShiftArray = [Shift]()
        for shift in allShifts {
            if shift.arrivalTime != nil && shift.exitTime != nil {
                newShiftArray.append(shift)
            }
        }
        return newShiftArray
    }
}
