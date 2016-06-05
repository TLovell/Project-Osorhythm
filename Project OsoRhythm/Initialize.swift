//
//  Initialize.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/4/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation

internal func random(int: Int) -> Int {
    return Int(arc4random_uniform(UInt32(int)))
}

internal extension Array {
    func randomItem() -> Element {
        return self[random(self.count)]
    }
}

internal extension Array where Element : Equatable {
    func intersection(array: Array) -> Array {
        var intersect : Array = []
        
        for item1 in array {
            for item2 in self {
                if item1 == item2 {
                    intersect.append(item1)
                }
            }
        }
        
        return intersect
    }
}

internal func roundDown(double: Double) -> Double {
    if double >= 0.0 && double < 0.5 {
        return 0.0
    } else {
        return round(double - 0.5)
    }
}

internal var intensity = 0.6
