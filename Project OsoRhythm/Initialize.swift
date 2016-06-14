//
//  Initialize.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/4/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation

//Initialize probably isn't the proper name for a script like this but basically this creates the functions and extensions and variables used throughout the app that didn't fall under a category.

internal func random(int: Int) -> Int {
    return Int(arc4random_uniform(UInt32(int)))
}

internal extension Array { // Will crash the app when given an empty array. This occasionally happens when called in Generation.swift. 
    func randomItem() -> Element {
        print("\(self)[random(\(self.count))]")
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
