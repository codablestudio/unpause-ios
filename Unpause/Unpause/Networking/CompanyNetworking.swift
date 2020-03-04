//
//  CompanyNetworking.swift
//  Unpause
//
//  Created by Krešimir Baković on 04/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

class CompanyNetworking {
    
    private let dataBaseReference = Firestore.firestore()
    
    func fetchCompanyReference() -> Observable<CompanyReferenceFetchingResponse> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(CompanyReferenceFetchingResponse.error(UnpauseError.noUser))
        }
        
        return dataBaseReference
            .collection("users")
            .document("\(currentUserEmail)")
            .rx
            .getDocument()
            .map { documnetSnapshot -> CompanyReferenceFetchingResponse in
                do {
                    guard let companyReference = try UserFactory.createCompanyReference(from: documnetSnapshot) else {
                        return CompanyReferenceFetchingResponse.error(UnpauseError.emptyError)
                    }
                    return CompanyReferenceFetchingResponse.success(companyReference)
                } catch (let error) {
                    print("ERROR: \(error.localizedDescription)")
                    return CompanyReferenceFetchingResponse.error(error)
                }
        }
    }
    
    func fetchCompany() -> Observable<CompanyFetchingResponse> {
        return fetchCompanyReference()
            .flatMapLatest { companyReferenceFetchingResponse -> Observable<DocumentSnapshot> in
                switch companyReferenceFetchingResponse {
                case .success(let documentReference):
                    return documentReference.rx.getDocument()
                case .error(_):
                    return Observable.empty()
                }
        }
        .map { documentSnapshot -> CompanyFetchingResponse in
            do {
                guard let company = try UserFactory.createCompany(from: documentSnapshot) else {
                    return CompanyFetchingResponse.error(UnpauseError.emptyError)
                }
                return CompanyFetchingResponse.success(company)
            } catch (let error){
                return CompanyFetchingResponse.error(error)
            }
        }
    }
}
