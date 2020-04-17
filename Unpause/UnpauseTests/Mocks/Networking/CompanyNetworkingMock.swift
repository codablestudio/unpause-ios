//
//  CompanyNetworkingMock.swift
//  Unpause
//
//  Created by Krešimir Baković on 03/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

class CompanyNetworkingMock: CompanyNetworkingProtocol {
    
    func fetchCompanyReference() -> Observable<CompanyReferenceFetchingResponse> {
        return Observable.just(CompanyReferenceFetchingResponse.error(.fetchingCompanyReferenceError))
    }
    
    func fetchCompany() -> Observable<CompanyFetchingResponse> {
        return Observable.just(CompanyFetchingResponse.error(.companyFetchingError))
    }
    
    func addCompanyReferenceToUser(userEmail: String?, companyPassCode: String?) -> Observable<Response> {
        return Observable.just(Response.error(UnpauseError.companyMakingError))
    }
    
    func fetchAllCompaniesValidationDataFromServer() -> Observable<CompaniesValidationDataResponse> {
        return Observable.just(CompaniesValidationDataResponse.error(UnpauseError.companyFetchingError))
    }
    
    func saveCompanyReferenceToUserOnServer(companyReference: DocumentReference, userEmail: String) -> Observable<Response> {
        return Observable.just(Response.error(UnpauseError.serverSavingError))
    }
    
    func findCompanyWithNameAndPassCode(allCompaniesValidationData: [CompanyValidationData], companyPassCode: String?) -> DocumentReference? {
        return nil
    }
    
    func saveNewCompanyToCurrentUser(newCompany: Company) {
        
    }
    
    func getCompanyDataFromCompanyReference(companyReference: DocumentReference) -> Observable<FirebaseDocumentResponseObject> {
        return Observable.just(FirebaseDocumentResponseObject.error(.fetchingCompanyReferenceError))
    }
}
