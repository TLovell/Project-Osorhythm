//
//  Metronome.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 7/4/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Metronome: UIControl {
    
    var beatsInFirstMeasure : Int = 0
    
    var tickSound : SystemSoundID = 1057
    var tockSound : SystemSoundID = 1103
    var beatCount = 0
    
    let countOffText = [[], [],
                        ["1", "2", "Ready", "Go!"],
                        ["1", "2", "3", "1", "Ready", "Go!"],
                        ["1", "", "2", "", "1", "2", "Ready", "Go!"],
                        ["1", "", "", "", "", "1", "2", "3", "Ready", "Go!"],
                        ["1", "", "", "2", "", "", "1", "2", "3", "4", "Ready", "Go!"]
    ]
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func fade() {
        self.alpha += 0.03
    }
    
    var fadeTimer : NSTimer?
    func blink(accent: Bool) {
        beatCount += 1
        
        var overrideAccent = accent
        
        if beatCount < 0 && beatCount >= -(beatsInFirstMeasure * 2) {
            let str = countOffText[beatsInFirstMeasure][beatCount + (beatsInFirstMeasure * 2)]
            
            if str == "1" || str == "Ready" || str == "Go!" {
                overrideAccent = true
            }
            
            tapCircle!.setLabelText(countOffText[beatsInFirstMeasure][beatCount + (beatsInFirstMeasure * 2)])
            
        }
        
        
        AudioServicesPlaySystemSound((overrideAccent) ? tickSound : tockSound)
        
        
        self.alpha = (accent) ? 0.2 : 0.5
        
        if fadeTimer != nil {
            fadeTimer!.invalidate()
        }
        
        fadeTimer = NSTimer.scheduledTimerWithTimeInterval((accent) ? 0.02 : 0.05, target: self, selector: #selector(Metronome.fade), userInfo: nil, repeats: true)
        
        if beatCount == -1 {
            exerciseInitialTime = NSDate().timeIntervalSinceReferenceDate
            currentAppState = .ExerciseRunning
            if tapCircle!.userInteractionEnabled == false {
                tapCircle!.autoPlay()
            }
        }
        
        
    }
    
    
    private func createUnitList(exercise: [[(String, Int)]], firstAttempt: Bool) -> [Int] {
        var unitList : [Int] = []
        var measureIndex = 0
        for measure in exercise {
            var beatIndex = 0
            for beat in measure {
                for i in 0...(beat.1 - 1) {
                    var newUnit = (i == 0) ? 1 : 0
                    newUnit = ((newUnit == 1) && (beatIndex == 0)) ? 2 : newUnit
                    unitList.append(newUnit)
                }
                beatIndex += 1
            }
            if measureIndex == 0 {
                let maxIndex = (firstAttempt) ?  3 : 1
                let firstMeasure = unitList
                
                unitList.removeAll()
                unitList.append(1)
                
                for _ in 0...maxIndex {
                    for unit in firstMeasure {
                        if unit == 0 {
                            unitList.append(0)
                        } else {
                            unitList.append(1)
                        }
                    }
                }
                
                unitList += firstMeasure
            }
            measureIndex += 1
        }
        return unitList
    }
    
    var unitList : [Int] = []
    var blinkWithExerciseTimer : NSTimer?
    
    func unitPassed() {
        if !(unitList.isEmpty) {
            switch unitList[0] {
            case 1:
                blink(false)
            case 2:
                blink(true)
            default:
                break
            }
            unitList.removeFirst()
        } else {
            blinkWithExerciseTimer!.invalidate()
            currentAppState = .Results
            correctTouches = 0
            self.sendActionsForControlEvents(.ValueChanged)
        }
        
    }
    
    
    
    
    func blinkWithExercise(exercise: [[(String, Int)]], unitTimeInterval: Double, firstAttempt: Bool) {
        unitList = createUnitList(exercise, firstAttempt: firstAttempt)
        beatsInFirstMeasure = exercise[0].count
        
        beatCount = (firstAttempt) ? (-1 - (beatsInFirstMeasure * 4)) : (-1 - (beatsInFirstMeasure * 2))
        
        unitList.removeFirst()
        blinkWithExerciseTimer = NSTimer.scheduledTimerWithTimeInterval(unitTimeInterval, target: self, selector: #selector(Metronome.unitPassed), userInfo: nil, repeats: true)
    }
    
}