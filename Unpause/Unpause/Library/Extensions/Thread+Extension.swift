//
//  Thread+Extension.swift

//
//  Created by Marko Aras on 21/08/2019.
//  Copyright © 2019 Codable Studio. All rights reserved.
//

import Foundation

extension Thread {
    class func printCurrent() {
        print("\r⚡️: \(Thread.current) " + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
    }
}
