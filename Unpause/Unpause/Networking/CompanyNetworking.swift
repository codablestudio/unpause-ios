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
                    guard let companyReference = try CompanyFactory.createCompanyReference(from: documnetSnapshot) else {
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
                guard let company = try CompanyFactory.createCompany(from: documentSnapshot) else {
                    return CompanyFetchingResponse.error(UnpauseError.emptyError)
                }
                return CompanyFetchingResponse.success(company)
            } catch (let error){
                return CompanyFetchingResponse.error(error)
            }
        }
    }
    
    func addCompanyReferenceToUser(userEmail: String?, companyName: String?, companyPassCode: String?) -> Observable<Response> {
        return fetchAllCompaniesValidationDataFromServer()
            .flatMapLatest ({ [weak self] companiesValidationDataResponse -> Observable<DocumentReferenceFetchingResponse> in
                guard let `self` = self else { return Observable.empty() }
                switch companiesValidationDataResponse {
                case .success(let allCompaniesValidationData):
                    guard let companyReference = self.findCompanyWithNameAndPassCode(allCompaniesValidationData: allCompaniesValidationData,
                                                                                     companyName: companyName,
                                                                                     companyPassCode: companyPassCode)
                        else {
                            return Observable.just(DocumentReferenceFetchingResponse.error(UnpauseError.emptyError))
                    }
                    return Observable.just(DocumentReferenceFetchingResponse.success(companyReference))
                case .error(let error):
                    return Observable.just(DocumentReferenceFetchingResponse.error(error))
                }
            })
            .flatMapLatest ({ [weak self] documentReferenceFetchingResponse -> Observable<Response> in
                guard let `self` = self,
                    let userEmail = userEmail else { return Observable.just(Response.error(UnpauseError.emptyError)) }
                switch documentReferenceFetchingResponse {
                case .success(let companyDocumentReference):
                    guard let companyReference = companyDocumentReference else {
                        return Observable.just(Response.error(UnpauseError.emptyError))
                    }
                    return self.saveCompanyReferenceToUser(companyReference: companyReference, userEmail: userEmail)
                case .error(let error):
                    print("ERROR: \(error.localizedDescription)")
                    return Observable.just(Response.error(error))
                }
            })
    }
    
    func fetchAllCompaniesValidationDataFromServer() -> Observable<CompaniesValidationDataResponse> {
        return dataBaseReference
            .collection("companies")
            .rx
            .getDocuments()
            .map ({ querySnapshot -> CompaniesValidationDataResponse in
                do {
                    guard let companiesValidationData = try CompanyFactory.createCompaniesValidationData(from: querySnapshot.documents) else {
                        return CompaniesValidationDataResponse.error(UnpauseError.emptyError)
                    }
                    return CompaniesValidationDataResponse.success(companiesValidationData)
                } catch (let error) {
                    print("ERROR: \(error.localizedDescription)")
                    return CompaniesValidationDataResponse.error(error)
                }
            })
    }
    
    func saveCompanyReferenceToUser(companyReference: DocumentReference, userEmail: String) -> Observable<Response> {
        return dataBaseReference
            .collection("users")
            .document("\(userEmail)")
            .rx
            .updateData([
                "companyReference": companyReference
            ])
            .flatMapLatest ({ _ -> Observable<Response> in
                return Observable.just(Response.success)
            })
            .catchError ({ error -> Observable<Response> in
                return Observable.just(Response.error(error))
            })
    }
    
    private func findCompanyWithNameAndPassCode(allCompaniesValidationData: [CompanyValidationData],
                                                companyName: String?,
                                                companyPassCode: String?) -> DocumentReference? {
        var companyReference: String?
        for companyValidationData in allCompaniesValidationData {
            if companyValidationData.companyName == companyName && companyValidationData.companyPassCode == companyPassCode {
                companyReference = companyValidationData.companyReference
            }
        }
        guard let companyDataBaseReference = companyReference else { return nil }
        return dataBaseReference.collection("companies").document("\(companyDataBaseReference)")
    }
}
