//
//  Extension.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/15/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import Foundation

extension Sequence {
    
    func sumBy(selector: (Element) -> Int) -> Int {
        return self.reduce(into: 0) { (sum, element) in
            sum += selector(element)
        }
    }
    
}
