//
//  Evaluation.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/22/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation

internal struct fraction {
    var n : Int
    var d : Int
    
    var string : String { return "\(n)/\(d)" }
    var decimal : Double { return Double(n) / Double(d) }
    var grade: Int {
        if decimal == 1.0 {
            return 3
        } else if decimal >= 0.85 {
            return 2
        } else if decimal >= 0.65 {
            return 1
        } else {
            return 0
        }
    }
    
    init(n: Int, d: Int) {
        self.n = n
        self.d = d
    }
}


var primaryGradeFraction = fraction(n: 0, d: 0)
var secondaryGradeFraction = fraction(n: 0, d: 0)

internal enum BeatDelegation {
    case Primary
    case Secondary
    case Both
}

var currentAnswerKey : [(time: Double, beatDelegation: BeatDelegation)] = []

internal func answerKey(exercise: [[(String, Int)]], primaryBeats: [[Bool]], primarySkill: SkillSet) -> (answerKey: [(time: Double, beatDelegation: BeatDelegation)], beatsPerSecond: Double, initialTempo: Double, unitTimeInterval: Double) {
    let tempo = 80.0 + (30 * intensity)
    let beatsPerSecond = 60 / tempo
    
    var beatDivisor = 3
    
    primaryGradeFraction.d = 0
    primaryGradeFraction.n = 0
    secondaryGradeFraction.d = 0
    secondaryGradeFraction.n = 0
    
    for measure in exercise {
        for beat in measure {
            if beat.1 == 2 {
                beatDivisor = 2
            }
        }
    }
    
    let unitInterval = beatsPerSecond / Double(beatDivisor)
    
    var answerKey : [(time: Double, beatDelegation: BeatDelegation)] = []
    
    let initialTempo = unitInterval * Double(exercise[0].last!.1)
    
    var t = initialTempo
    
    var measureIndex = 0
    for measure in exercise {
        var beatIndex = 0
        for beat in measure {
            let noteInterval = (unitInterval * Double(beat.1)) / Double(beat.0.characters.count)
            
            for note in beat.0.characters {
                if note == "1" {
                    let isPrimary = primaryBeats[measureIndex][beatIndex]
                    
                    
                    if primarySkill.type == 0 || primarySkill.technicalName == "c.1" {
                        (isPrimary) ? (primaryGradeFraction.d += 1) : (secondaryGradeFraction.d += 1)
                        answerKey.append((t, ((isPrimary) ? .Primary : .Secondary)))
                    } else if primarySkill.technicalName == "c.2" {
                        (measureIndex % 2 == 1) ? (primaryGradeFraction.d += 1) : (secondaryGradeFraction.d += 1)
                        answerKey.append((t, ((measureIndex % 2 == 1) ? .Primary : .Secondary)))
                    } else if  primarySkill.type == 1 {
                        answerKey.append((t, .Both))
                        primaryGradeFraction.d += 1
                        secondaryGradeFraction.d += 1
                    }
                }
                t += noteInterval
            }
            beatIndex += 1
        }
        measureIndex += 1
    }
    
    currentAnswerKey = answerKey
    return (answerKey, beatsPerSecond, initialTempo, unitInterval)
}

internal var exerciseInitialTime : NSTimeInterval = 0.0
internal var correctTouches = 0

internal func tapAreaTouched() {
    if currentAppState == .ExerciseRunning {
        let touchTime = NSDate().timeIntervalSinceReferenceDate - exerciseInitialTime
                
        let primarySensitivity = 0.04
        let secondarySensitivity = 0.095
        
        var touchWasCorrect = false
        if !currentAnswerKey.isEmpty {
            for timeIndex in 0...(currentAnswerKey.count - 1) {
                let tap = currentAnswerKey[timeIndex]
                if touchTime > (tap.time - secondarySensitivity) && touchTime < (tap.time + secondarySensitivity) {
                    currentAnswerKey.removeAtIndex(timeIndex)
                    touchWasCorrect = true
                    
                    let displacement = (abs(touchTime - tap.time) < primarySensitivity) ? 0.0 : ((touchTime - tap.time) / secondarySensitivity)
                    
                    exerciseDisplay!.recordTouch(timeIndex + correctTouches, displacement: displacement)
                    correctTouches += 1
                    
                    switch tap.beatDelegation {
                    case .Primary:
                        primaryGradeFraction.n += 1
                    case .Secondary:
                        secondaryGradeFraction.n += 1
                    case .Both:
                        primaryGradeFraction.n += 1
                        secondaryGradeFraction.n += 1
                    }
                    
                    break
                }
            }
        }
        
        if touchWasCorrect == false {
            secondaryGradeFraction.d += 1
        }
        
        
    }
}

func skillGain(primaryGrade: Int, secondaryGrade: Int, attemptNumber: Int) -> (primaryGain: Double, secondaryGain: Double) {
    
    let attemptIndex = ((attemptNumber > 4) ? 4 : attemptNumber) - 1
    
    let gainInfo = [
        [(-0.2, -0.1), (0.1, 0.0), (0.3, 0.1), (0.5, 0.3)],
        [(-0.2, -0.1), (0.0, 0.0), (0.1, 0.0), (0.3, 0.1)],
        [(-0.2, -0.1), (0.0, 0.0), (0.0, 0.0), (0.1, 0.0)],
        [(-0.2, -0.1), (-0.1, 0.0), (-0.1, 0.0), (0.0, 0.0)]
    ]
    
    let primaryGain = gainInfo[attemptIndex][primaryGrade].0
    let secondaryGain = gainInfo[attemptIndex][secondaryGrade].1
    
    return (primaryGain, secondaryGain)
}

internal func results(attemptNumber: Int) -> (primaryGain: Double, secondaryGain: Double, totalGrade: Int) {
    
    let gains = skillGain(primaryGradeFraction.grade, secondaryGrade: secondaryGradeFraction.grade, attemptNumber: attemptNumber)

    
    let totalGrade = ((primaryGradeFraction.grade * secondaryGradeFraction.grade) != 0) ? Int(roundDown(Double(primaryGradeFraction.grade + secondaryGradeFraction.grade) / 2)) : 0
    
    return (gains.primaryGain, gains.secondaryGain, totalGrade)
}




