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
import FirebaseFirestore

class CompanyNetworking: CompanyNetworkingProtocol {
    
    private let dataBaseReference = Firestore.firestore()
    
    private var privateCompanyReference: DocumentReference?

    func fetchCompanyReference() -> Observable<CompanyReferenceFetchingResponse> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(CompanyReferenceFetchingResponse.error(.noUser))
        }
        
        return dataBaseReference
            .collection("users")
            .document("\(currentUserEmail)")
            .rx
            .getDocument()
            .map ({ documnetSnapshot -> CompanyReferenceFetchingResponse in
                guard let companyReference = CompanyFactory.createCompanyReference(from: documnetSnapshot) else {
                    return CompanyReferenceFetchingResponse.error(.noCompany)
                }
                return CompanyReferenceFetchingResponse.success(companyReference)
            })
            .catchError { error -> Observable<CompanyReferenceFetchingResponse> in
                return Observable.just(CompanyReferenceFetchingResponse.error(.otherError(error)))
        }
    }
    
    func fetchCompany() -> Observable<CompanyFetchingResponse> {
        return fetchCompanyReference()
            .flatMapLatest ({ [weak self] companyReferenceFetchingResponse -> Observable<FirebaseDocumentResponseObject> in
                guard let `self` = self else { return Observable.empty() }
                switch companyReferenceFetchingResponse {
                case .success(let companyReference):
                    return self.getCompanyDataFromCompanyReference(companyReference: companyReference)
                case .error(let error):
                    return Observable.just(FirebaseDocumentResponseObject.error(error))
                }
            })
            .map ({ firebaseDocumentResponseObject -> CompanyFetchingResponse in
                switch firebaseDocumentResponseObject {
                case .success(let documentSnapshot):
                    do {
                        guard let company = try CompanyFactory.createCompanyFromDocument(document: documentSnapshot) else {
                            return CompanyFetchingResponse.error(.noCompany)
                        }
                        return CompanyFetchingResponse.success(company)
                    } catch (let error){
                        return CompanyFetchingResponse.error(.otherError(error))
                    }
                case .error(let error):
                    return CompanyFetchingResponse.error(error)
                }
            })
    }
    
    func addCompanyReferenceToUser(userEmail: String?, companyPassCode: String?) -> Observable<Response> {
        return fetchAllCompaniesValidationDataFromServer()
            .flatMapLatest ({ [weak self] companiesValidationDataResponse -> Observable<DocumentReferenceFetchingResponse> in
                guard let `self` = self else { return Observable.empty() }
                switch companiesValidationDataResponse {
                case .success(let allCompaniesValidationData):
                    guard let companyReference = self
                        .findCompanyWithNameAndPassCode(allCompaniesValidationData: allCompaniesValidationData,
                                                        companyPassCode: companyPassCode)
                        else {
                            return Observable.just(DocumentReferenceFetchingResponse.error(UnpauseError.emptyError))
                    }
                    return Observable.just(DocumentReferenceFetchingResponse.success(companyReference))
                case .error(let error):
                    return Observable.just(DocumentReferenceFetchingResponse.error(error))
                }
            })
            .flatMapLatest ({ [weak self] documentReferenceFetchingResponse -> Observable<DocumentReferenceFetchingResponse> in
                guard let `self` = self else {
                    return Observable.just(DocumentReferenceFetchingResponse.error(UnpauseError.emptyError))
                }
                switch documentReferenceFetchingResponse {
                case .success(let companyDocumentReference):
                    guard let companyReference = companyDocumentReference else {
                        return Observable.just(DocumentReferenceFetchingResponse.error(UnpauseError.emptyError))
                    }
                    self.privateCompanyReference = companyReference
                    return Observable.just(DocumentReferenceFetchingResponse.success(companyReference))
                case .error(let error):
                    print("ERROR: \(error.localizedDescription)")
                    return Observable.just(DocumentReferenceFetchingResponse.error(error))
                }
            })
            .flatMapLatest ({ documentReferenceFetchingResponse -> Observable<FirebaseDocumentResponseObject> in
                switch documentReferenceFetchingResponse {
                case .success(let documentReference):
                    guard let document = documentReference?.rx.getDocument() else {
                        return Observable.just(FirebaseDocumentResponseObject.error(UnpauseError.fetchingCompanyReferenceError))
                    }
                    return document
                        .flatMapLatest({ documentSnapshot -> Observable<FirebaseDocumentResponseObject> in
                            return Observable.just(FirebaseDocumentResponseObject.success(documentSnapshot))
                        })
                case .error(_):
                    return Observable.just(FirebaseDocumentResponseObject.error(UnpauseError.fetchingCompanyReferenceError))
                }
            })
            .flatMapLatest ({ [weak self] firebaseDocumentResponseObject -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                switch firebaseDocumentResponseObject {
                case .success(let documentSnapshot):
                    do {
                        guard let newCompany = try CompanyFactory.createCompanyFromDocument(document: documentSnapshot),
                            let companyReference = self.privateCompanyReference,
                            let userEmail = userEmail else {
                                return Observable.just(Response.error(UnpauseError.emptyError))
                        }
                        self.saveNewCompanyToCurrentUser(newCompany: newCompany)
                        return self.saveCompanyReferenceToUserOnServer(companyReference: companyReference, userEmail: userEmail)
                    } catch (let error) {
                        return Observable.just(Response.error(.otherError(error)))
                    }
                case .error(let error):
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
    
    func saveCompanyReferenceToUserOnServer(companyReference: DocumentReference, userEmail: String) -> Observable<Response> {
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
                return Observable.just(Response.error(.otherError(error)))
            })
    }
    
     internal func findCompanyWithNameAndPassCode(allCompaniesValidationData: [CompanyValidationData],
                                                companyPassCode: String?) -> DocumentReference? {
        var companyReference: String?
        for companyValidationData in allCompaniesValidationData {
            if companyValidationData.companyPassCode == companyPassCode {
                companyReference = companyValidationData.companyReference
            }
        }
        guard let companyDataBaseReference = companyReference else { return nil }
        return dataBaseReference.collection("companies").document("\(companyDataBaseReference)")
    }
    
    internal func saveNewCompanyToCurrentUser(newCompany: Company) {
        SessionManager.shared.currentUser?.company = newCompany
        SessionManager.shared.saveCurrentUserToUserDefaults()
    }
    
    internal func getCompanyDataFromCompanyReference(companyReference: DocumentReference) -> Observable<FirebaseDocumentResponseObject> {
        return companyReference.rx.getDocument()
            .flatMapLatest ({ documentSnapshot -> Observable<FirebaseDocumentResponseObject> in
                return Observable.just(FirebaseDocumentResponseObject.success(documentSnapshot))
            })
            .catchError ({ error -> Observable<FirebaseDocumentResponseObject> in
                return Observable.just(FirebaseDocumentResponseObject.error(.otherError(error)))
            })
    }
}
