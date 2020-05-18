//
//  InAppPurchaseNetworking.swift
//  Unpause
//
//  Created by Krešimir Baković on 18/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import RxSwift
import RxFirebase

class InAppPurchaseNetworking: InAppPurchaseNetworkingProtocol {
    
    private let dataBaseReference = Firestore.firestore()
    
    func saveUserOneMonthSubscriptionDateInDatabase() -> Observable<Response> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(Response.error(.noUser))
        }
        let dateOneMonthAfterTodaysDate = Formatter.shared.getDateOneMontAfterTodaysDate()
        guard let dateOneMonthAfterTodaysDateInTimeStampFormat = Formatter.shared.convertDateIntoTimeStamp(date: dateOneMonthAfterTodaysDate) else {
            return Observable.just(Response.error(.dateConversionError))
        }
        
        return dataBaseReference
            .collection("users")
            .document("\(currentUserEmail)")
            .rx
            .setData(["oneMonthSubscription": dateOneMonthAfterTodaysDateInTimeStampFormat], merge: true)
            .flatMapLatest ({ _ -> Observable<Response> in
                return Observable.just(Response.success)
            }).catchError ({ error -> Observable<Response> in
                return Observable.just(Response.error(.otherError(error)))
            })
    }
    
    func saveUserOneYearSubscriptionDateInDatabase() -> Observable<Response> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(Response.error(.noUser))
        }
        let dateOneYearAfterTodaysDate = Formatter.shared.getDateOneYearAfterTodaysDate()
        guard let dateOneYearAfterTodaysDateInTimeStampFormat = Formatter.shared.convertDateIntoTimeStamp(date: dateOneYearAfterTodaysDate) else {
            return Observable.just(Response.error(.dateConversionError))
        }
        
        return dataBaseReference
            .collection("users")
            .document("\(currentUserEmail)")
            .rx
            .setData(["oneYearSubscription": dateOneYearAfterTodaysDateInTimeStampFormat], merge: true)
            .flatMapLatest ({ _ -> Observable<Response> in
                return Observable.just(Response.success)
            }).catchError ({ error -> Observable<Response> in
                return Observable.just(Response.error(.otherError(error)))
            })
    }
}
