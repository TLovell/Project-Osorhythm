//
//  ViewController.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/4/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import UIKit


internal var currentExercise : [[(String, Int)]]?
internal var currentPrimaryBeats : [[Bool]]?
internal var currentPrimarySkill : SkillSet?
internal var unitTimeInterval : Double?
internal var exerciseDisplay : ExerciseDisplay?

class ViewController: UIViewController {

    var attemptNumber = 0
    
    var tapCircle : CircleButton?
    func drawTapCircle() {
        let screenSize = UIScreen.mainScreen().bounds
        let r = ((441 * screenSize.width * screenSize.width) - (256 * screenSize.width * screenSize.height) + (272 * screenSize.height * screenSize.height)) / (336 * screenSize.width)
        let y = (16 / 21 * Double(screenSize.height))
        let circleButton = CircleButton(x: Double((screenSize.width / 2) - r), y: y, radius: Double(r), type: .TapCircle, visibleHeight: Double(screenSize.height) - y)
        
        tapCircle = circleButton
        view.addSubview(circleButton)
    }
    
    func drawExerciseDisplay() {
        let screenSize = UIScreen.mainScreen().bounds
        let orientation = UIDevice.currentDevice().orientation
        let frame = CGRect(x: Double(screenSize.width / 16), y: Double(screenSize.height * ((orientation.isLandscape) ? (1 / 6) : (2 / 21))), width: Double(screenSize.width) * (7 / 8), height: ((Double(screenSize.height) / 3) * 2) * ((orientation.isLandscape) ? (3 / 4) : (6 / 7)))
        
        exerciseDisplay = ExerciseDisplay(frame: frame)
        view.addSubview(exerciseDisplay!)
    }
    
