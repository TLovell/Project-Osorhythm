//
//  Evaluation.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/22/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation

var currentAnswerKey : [Double] = []

internal func answerKey(exercise: [[(String, Int)]]) -> (answerKey: [Double], beatsPerSecond: Double, initialTempo: Double) {
    let tempo = 80.0 + (30 * intensity)
    let beatsPerSecond = 60 / tempo
    
    var beatDivisor = 3
    
    for measure in exercise {
        for beat in measure {
            if beat.1 == 2 {
                beatDivisor = 2
            }
        }
    }
    
    let unitInterval = beatsPerSecond / Double(beatDivisor)
    
    var answerKey : [Double] = []
    
    let initialTempo = unitInterval * Double(exercise[0][0].1)
    
    var t = initialTempo
    
    for measure in exercise {
        for beat in measure {
            let noteInterval = (unitInterval * Double(beat.1)) / Double(beat.0.characters.count)
            
            for note in beat.0.characters {
                if note == "1" {
                    answerKey.append(t)
                }
                t += noteInterval
            }
        }
    }
    
    print(answerKey)
    
    currentAnswerKey = answerKey
    return (answerKey, beatsPerSecond, initialTempo)
}

internal var exerciseInitialTime : NSTimeInterval = 0.0

internal func tapAreaTouched() {
    if currentAppState == .ExerciseRunning {
        let touchTime = NSDate().timeIntervalSinceReferenceDate - exerciseInitialTime
        
        print(touchTime)
        
        let primarySensitivity = 0.2
        
        var touchWasCorrect = false
        
        for timeIndex in 0...(currentAnswerKey.count - 1) {
            let time = currentAnswerKey[timeIndex]
            if touchTime > (time - primarySensitivity) && touchTime < (time + primarySensitivity) {
                currentAnswerKey.removeAtIndex(timeIndex)
                touchWasCorrect = true
                break
            }
        }
        
        print((touchWasCorrect) ? "Touch was Correct!" : "Touch was incorrect..")
        
    }
}




