//
//  CompanyNetworkingProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

protocol CompanyNetworkingProtocol {
    func fetchCompanyReference() -> Observable<CompanyReferenceFetchingResponse>
    func fetchCompany() -> Observable<CompanyFetchingResponse>
    func addCompanyReferenceToUser(userEmail: String?, companyName: String?, companyPassCode: String?) -> Observable<Response>
    func fetchAllCompaniesValidationDataFromServer() -> Observable<CompaniesValidationDataResponse>
    func saveCompanyReferenceToUserOnServer(companyReference: DocumentReference, userEmail: String) -> Observable<Response>
    func findCompanyWithNameAndPassCode(allCompaniesValidationData: [CompanyValidationData],
                                        companyName: String?,
                                        companyPassCode: String?) -> DocumentReference?
    func saveNewCompanyToCurrentUser(newCompany: Company)
    func getCompanyDataFromCompanyReference(companyReference: DocumentReference) -> Observable<FirebaseDocumentResponseObject>
}
