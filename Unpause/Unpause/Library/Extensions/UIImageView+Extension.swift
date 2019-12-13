//
//  UIImageView+Extension.swift

//
//  Created by Marko Aras on 18/10/2018.
//  Copyright © 2018 Codable Studio. All rights reserved.
//

//import Foundation
//import Kingfisher
//import UIKit
//
//class KingfisherPlaceholder: UIView {
////    static let placeholderImage = UIImage.create("Splash")
//    let placeholderImageView = UIImageView()//(image: KingfisherPlaceholder.placeholderImage)
//    
//    init() {
//        super.init(frame: .zero)
////        self.insertSubview(placeholderImageView, at: 0)
////        placeholderImageView.edgesEqualToSuperview()
////        placeholderImageView.contentMode = .scaleAspectFit
//        self.renderLoader()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//extension KingfisherPlaceholder: Placeholder { /* Just leave it empty */}
//
//extension UIImageView {
//    
//    func downloadImage(_ URL: Foundation.URL, layoutOnFinish: UIView? = nil) {
//        let placeholderImage = KingfisherPlaceholder()
//        
//        self.kf.setImage(with: URL, placeholder: placeholderImage, options: []) { [weak layoutOnFinish] _ in
//            layoutOnFinish?.setNeedsLayout()
//            placeholderImage.removeLoader()
////            log.debug("URL \(URL)")
////            switch result {
////            case .success(let res):
////                log.debug("RES \(res.cacheType)")
////            case .failure(let err):
////                log.error("err \(err)")
////            }
//        }
//    }
//}
