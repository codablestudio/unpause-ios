//
//  BossNetworking.swift
//  Unpause
//
//  Created by Krešimir Baković on 26/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RxSwift

class BossNetworking {
    
    private let dataBaseReference = Firestore.firestore()
    
    func addBossToCurrenUser(bossEmail: String, bossFirstName: String, bossLastName: String) -> Observable<Response> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(Response.error(UnpauseError.noUser))
        }
        
        return dataBaseReference
            .collection("users")
            .document("\(currentUserEmail)")
            .rx
            .updateData([
                "boss":
                    [
                        "email": "\(bossEmail)",
                        "firstName": "\(bossFirstName)",
                        "lastName": "\(bossLastName)"
                ]
            ])
            .flatMapLatest { [weak self] _ -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                let boss = User(firstName: bossFirstName, lastName: bossLastName, email: bossEmail)
                self.updateUsersBossDataWith(boss: boss)
                return Observable.just(Response.success)
        }
        .catchError { error -> Observable<Response> in
            return Observable.just(Response.error(error))
        }
    }
    
    func fetchBoss() -> Observable<BossFetchingResponse> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(BossFetchingResponse.error(UnpauseError.noUser))
        }
        
        return dataBaseReference
            .collection("users")
            .document("\(currentUserEmail)")
            .rx
            .getDocument()
            .map { documentSnapshot -> BossFetchingResponse in
                do {
                    let boss = try UserFactory.createUser(from: documentSnapshot)
                    print("BOSS:\(boss)")
                    return BossFetchingResponse.success(boss)
                } catch (let error) {
                    print("ERROR: \(error)")
                    return BossFetchingResponse.error(error)
                }
        }
    }
    
    private func updateUsersBossDataWith(boss: User) {
        SessionManager.shared.currentUser?.boss = boss
    }
}
