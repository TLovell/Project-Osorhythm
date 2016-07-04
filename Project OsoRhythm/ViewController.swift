//
//  ViewController.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/4/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var Display: UITextView!
    @IBOutlet weak var Display2: UITextView!
    @IBOutlet weak var tapOffLabel: UILabel!
    
    
    var exerciseDisplay : ExerciseDisplay? = nil
    @IBOutlet weak var generateView: UIButton!

    var tapCircle : CircleButton?
    func drawTapCircle() {
        let screenSize = UIScreen.mainScreen().bounds
        let r = ((441 * screenSize.width * screenSize.width) - (256 * screenSize.width * screenSize.height) + (272 * screenSize.height * screenSize.height)) / (336 * screenSize.width)
        let y = (16 / 21 * Double(screenSize.height))
        let circleButton = CircleButton(x: Double((screenSize.width / 2) - r), y: y, radius: Double(r), visibleHeight: Double(screenSize.height) - y)
        
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
    
    func initialize() {
        
        drawTapCircle()
        
        
        for skillSet in skillSetList {
            if skillSet == quarterNotes || skillSet == dupleSigs || skillSet == eighthNotes || skillSet == tripleSigs || skillSet == tripletNotes {
                skillSet.skillLevel = (Double(random(40)) + 10) / 10
            } else {
                skillSet.skillLevel = Double(random(50)) / 10
            }
        }
    }
    
    
    var beatCount = 0
    
    func beatPassed() {
        let countDown = 16 - beatCount
        
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
        default:
            break
        }
        }
            
        beatCount += 1
    }
    
    var tempoTimer = NSTimer()
    
    func deviceRotated() {
        
        let screenSize = UIScreen.mainScreen().bounds
        let orientation = UIDevice.currentDevice().orientation
        
        exerciseDisplay!.deviceRotated(CGRect(x: Double(screenSize.width / 16), y: Double(screenSize.height * ((orientation.isLandscape) ? (1 / 6) : (2 / 21))), width: Double(screenSize.width) * (7 / 8), height: ((Double(screenSize.height) / 3) * 2) * ((orientation.isLandscape) ? (3 / 4) : (6 / 7))), newOrientation: orientation)
        
        
        let r = ((441 * screenSize.width * screenSize.width) - (256 * screenSize.width * screenSize.height) + (272 * screenSize.height * screenSize.height)) / (336 * screenSize.width)
        let y = (16 / 21 * Double(screenSize.height))
        tapCircle!.resetFrame(Double((screenSize.width / 2) - r), y: y, radius: Double(r), visibleHeight: Double(screenSize.height) - y)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("deviceRotated"), userInfo: nil, repeats: false)
    }
    
    @IBAction func generateButton(sender: AnyObject) {
        
        currentAppState = .CountOff
        
        if exerciseDisplay != nil {
            exerciseDisplay!.resetView(true)
        }
        
        intensity = (intensity == 0.9) ? 0.0 : intensity + 0.1
        let exercise = generateExercise() // in Generation.swift
        let heldNotes = notesHeld(exercise.exercise) // in Display.swift
        
        exerciseDisplay!.display(displayInformation(heldNotes), timeSignature: exercise.timeSignature, orientation: UIDevice.currentDevice().orientation)
        
        answerKey(exercise.exercise)
        
        beatCount = 0
        
        tempoTimer.invalidate()
        tempoTimer = NSTimer.scheduledTimerWithTimeInterval(answerKey(exercise.exercise).initialTempo, target: self, selector: Selector("beatPassed"), userInfo: nil, repeats: true)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        
        drawExerciseDisplay()
        
        view.bringSubviewToFront(generateView)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

