//
//  ExerciseDisplay.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/30/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation

import UIKit

class ExerciseDisplay: UIView {
    var currentExercise : [[([(length: Int, beams: Int, noteType: Int, tied: Bool, dotted: Bool)], units: Int)]] = []
    var timeSignature : (String, String) = ("", "")
    private var addedImages : [UIImageView] = []
    private var addedFlags : [UIImageView] = []
    private var addedLabels : [UILabel] = []
    var orientation : UIDeviceOrientation = .Portrait
    private var unitHeight = 0.0
    private var noteHeight = 0.0
    private var noteWidth = 0.0
    private var tappedNoteFrames : [CGRect] = []
    
    override init(frame: CGRect) {
        self.orientation = UIDevice.currentDevice().orientation
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func resetView(hardReset: Bool) {
        for image in addedImages {
            image.removeFromSuperview()
        }
        for label in addedLabels {
            label.removeFromSuperview()
        }
        addedImages.removeAll()
        addedLabels.removeAll()
        addedFlags.removeAll()
        tappedNoteFrames.removeAll()
        
        if hardReset {
            currentExercise = []
            timeSignature = ("", "")
            unitHeight = 0.0
            noteHeight = 0.0
            noteWidth = 0.0
        }
        
    }
    
    func numberOfUnitsInLines() -> [Int] {
        var unitsInLines : [Int] = []
        var measureIndex = 0
        var unitCount = 0
        
        // Counts all the "units" needed per line.
        
        for measure in currentExercise {
            for beat in measure {
                unitCount += beat.units
            }
            
            if orientation.isLandscape {
                if measureIndex == 1 || measureIndex == 3 {
                    if timeSignature.0 == timeSignature.1 {
                        unitCount += 4
                    } else {
                        unitCount += 5
                    }
                    
                    unitsInLines.append(unitCount)
                    unitCount = 0
                }
            } else {
                unitCount += 3
                
                unitsInLines.append(unitCount)
                unitCount = 0
            }
            
            measureIndex += 1
        }
        
        return unitsInLines
    }
    
    func setUnitAndNoteDimensions(unitsInLines: [Int]) {
        unitHeight = Double(frame.height) / Double(unitsInLines.count)
        
        var lineIndex = 0
        let numberOfMeasuresInLine = (orientation.isLandscape) ? 2 : 1
        
        
        var smallestNoteWidth = unitHeight / 3
        
        for units in unitsInLines {
            
            let unitWidth = Double(frame.width) / Double(units)
            let measureIndexOffput = lineIndex * numberOfMeasuresInLine
            
            for measureIndex in (measureIndexOffput)...((numberOfMeasuresInLine - 1) + measureIndexOffput) {
                for beat in currentExercise[measureIndex] {
                    var sumOfLengthsInBeat = 0
                    for note in beat.0 {
                        sumOfLengthsInBeat += note.length
                    }
                    
                    let noteWidth = (unitWidth * Double(beat.units)) / Double(sumOfLengthsInBeat)
                    
                    if noteWidth < smallestNoteWidth || smallestNoteWidth == 0  {
                        smallestNoteWidth = noteWidth
                    }
                }
            }
            lineIndex += 1
        }
        
        noteHeight = smallestNoteWidth * 3
        noteWidth = smallestNoteWidth
    }
    
    func addImageView(assetIndentifier: UIImage.AssetIdentifier, x: Double, y: Double, width: Double, height: Double) -> UIImageView {
        let imageView = UIImageView(image: UIImage(assetIndentifier: assetIndentifier))
        imageView.frame = CGRect(x: Int(roundDown(x)), y: Int(roundDown(y)), width: Int(roundDown(width)), height: Int(roundDown(height)))
        if assetIndentifier == .Flag {
            addedFlags.append(imageView)
        } else if assetIndentifier == .NoteHead {
            imageView.image = imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            imageView.tintColor = tapCircle!.topCircle.backgroundColor?.colorWithAlphaComponent(1.0)
        }
        self.addSubview(imageView)
        addedImages.append(imageView)
        return imageView
    }
    
    func addLabel(text: String, x: Double, y: Double, width: Double, height: Double) -> UILabel {
        let label = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
        label.text = text
        label.font = UIFont.systemFontOfSize(CGFloat(height))
        label.textAlignment = .Center
        self.addSubview(label)
        addedLabels.append(label)
        return label
    }
    
    
    
    func displayNotation(unitsInLines: [Int]) {
        var previousNote : (length: Int, beams: Int, noteType: Int, tied: Bool, dotted: Bool, x: Double, y: Double, drawnBeams: Int, drawnFlags: Int) = (0, 0, 0, false, false, 0, 0, 0, 0)
        
        let numberOfMeasuresInLine = (orientation.isLandscape) ? 2 : 1
        // Notes and rests and flags and dots are officially added to the screen here. Beams and dots and time signatures are coming soon.
        
        var lineIndex = 0
        for units in unitsInLines {
            
            let unitWidth = Double(frame.width) / Double(units)
            
            var x = 0.0
            let y = (unitHeight * Double(lineIndex))
            
            let measureIndexOffput = lineIndex * numberOfMeasuresInLine
            
            for measureIndex in (measureIndexOffput)...((numberOfMeasuresInLine - 1) + measureIndexOffput) {
                
                if measureIndex == measureIndexOffput {
                    addImageView(.StartBarLine, x: x, y: y, width: unitWidth, height: noteHeight)
                } else {
                    addImageView(.MiddleBarLine, x: x, y: y, width: unitWidth, height: noteHeight)
                }
                x += unitWidth
                
                if timeSignature.0 != timeSignature.1 {
                    let timeSigIndex = measureIndex % 2
                    var sigNumerator = ""
                    var sigDenominator = ""
                    if timeSigIndex == 1 {
                        sigNumerator = String(timeSignature.1.characters.prefix(Int(timeSignature.1.startIndex.distanceTo(timeSignature.1.characters.indexOf("/")!))))
                        sigDenominator = String(timeSignature.1.characters.last!)
                    } else {
                        sigNumerator = String(timeSignature.0.characters.prefix(Int(timeSignature.0.startIndex.distanceTo(timeSignature.0.characters.indexOf("/")!))))
                        sigDenominator = String(timeSignature.0.characters.last!)
                    }
                    
                    addImageView(.SignatureBar, x: x, y: y, width: unitWidth, height: noteHeight)
                    addLabel(sigNumerator, x: x, y: y, width: unitWidth, height: noteHeight * (7 / 24))
                    addLabel(sigDenominator, x: x, y: y + (noteHeight * (9 / 24)), width: unitWidth, height: noteHeight * (7 / 24))
                    
                    x += unitWidth
                } else if measureIndex % numberOfMeasuresInLine == 0 {
                    let timeSigIndex = lineIndex % 2
                    var sigNumerator = ""
                    var sigDenominator = ""
                    if timeSigIndex == 1 {
                        sigNumerator = String(timeSignature.1.characters.prefix(Int(timeSignature.1.startIndex.distanceTo(timeSignature.1.characters.indexOf("/")!))))
                        sigDenominator = String(timeSignature.1.characters.last!)
                    } else {
                        sigNumerator = String(timeSignature.0.characters.prefix(Int(timeSignature.0.startIndex.distanceTo(timeSignature.0.characters.indexOf("/")!))))
                        sigDenominator = String(timeSignature.0.characters.last!)
                    }
                    
                    addImageView(.SignatureBar, x: x, y: y, width: unitWidth, height: noteHeight)
                    addLabel(sigNumerator, x: x, y: y, width: unitWidth, height: noteHeight * (7 / 24))
                    addLabel(sigDenominator, x: x, y: y + (noteHeight * (9 / 24)), width: unitWidth, height: noteHeight * (7 / 24))
                    
                    x += unitWidth
                }
                
                var beatIndex = 0
                for beat in currentExercise[measureIndex] {
                    var sumOfLengthsInBeat = 0
                    
                    for note in beat.0 {
                        sumOfLengthsInBeat += note.length
                    }
                    
                    
                    let deltaX = (unitWidth * Double(beat.units)) / Double(sumOfLengthsInBeat)
                    
                    if sumOfLengthsInBeat % beat.units != 0 && sumOfLengthsInBeat > 1 {
                        
                        let labelHeight =  (unitHeight - (noteHeight * (5 / 6))) < (noteHeight * (4 / 9)) ? unitHeight - (noteHeight * (5 / 6)) : noteHeight * (4 / 9)
                        
                        addLabel("\(sumOfLengthsInBeat)", x: x + (noteWidth / 2), y: y - labelHeight - 3, width: (deltaX * Double(sumOfLengthsInBeat)) * (39 / 40), height: labelHeight / 2)
                        addImageView(.Bracket, x: x + (noteWidth / 2), y: y - labelHeight - 3, width: (deltaX * Double(sumOfLengthsInBeat) * (39 / 40)), height: labelHeight)
                    }
                    
                    
                    
                    var noteIndex = 0
                    for note in beat.0 {
                        if note.beams >= 0 {
                            var noteID : UIImage.AssetIdentifier?
                            
                            if note.noteType == 1 {
                                noteID = .QuarterNote
                                if !(previousNote.tied) {
                                    tappedNoteFrames.append(CGRect(x: x, y: y, width: noteWidth, height: noteHeight))
                                }
                            } else {
                                switch note.beams {
                                case 0:
                                    noteID = .QuarterRest
                                case 1:
                                    noteID = .EighthRest
                                case 2:
                                    noteID = .SixteenthRest
                                default:
                                    break
                                }
                            }
                            
                            addImageView(noteID!, x: x, y: y, width: noteWidth, height: noteHeight)
                            
                            
                            if previousNote.tied {
                                if previousNote.x < x {
                                    addImageView(.Tie, x: previousNote.x + (noteWidth / 2), y: previousNote.y + ((2/3) * noteHeight), width: x - previousNote.x, height: noteWidth)
                                } else {
                                    addImageView(.Tie, x: previousNote.x + (noteWidth / 2), y: previousNote.y + ((2/3) * noteHeight), width: (Double(frame.width) + 10) - previousNote.x, height: noteWidth)
                                    addImageView(.Tie, x: -10 - (noteWidth / 2), y: y + ((2/3) * noteHeight), width: x - (-10 - (noteWidth / 2)), height: noteWidth)
                                }
                            }
                            
                            
                            if note.dotted {
                                addImageView(.Dot, x: x + noteWidth, y: y, width: noteWidth, height: noteHeight)
                            }
                            
                            var drawnFlags = 0
                            var drawnBeams = 0
                            
                            if note.beams > 0 && note.noteType == 1 {
                                if previousNote.beams > 0 && previousNote.noteType == 1 && noteIndex != 0 {
                                    // Removes previous Flags
                                    if previousNote.drawnFlags > 0 {
                                        for _ in 1...previousNote.drawnFlags {
                                            addedFlags.last!.removeFromSuperview()
                                            addedFlags.removeLast()
                                        }
                                    }
                                    // Draws beams that current and previous note share
                                    let numberOfSharedBeams = (previousNote.beams < note.beams) ? previousNote.beams : note.beams
                                    for beamIndex in 0...(numberOfSharedBeams - 1) {
                                        addImageView(.Beam, x: previousNote.x + noteWidth - 1, y: y + (Double(beamIndex) * (noteHeight / 6)), width: deltaX * Double(previousNote.length), height: noteWidth / 4)
                                        drawnBeams += 1
                                    }
                                    // Draws remaining beams that previous note hasn't drawn yet
                                    if drawnBeams < previousNote.beams && previousNote.drawnBeams < previousNote.beams {
                                        if previousNote.drawnBeams == 0 {
                                            for beamIndex in drawnBeams...(previousNote.beams - 1) {
                                                addImageView(.Beam, x: previousNote.x + noteWidth - 1, y: y + (Double(beamIndex) * (noteHeight / 6)), width: (deltaX * Double(previousNote.length)) / 2, height: noteWidth / 4)
                                            }
                                        } else {
                                            for beamIndex in previousNote.drawnBeams...(previousNote.beams - 1) {
                                                addImageView(.Beam, x: previousNote.x + (noteWidth / 2) - 1, y: y + (Double(beamIndex) * (noteHeight / 6)), width: noteWidth / 2, height: noteWidth / 4)
                                            }
                                        }
                                    }
                                    
                                    if noteIndex == beat.0.count - 1 || currentExercise[measureIndex][beatIndex].0[noteIndex + 1].noteType == 0 {
                                        if drawnBeams < note.beams {
                                            for beamIndex in drawnBeams...(note.beams - 1) {
                                                addImageView(.Beam, x: x + (noteWidth / 2) - 1, y: y + (Double(beamIndex) * (noteHeight / 6)), width: noteWidth / 2, height: noteWidth / 4)
                                            }
                                        }
                                    }
                                    
                                } else {
                                    for i in 0...(note.beams - 1) {
                                        addImageView(.Flag, x: x + noteWidth - 1, y: y + (Double(i) * (noteHeight / 6)), width: noteWidth, height: noteWidth)
                                        drawnFlags += 1
                                    }
                                }
                            }
                            
                            previousNote = (note.length, note.beams, note.noteType, note.tied, note.dotted, x, y, drawnBeams, drawnFlags)
                        }
                        
                        x += deltaX * Double(note.length)
                        
                        noteIndex += 1
                    }
                    
                    
                    beatIndex += 1
                }
            }
            
            let barLineID : UIImage.AssetIdentifier = (lineIndex == (unitsInLines.count - 1)) ? .DoubleBarLine : .EndBarLine
            
            addImageView(barLineID, x: x, y: y, width: unitWidth, height: noteHeight)
            
            lineIndex += 1
        }

    }
    
    func recordTouch(touchIndex: Int, displacement: Double) {
        let noteFrame = tappedNoteFrames[touchIndex]
        let x = Double(noteFrame.origin.x) + ((noteWidth / 2) * displacement)
        addImageView(.NoteHead, x: x, y: Double(noteFrame.origin.y), width: Double(noteFrame.width), height: Double(noteFrame.height))
    }
    
    
    func display(exercise: [[([(length: Int, beams: Int, noteType: Int, tied: Bool, dotted: Bool)], units: Int)]], timeSignature: (String, String), orientation: UIDeviceOrientation) {
        self.currentExercise = exercise
        self.timeSignature = timeSignature
        self.orientation = orientation
        let unitsInLines = numberOfUnitsInLines()
        setUnitAndNoteDimensions(unitsInLines)
        displayNotation(unitsInLines)
    }
    
    func deviceRotated(frame: CGRect, newOrientation: UIDeviceOrientation) {
        resetView(false)
        self.frame = frame
        display(currentExercise, timeSignature: timeSignature, orientation: newOrientation)
    }
    
    
}