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
    
    func initialize() {
        for skillSet in skillSetList {
            if skillSet == quarterNotes || skillSet == dupleSigs || skillSet == eighthNotes {
                skillSet.skillLevel = (Double(random(40)) + 10) / 10
            } else {
                skillSet.skillLevel = Double(random(50)) / 10
            }
        }
    }
    
    var addedImages : [UIImageView] = []
    
    func addImageView(name: String, x: Double, y: Double, width: Double, height: Double) -> UIImageView {
        print("\(name) \(x) \(y) \(width) \(height)")
        let imageView = UIImageView(image: UIImage(named: name))
        imageView.frame = CGRect(x: Int(round(x)), y: Int(round(y)), width: Int(round(width)), height: Int(round(height)))
        view.addSubview(imageView)
        addedImages.append(imageView)
        return imageView
    }
    
    func displayExercise(displayInfo: [[([(length: Int, beams: Int, noteType: Int, tied: Bool, dotted: Bool)], units: Int)]], exercise: [[(String, Int)]], timeSignature: (String, String)) {
        let screenSize = UIScreen.mainScreen().bounds
        let orientation = UIDevice.currentDevice().orientation
        let exerciseAreaHeight = ((Double(screenSize.height) / 3) * 2) * ((orientation.isLandscape) ? (3 / 4) : (6 / 7))
        let yOffset = Double(screenSize.height * ((orientation.isLandscape) ? (1 / 6) : (2 / 21)))
        
        var numberOfUnitsInLines : [Int] = []
        var measureIndex = 0
        var unitCount = 0
        for measure in displayInfo {
            for beat in measure {
                unitCount += beat.units
            }
            
            if orientation.isLandscape {
                if measureIndex == 1 || measureIndex == 3 {
                    if timeSignature.0 == timeSignature.1 {
                        unitCount += 6
                    } else {
                        unitCount += 8
                    }
                    
                    numberOfUnitsInLines.append(unitCount)
                    unitCount = 0
                }
            } else {
                unitCount += 5
                
                numberOfUnitsInLines.append(unitCount)
                unitCount = 0
            }
            
            measureIndex += 1
        }
        
        let unitHeight = exerciseAreaHeight / Double(numberOfUnitsInLines.count)
        
        var lineIndex = 0
        let numberOfMeasuresInLine = (orientation.isLandscape) ? 2 : 1
        
        for units in numberOfUnitsInLines {
            
            let unitWidth = Double(screenSize.width) / Double(units)
            
            var x = 0.0
            let y = yOffset + (unitHeight * Double(lineIndex))
            
            let measureIndexOffput = lineIndex * numberOfMeasuresInLine
            
            var smallestNoteWidth = 0.0
            
            for measureIndex in (0 + measureIndexOffput)...((numberOfMeasuresInLine - 1) + measureIndexOffput) {
                for beat in displayInfo[measureIndex] {
                    var sumOfLengthsInBeat = 0
                    for note in beat.0 {
                        sumOfLengthsInBeat += note.length
                    }
                    
                    print("sum of lengths in beat = \(sumOfLengthsInBeat)")
                    
                    let noteWidth = (unitWidth * Double(beat.units)) / Double(sumOfLengthsInBeat)
                    
                    if noteWidth < smallestNoteWidth || smallestNoteWidth == 0  {
                        smallestNoteWidth = noteWidth
                    }
                }
            }
            
            for measureIndex in (0 + measureIndexOffput)...((numberOfMeasuresInLine - 1) + measureIndexOffput) {
                
                addImageView("Bar Line.png", x: x, y: y, width: unitWidth, height: unitHeight)
                x += unitWidth
                
                if timeSignature.0 != timeSignature.1 { //Time signature development later?
                    
                    x += unitWidth
                } else if measureIndex % numberOfMeasuresInLine == 0 {
                    
                    x += unitWidth
                }
                
                var beatIndex = 0
                for beat in displayInfo[measureIndex] {
                    var sumOfLengthsInBeat = 0
                    
                    print("\(beat.0)")
                    for note in beat.0 {
                        sumOfLengthsInBeat += note.length
                    }
                    
                    
                    print("unitWidth = \(unitWidth), beat.units = \(beat.units), sumOfLengthsInBeat = \(sumOfLengthsInBeat)")
                    let deltaX = (unitWidth * Double(beat.units)) / Double(sumOfLengthsInBeat)
                    
                    
                    
                    var noteIndex = 0
                    for note in beat.0 {
                        if note.beams >= 0 {
                            var noteName : String = ""
                            
                            if note.noteType == 1 {
                                noteName = "note.png"
                            } else {
                                switch note.beams {
                                case 0:
                                    noteName = "Quarter Rest.png"
                                case 1:
                                    noteName = "Eighth Rest.png"
                                case 2:
                                    noteName = "Sixteenth Rest.png"
                                default:
                                    break
                                }
                            }
                            
                            addImageView(noteName, x: x, y: y, width: smallestNoteWidth, height: unitHeight)
                            if note.dotted {
                                addImageView("Dot.png", x: x + smallestNoteWidth, y: y, width: smallestNoteWidth, height: unitHeight)
                            }
                            if note.beams > 0 && note.noteType == 1 {
                                for i in 0...(note.beams - 1) {
                                    addImageView("Flag.png", x: x + smallestNoteWidth, y: y + (Double(i) * (unitHeight / 6)), width: smallestNoteWidth, height: deltaX)
                                }
                            }
                        }
                        
                        x += deltaX * Double(note.length)
                        
                        noteIndex += 1
                    }
                    
                    
                    beatIndex += 1
                }
            }
            
            let barLineName = (lineIndex == (numberOfUnitsInLines.count - 1)) ? "Double Bar Line.png" : "Bar Line.png"
            
            addImageView(barLineName, x: x, y: yOffset + (unitHeight * Double(lineIndex)), width: unitWidth, height: unitHeight)
            
            lineIndex += 1
        }
        
        
        
    }
    
    func resetView() {
        for image in addedImages {
            image.removeFromSuperview()
        }
        addedImages.removeAll()
    }
    
    @IBAction func generateButton(sender: AnyObject) {
        resetView()
        
        intensity = (intensity == 0.9) ? 0.0 : intensity + 0.1
        let exercise = generateExercise()
        let heldNotes = notesHeld(exercise.exercise)
        Display2.text = String(heldNotes)
        displayExercise(displayInformation(heldNotes), exercise: exercise.exercise, timeSignature: exercise.timeSignature)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

