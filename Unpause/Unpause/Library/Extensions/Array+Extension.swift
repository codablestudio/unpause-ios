//
//  Array+Extension.swift

//
//  Created by Marko Aras on 11/09/2018.
//  Copyright © 2018 Codable Studio. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    /// Remove duplicates from the array, preserving the items order
    func filterDuplicates() -> [Element] {
        var set = Set<Element>()
        var filteredArray = [Element]()
        for item in self {
            if set.insert(item).inserted {
                filteredArray.append(item)
            }
        }
        return filteredArray
    }
}
