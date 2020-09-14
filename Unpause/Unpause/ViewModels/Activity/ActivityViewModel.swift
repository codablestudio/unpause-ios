//
//  ActivityViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 19/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import RxSwift

class ActivityViewModel: ActivityViewModelProtocol {
    
    private let shiftNetworking: ShiftNetworkingProtocol
    private let companyNetworking: CompanyNetworkingProtocol
    private let disposeBag = DisposeBag()
    
    var shiftsRequest: Observable<[ShiftsTableViewItem]>!
    var deleteRequest: Observable<ShiftDeletionResponse>!
    
    var refreshTrigger = PublishSubject<Void>()
    var firstFilterDateChanges = PublishSubject<Date>()
    var secondFilterDateChanges = PublishSubject<Date>()
    var activityStarted = PublishSubject<Void>()
    var shiftToDelete = PublishSubject<Shift>()
    
    private var firstFilterDate: Date?
    private var secondFilterDate: Date?
    
    static var forceRefresh = PublishSubject<(Void)>()
    
    init(shiftNetworking: ShiftNetworkingProtocol,
         companyNetworking: CompanyNetworkingProtocol) {
        self.shiftNetworking = shiftNetworking
        self.companyNetworking = companyNetworking
        
        setUpObservables()
    }
    
    private func setUpObservables() {
        firstFilterDateChanges
            .subscribe(onNext: { [weak self] date in
                guard let `self` = self else { return }
                let dateWithZeroTime = Formatter.shared.getDateWithStartingDayTime(fromDate: date)
                self.firstFilterDate = dateWithZeroTime
            }).disposed(by: disposeBag)
        
        secondFilterDateChanges
            .subscribe(onNext: { [weak self] date in
                guard let `self` = self else { return }
                let dateWithZeroTime = Formatter.shared.getDateWithEndingDayTime(fromDate: date)
                self.secondFilterDate = dateWithZeroTime
            }).disposed(by: disposeBag)
        
        shiftsRequest = Observable.merge(ActivityViewModel.forceRefresh, refreshTrigger)
            .startWith(())
            .flatMapLatest({ [weak self] _ -> Observable<ShiftsResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.shiftNetworking.fetchShifts()
            })
            .flatMapLatest({ [weak self] shiftsResponse -> Observable<ShiftsResponse> in
                guard let `self` = self,
                    let fromDate = self.firstFilterDate,
                    let toDate = self.secondFilterDate else {
                        return Observable.just(ShiftsResponse.error(UnpauseError.emptyError))
                }
                return self.shiftNetworking.filterShifts(fromDate: fromDate, toDate: toDate, allShifts: shiftsResponse)
            })
            .map({ shiftsResponse -> [ShiftsTableViewItem] in
                switch shiftsResponse {
                case .success(let shifts):
                    var response = [ShiftsTableViewItem]()
                    for shift in shifts {
                        response.append(.shift(shift))
                    }
                    
                    if shifts.isEmpty {
                        response.append(.empty)
                    }
                    
                    return response
                case .error(let error):
                    print("error \(error)")
                }
                return []
            })
        
        deleteRequest = shiftToDelete
            .flatMapLatest({ [weak self] shift -> Observable<ShiftDeletionResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.shiftNetworking.deleteShift(shiftToDelete: shift)
            })
    }
}

// MARK: Open CSV
extension ActivityViewModel {
    func makeNewCSVFileWithShiftsData(shiftsData: [ShiftsTableViewItem]) -> CSVMakingResponse {
        var csvString = "\("Arrival time"),\("Leaving time"),\("Description"),\("Hours")\n"
        var totalWorkingHours = 0.0
        
        for shiftData in shiftsData {
            guard let arrivalDateInDateFormat = Formatter.shared.convertTimeStampIntoDate(timeStamp: shiftData.shift?.arrivalTime),
                let leavingDateInDateFormat = Formatter.shared.convertTimeStampIntoDate(timeStamp: shiftData.shift?.exitTime),
                let description = shiftData.shift?.description else {
                    return CSVMakingResponse.error(.noShiftsCSVError)
            }
            
            let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: arrivalDateInDateFormat)
            let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: leavingDateInDateFormat)
            
            let arrivalDateAndTimeInStringFormat = Formatter.shared.convertDateIntoStringWithTime(from: arrivalDateInDateFormat)
            let leavingDateAndTimeInStringFormat = Formatter.shared.convertDateIntoStringWithTime(from: leavingDateInDateFormat)
            
            
            let workingHours = Formatter.shared.findTimeDifferenceInHours(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                          secondDate: leavingDateAndTimeWithZeroSeconds)
            
            totalWorkingHours += workingHours
            let workingHoursInStringFormat = String(workingHours)
            let descriptionTextWithoutNewLines = description.replacingOccurrences(of: "\n", with: " ",
                                                                                  options: .literal,
                                                                                  range: nil)
            
            let firstPartOfString = "\(arrivalDateAndTimeInStringFormat),"
            let secondPartOfString = "\(leavingDateAndTimeInStringFormat),"
            let thirdPartOfString = "\(descriptionTextWithoutNewLines),"
            let lastPartOfString = "\(workingHoursInStringFormat)\n"
            
            csvString = csvString.appending("\(firstPartOfString)\(secondPartOfString)\(thirdPartOfString)\(lastPartOfString)")
        }
        
        let totalWorkingHoursInStringFormat = String(round(totalWorkingHours*100)/100)
        
        csvString = csvString.appending("\n \("Total hours"), \(totalWorkingHoursInStringFormat)")
        
        let fileManager = FileManager.default
        do {
            guard let currentUserFirstName = SessionManager.shared.currentUser?.firstName,
                let currentUserLastName = SessionManager.shared.currentUser?.lastName else {
                    return CSVMakingResponse.error(.noUser)
            }
            
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("\(currentUserFirstName) \(currentUserLastName).csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return CSVMakingResponse.success(fileURL)
        } catch (let error) {
            return CSVMakingResponse.error(.otherError(error))
        }
    }
}

extension ActivityViewModel {
    func makeDataFrom(csvMakingResponse: CSVMakingResponse) -> DataMakingResponse {
        switch csvMakingResponse {
        case .success(let url):
            do {
                let data =  try Data(contentsOf: url)
                return DataMakingResponse.success(data)
            } catch {
                return DataMakingResponse.error(.otherError(error))
            }
        case .error(let error):
            return DataMakingResponse.error(error)
        }
    }
}