    var metronome: Metronome?
    func drawMetronome() {
        let screenSize = UIScreen.mainScreen().bounds
        let frame = CGRect(x: 0.0, y: (2 / 3) * Double(screenSize.height), width: Double(screenSize.width), height: (1 / 2) * Double(screenSize.height))
        
        metronome = Metronome(frame: frame)
        metronome?.addTarget(self, action: #selector(ViewController.exerciseEnded), forControlEvents: .ValueChanged)
        view.addSubview(metronome!)
    }
    
    var starView: StarView?
    func drawStarView(starCount: Int) {
        let screenSize = UIScreen.mainScreen().bounds
        let orientation = UIDevice.currentDevice().orientation
        
        starView = StarView(x: Double(screenSize.width) * ((orientation.isLandscape) ? (3 / 8) : (1 / 3)), y: Double(screenSize.height) * (61 / 90), width: Double(screenSize.width) / ((orientation.isLandscape) ? 4 : 3), starCount: starCount)
        view.addSubview(starView!)
    }
    
    
    enum Alignment {
        case Left
        case Middle
        case Right
    }
    var nextExerciseButton : (button: CircleButton, alignment: Alignment, text: String)?
    var tryAgainButton : (button: CircleButton, alignment: Alignment, text: String)?
    func drawCircleButton(alignment: Alignment, type: CircleButton.ButtonType, text: String) {
        
        let screenSize = UIScreen.mainScreen().bounds
        let sw = Double(screenSize.width)
        let sh = Double(screenSize.height)
        let orientation = UIDevice.currentDevice().orientation
        var x = 0.0
        var y = 0.0
        var radius = 0.0
        if orientation.isLandscape {
            y = sh * (17/24)
            radius = sh / 8
            
            switch alignment {
            case .Left:
                x = sw * (5/21)
            case .Right:
                x = sw * (13/21)
            case .Middle:
                x = sw * (9/21)
            }
        } else {
            y = sh * (15/21)
            radius = sw / 6
            
            switch alignment {
            case .Left:
                x = sw / 12
            case .Right:
                x = sw * (7 / 12)
            case .Middle:
                x = sw / 3
            }
        }
        
        let newCircleButton = CircleButton(x: x, y: y, radius: radius, type: type, text: text)
        if type == .NextExercise {
            newCircleButton.addTarget(self, action: #selector(ViewController.generateButton), forControlEvents: .TouchUpInside)
            nextExerciseButton = (newCircleButton, alignment: alignment, text)
        } else if type == .TryAgain {
            newCircleButton.addTarget(self, action: #selector(ViewController.tryAgain), forControlEvents: .TouchUpInside)
            tryAgainButton = (newCircleButton, alignment: alignment, text)
        }
        
        view.addSubview(newCircleButton)
    }
    
    func initialize() {
        

        drawCircleButton(.Middle, type: .NextExercise, text: "Generate")
        
        
        //drawTapCircle()
        
        
//        for skillSet in skillSetList {
//            if skillSet == quarterNotes || skillSet == dupleSigs || skillSet == eighthNotes || skillSet == tripleSigs || skillSet == tripletNotes {
//                skillSet.skillLevel = (Double(random(40)) + 10) / 10
//            } else {
//                skillSet.skillLevel = Double(random(50)) / 10
//            }
//        }
        
        
    }
    
    
    var beatCount = 0
    
    func beatPassed() {
        let countDown = 16 - beatCount
        
        var blink = false
        
        if tapCircle != nil {
            switch countDown {
            case 8, 4:
                tapCircle!.setLabelText("1")
            case 6, 3:
                tapCircle!.setLabelText("2")
            case 2:
                tapCircle!.setLabelText("Ready")
            case 1:
                tapCircle!.setLabelText("Go!")
                exerciseInitialTime = NSDate().timeIntervalSinceReferenceDate
                currentAppState = .ExerciseRunning
            case 0:
                metronome!.blinkWithExercise(currentExercise!, unitTimeInterval: unitTimeInterval!)
                tempoTimer.invalidate()
                blink = true
            default:
                break
            }
        }
        
        
        metronome!.blink(blink)
        beatCount += 1
    }
    
    var tempoTimer = NSTimer()
    
    func deviceRotated() {
        
        let screenSize = UIScreen.mainScreen().bounds
        let orientation = UIDevice.currentDevice().orientation
        
        exerciseDisplay!.deviceRotated(CGRect(x: Double(screenSize.width / 16), y: Double(screenSize.height * ((orientation.isLandscape) ? (1 / 6) : (2 / 21))), width: Double(screenSize.width) * (7 / 8), height: ((Double(screenSize.height) / 3) * 2) * ((orientation.isLandscape) ? (3 / 4) : (6 / 7))), newOrientation: orientation)
        
        
        let r = ((441 * screenSize.width * screenSize.width) - (256 * screenSize.width * screenSize.height) + (272 * screenSize.height * screenSize.height)) / (336 * screenSize.width)
        let y = (16 / 21 * Double(screenSize.height))
        if tapCircle != nil {
            tapCircle!.resetFrame(Double((screenSize.width / 2) - r), y: y, radius: Double(r), visibleHeight: Double(screenSize.height) - y)
        }
        metronome!.frame = CGRect(x: 0.0, y: (2 / 3) * Double(screenSize.height), width: Double(screenSize.width), height: (1 / 2) * Double(screenSize.height))
        
        if nextExerciseButton != nil {
            nextExerciseButton!.button.removeFromSuperview()
            drawCircleButton(nextExerciseButton!.alignment, type: .NextExercise, text: nextExerciseButton!.text)
        }
        if tryAgainButton != nil {
            tryAgainButton!.button.removeFromSuperview()
            drawCircleButton(tryAgainButton!.alignment, type: .TryAgain, text: tryAgainButton!.text)
        }
        if starView != nil {
            starView!.adjustFrame(Double(screenSize.width) * ((orientation.isLandscape) ? (3 / 8) : (1 / 3)), y: Double(screenSize.height) * (61 / 90), width: Double(screenSize.width) / ((orientation.isLandscape) ? 4 : 3))
            
            
        }
        
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.deviceRotated), userInfo: nil, repeats: false)
    }
    
    
    var recordedResults : [(primaryGain: Double, secondaryGain: Double, totalGrade: Int)] = []
    
    func exerciseEnded() {
        let exerciseResults = results(attemptNumber)
        
        recordedResults.append(exerciseResults)

        drawStarView(exerciseResults.totalGrade)
        tapCircle!.fadeOut()
        
        
        drawCircleButton(.Left, type: .TryAgain, text: "Try Again")
        drawCircleButton(.Right, type: .NextExercise, text: "Next Exercise")
    }
    
    func tryAgain() {
        currentAppState = .CountOff
        
        attemptNumber += 1
        
        if tryAgainButton != nil {
            tryAgainButton!.button.fadeOut()
            tryAgainButton = nil
        }
        if nextExerciseButton != nil {
            nextExerciseButton!.button.fadeOut()
            nextExerciseButton = nil
        }
        if starView != nil {
            starView!.removeFromSuperview()
            starView = nil
        }
        
        drawTapCircle()
        
        let orientation = UIDevice.currentDevice().orientation
        
        exerciseDisplay!.resetView(false)
        exerciseDisplay!.display(exerciseDisplay!.currentExercise, timeSignature: exerciseDisplay!.timeSignature, orientation: orientation)
        
        let answer = answerKey(currentExercise!, primaryBeats: currentPrimaryBeats!, primarySkill: currentPrimarySkill!)
        unitTimeInterval = answer.unitTimeInterval
        
        beatCount = 6
        
        tempoTimer.invalidate()
        tempoTimer = NSTimer.scheduledTimerWithTimeInterval(answer.initialTempo, target: self, selector: #selector(ViewController.beatPassed), userInfo: nil, repeats: true)
    }
    
    
    
    
    func adjustSkillLevels() {
        
        var allPassingIndexes : [Int] = []
        for i in 0...(recordedResults.count - 1) {
            if recordedResults[i].totalGrade >= 0 {
                allPassingIndexes.append(i)
            }
        }
        
        var bestPerformanceIndex : Int = 0
        
        func findBestPerformance(indexList: [Int]) {
            for i in indexList {
                if recordedResults[i].primaryGain > recordedResults[bestPerformanceIndex].primaryGain || (recordedResults[i].primaryGain == recordedResults[bestPerformanceIndex].primaryGain && recordedResults[i].secondaryGain > recordedResults[bestPerformanceIndex].secondaryGain) {
                    bestPerformanceIndex = i
                }
            }
        }
        
        if !(allPassingIndexes.isEmpty) {
            findBestPerformance(allPassingIndexes)
        } else {
            var list : [Int] = []
            list += (0...(recordedResults.count - 1))
            findBestPerformance(list)
        }
        
        let bestPerformance = recordedResults[bestPerformanceIndex]
        
        if exerciseProperties != nil {
            let primarySkill = exerciseProperties!.primarySkill
            
            primarySkill.skillGain(bestPerformance.primaryGain)
            
            var secondarySkills = [exerciseProperties!.primarySubSkill.0, exerciseProperties!.secondarySubSkill.0, exerciseProperties!.timeSignatureSkill.0]
            
            if exerciseProperties!.mixtureBool.0 { secondarySkills.append(subMixture) }
            if exerciseProperties!.mixtureBool.1 { secondarySkills.append(timeMixture) }
            if exerciseProperties!.mixedTimeSignatureSkill.0 {
                secondarySkills.append(exerciseProperties!.mixedTimeSignatureSkill.1)
                secondarySkills.append(exerciseProperties!.mixedTimeSubSkill.0)
            }
            
            for skill in secondarySkills {
                if skill != primarySkill {
                    skill.skillGain(bestPerformance.secondaryGain)
                }
            }
            
        }
        
        for skill in skillSetList {
            print("\(skill.name): \(skill.skillLevel)")
        }
        
    }
    
    func generateButton(sender: CircleButton!) {
        
        
        
        currentAppState = .CountOff
        
        attemptNumber = 1
        
        if tryAgainButton != nil {
            tryAgainButton!.button.fadeOut()
            tryAgainButton = nil
        }
        if nextExerciseButton != nil {
            nextExerciseButton!.button.fadeOut()
            nextExerciseButton = nil
        }
        
        drawTapCircle()
        
        if exerciseDisplay != nil {
            exerciseDisplay!.resetView(true)
        }
        if starView != nil {
            starView!.removeFromSuperview()
            starView = nil
        }
        
        if !(recordedResults.isEmpty) {
            adjustSkillLevels()
        }
        recordedResults = []
        
        intensity = (intensity == 0.9) ? 0.0 : intensity + 0.1
        let exercise = generateExercise() // in Generation.swift
        currentExercise = exercise.exercise
        currentPrimaryBeats = exercise.primaryBeats
        currentPrimarySkill = exercise.primarySkill
        let heldNotes = notesHeld(currentExercise!) // in Display.swift
        
        exerciseDisplay!.display(displayInformation(heldNotes), timeSignature: exercise.timeSignature, orientation: UIDevice.currentDevice().orientation)
        
        
        let answer = answerKey(currentExercise!, primaryBeats: currentPrimaryBeats!, primarySkill: currentPrimarySkill!)
        unitTimeInterval = answer.unitTimeInterval
        
        
        beatCount = 0
        
        tempoTimer.invalidate()
        tempoTimer = NSTimer.scheduledTimerWithTimeInterval(answer.initialTempo, target: self, selector: #selector(ViewController.beatPassed), userInfo: nil, repeats: true)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawMetronome()
        initialize()
        
        drawExerciseDisplay()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

