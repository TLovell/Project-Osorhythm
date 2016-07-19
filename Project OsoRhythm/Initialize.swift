//
//  Initialize.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/4/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation

import UIKit

//Initialize probably isn't the proper name for a script like this but basically this creates the functions and extensions and variables used throughout the app that didn't fall under a category.

internal func random(int: Int) -> Int {
    return Int(arc4random_uniform(UInt32(int)))
}

internal extension Array { // Will crash the app when given an empty array. This occasionally happens when called in Generation.swift. 
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

internal var intensity = 0.1

internal enum AppState {
    case ExerciseRunning
    case CountOff
    case Results
}

internal var currentAppState = AppState.CountOff

internal let accentColor = UIColor(red: 0.0, green: (122 / 255), blue: 1.0, alpha: 1.0)

extension UIImage {
    enum AssetIdentifier: String {
        case Beam = "Beam.png"
        case Bracket = "Bracket.png"
        case Dot = "Dot.png"
        case Flag = "Flag.png"
        case DoubleBarLine = "Double Bar Line.png"
        case EighthRest = "Eighth Rest.png"
        case EndBarLine = "End Bar Line.png"
        case HalfNote = "Half Note.png"
        case HalfRest = "Half Rest.png"
        case MiddleBarLine = "Middle Bar Line.png"
        case NoteHead = "Note Head.png"
        case QuarterNote = "Quarter Note.png"
        case QuarterRest = "Quarter Rest.png"
        case SignatureBar = "Signature Bar.png"
        case SixteenthRest = "Sixteenth Rest.png"
        case StartBarLine = "Start Bar Line.png"
        case Tie = "Tie.png"
        case WholeNote = "Whole Note.png"
        case WholeRest = "Whole Rest.png"
        case Star = "Star.png"
        case StarFilled = "Star Filled.png"
    }
    
    convenience init!(assetIndentifier: AssetIdentifier) {
        self.init(named: assetIndentifier.rawValue)
    }
}












