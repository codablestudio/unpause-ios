//
//  ObservableType+Extension.swift

//
//  Created by Marko Aras on 18/12/2018.
//  Copyright © 2018 Codable Studio. All rights reserved.
//

//import RxSwift
//import Moya
//import SwiftyJSON
//
//extension ObservableType where E == Response {
//    /// Filter all status codes that are not notStatusCode
//    public func filter(notStatusCode: Int) -> Observable<E> {
//        return flatMap { response -> Observable<E> in
//            if response.statusCode == notStatusCode {
//                return Observable.error(MoyaError.statusCode(response))
//            } else {
//                return Observable.just(response)
//            }
//        }
//    }
//    
//    public func filterErrorFromSuccessCode() -> Observable<E> {
//        return flatMap { response -> Observable<E> in
//            let json = JSON(response.data)
//            if json["errorMesage"].string != nil ||
//                json["errorMessage"].string != nil ||
//                json["errorCode"].string != nil {
//                return Observable.error(MoyaError.statusCode(response))
//            }
//            return Observable.just(response)
//        }
//    }
//}
