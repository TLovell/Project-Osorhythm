//
//  Metronome.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 7/4/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation
import UIKit

class Metronome: UIControl {
    
    

    
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
        self.alpha = (accent) ? 0.2 : 0.5
        
        if fadeTimer != nil {
            fadeTimer!.invalidate()
        }
        
        fadeTimer = NSTimer.scheduledTimerWithTimeInterval((accent) ? 0.02 : 0.05, target: self, selector: #selector(Metronome.fade), userInfo: nil, repeats: true)
    }
    
    
    private func createUnitList(exercise: [[(String, Int)]]) -> [Int] {
        var unitList : [Int] = []
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
    
    func blinkWithExercise(exercise: [[(String, Int)]], unitTimeInterval: Double) {
        unitList = createUnitList(exercise)
        unitList.removeFirst()
        blinkWithExerciseTimer = NSTimer.scheduledTimerWithTimeInterval(unitTimeInterval, target: self, selector: #selector(Metronome.unitPassed), userInfo: nil, repeats: true)
    }
    
}