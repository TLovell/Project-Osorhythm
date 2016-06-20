//
//  Display.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/5/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation

// Turns some 0's in the exercise to 2's to indicate that the "1" preceding them is "held". These held notes will be delegated as ties or dots or lower "beam counts" in later functions.
internal func notesHeld(exercise: [[(String, Int)]]) -> [[(String, Int)]] {
    var newExercise : [[(String, Int)]] = []
    var measureIndex = 0
    var previousNote = "0"
    for measure in exercise {
        var newMeasure : [(String, Int)] = []
        var beatIndex = 0
        for beat in measure {
            var newBeat : (String, Int) = ("", exercise[measureIndex][beatIndex].1)
            var noteIndex = 0
            for note in beat.0.characters {
                var newNote : String = ""
                var meetsLevelRequirement : Bool = false
                
                if noteIndex == 0 {
                    if beatIndex == 0 {
                        if measureIndex != 0 {
                            if passiveDisplay.skillLevel >= 2.0 {
                                meetsLevelRequirement = true
                            }
                        }
                    } else {
                        if passiveDisplay.skillLevel >= 1.0 {
                            meetsLevelRequirement = true
                        }
                    }
                } else {
                    meetsLevelRequirement = true
                }
                
                newNote = (meetsLevelRequirement && previousNote != "0" && random(4) != 0 && note == "0") ? "2" : String(note)
                previousNote = newNote
                newBeat.0 += newNote
                
                noteIndex += 1
            }
            newMeasure.append(newBeat)
            beatIndex += 1
        }
        newExercise.append(newMeasure)
        measureIndex += 1
    }
    return newExercise
}


// Takes the exercise and creates displayInformation, which basically lays out what the exercise is in musical notation.
func displayInformation(exercise: [[(String, Int)]]) -> [[([(length: Int, beams: Int, noteType: Int, tied: Bool, dotted: Bool)], units: Int)]] {
    
    var displayLengthsAndTies : [[([(length: Int, noteType: Int, tied: Bool)], beams: Int, units: Int)]] = []
    
    // for every note in the exercise, this explains what its length is in Integers. If the note is extended over multiple beats, it divides the full length across the beats and attaches ties to the notes.
    var measureIndex = 0
    for measure in exercise {
        var newMeasure : [([(length: Int, noteType: Int, tied: Bool)], beams: Int, units: Int)] = []
        var beatIndex = 0
        for beat in measure {
            let beams = getSubSkillSetFromDivision(beat.0.characters.count).beams
            
            var newBeat : ([(length: Int, noteType: Int, tied: Bool)], beams: Int, units: Int) = ([], beams,  exercise[measureIndex][beatIndex].1)
            
            var noteIndex = 0
            var newNote : (length: Int, noteType: Int, tied: Bool) = (0, 0, false)
            
            for note in beat.0.characters {
                switch note {
                case "1" :
                    if newNote.length > 0 {
                        newBeat.0.append(newNote)
                        newNote.tied = false
                    }
                    newNote.length = 1
                    newNote.noteType = 1
                case "2" :
                    newNote.length += 1
                    newNote.noteType = 1
                    if noteIndex == 0 {
                        if beatIndex == 0 {
                            if var lastMeasure = displayLengthsAndTies.last {
                                if var lastBeat = lastMeasure.last {
                                    if let lastNote = lastBeat.0.last {
                                        lastBeat.0.removeLast()
                                        lastBeat.0.append((lastNote.length, lastNote.noteType, true))
                                        
                                        lastMeasure.removeLast()
                                        lastMeasure.append(lastBeat)
                                        
                                        displayLengthsAndTies.removeLast()
                                        displayLengthsAndTies.append(lastMeasure)
                                    }
                                }
                            }
                        } else {
                            if var lastBeat = newMeasure.last {
                                if let lastNote = lastBeat.0.last {
                                    lastBeat.0.removeLast()
                                    lastBeat.0.append((lastNote.length, lastNote.noteType, true))
                                    
                                    newMeasure.removeLast()
                                    newMeasure.append(lastBeat)
                                    
                                }
                            }
                        }
                    }
                case "0" :
                    if newNote.noteType == 0 {
                        newNote.length += 1
                    } else {
                        newBeat.0.append(newNote)
                        newNote.tied = false
                        newNote.noteType = 0
                        newNote.length = 1
                    }
                default:
                        break
                }
                noteIndex += 1
            }
            newBeat.0.append(newNote)
            newMeasure.append(newBeat)
            beatIndex += 1
        }
        displayLengthsAndTies.append(newMeasure)
        measureIndex += 1
    }
    
    
    var displayBeamsAndDots : [[([(length: Int, beams: Int, noteType: Int, tied: Bool, dotted: Bool)], units: Int)]] = []
    
    // This takes the lengths from above and redescribes them in terms of musical notation. AKA number of Flags (beams variable), Dots, and Ties. This does not handle notes that extend across multiple beats, although it will handle their "pieces" within singular beats.
    for measure in displayLengthsAndTies {
        var newMeasure : [([(length: Int, beams: Int, noteType: Int, tied: Bool, dotted: Bool)], units: Int)] = []
        for beat in measure {
            var newBeat : ([(length: Int, beams: Int, noteType: Int, tied: Bool, dotted: Bool)], units: Int) = ([], beat.units)
            for note in beat.0 {
                var beamSubtrahends : [Int] = []
                
                // as it turns out, the behavior of beaming in musical notation behaves an awful lot like binary.
                let reverseBinaryLength = String(note.length, radix: 2).characters.reverse()
                
                for i in 0...(reverseBinaryLength.count - 1) {
                    if Array(reverseBinaryLength)[i] == "1" {
                        beamSubtrahends.append(i)
                    }
                }
                beamSubtrahends = beamSubtrahends.reverse()
                
                var isDotted : [Bool]  = []
                if passiveDisplay.skillLevel >= 2.0 {
                    var previousSubtrahend = 0
                
                    for i in 0...(beamSubtrahends.count - 1) {
                        let subtrahend = beamSubtrahends[i]
                        if subtrahend + 1 == previousSubtrahend {
                            isDotted.removeLast()
                            isDotted.append(true)
                            beamSubtrahends.removeAtIndex(i)
                        } else {
                            isDotted.append(false)
                            previousSubtrahend = subtrahend
                        }
                    }
                } else {
                    for _ in 0...(beamSubtrahends.count - 1) {
                        isDotted.append(false)
                    }
                }
                
                
                // the changed notes update their length variables here.
                for i in 0...(isDotted.count - 1) {
                    let beams = beat.beams - beamSubtrahends[i]
                    var tied : Bool
                    if i == (isDotted.count - 1) {
                        tied = note.tied
                    } else {
                        tied = true
                    }
                    let dotted = isDotted[i]
                    let length = Int(Double(pow(2.0, Double(beat.beams - beams))) * ((isDotted[i]) ? 1.5 : 1))
                    newBeat.0.append((length: length, beams: beams, noteType: note.noteType, tied: tied, dotted: dotted))
                }
                
            }
            newMeasure.append(newBeat)
        }
        displayBeamsAndDots.append(newMeasure)
    }
    
    /* This would handle what the previous set of loops could not, redescribing notes that extend across multiple beats. This is not finished yet, and is why you didn't see things like dotted quarter notes (in duple meters) or half notes in our last meeting.
    var displayProperties : [[([(length: Int, beams: Int, noteType: Int, tied: Bool, dotted: Bool)], units: Int)]] = []

    measureIndex = 0
    for measure in displayBeamsAndDots {
        var newMeasure : [([(length: Int, beams: Int, noteType: Int, tied: Bool, dotted: Bool)], units: Int)]
        var beatIndex = 0
        for beat in measure {
            
            var numberOfGoodBeats = 0
            var beatDoesChange = true
            
            if let lastNoteBeforeBeat = displayBeamsAndDots[measureIndex][beatIndex - 1].0.last {
                
                if !(lastNoteBeforeBeat.tied) {
                    var beatMeetsConditions = true
                    while beatMeetsConditions {
                        let beatAtI = displayBeamsAndDots[measureIndex][beatIndex + numberOfGoodBeats]
                        
                        var sumOfLengthsInBeatAtI = 0
                        for note in beatAtI.0 {
                            sumOfLengthsInBeatAtI += note.length
                        }
                        
                        if beatAtI.units == beat.units && beatAtI.0[0].noteType == beat.0[0].noteType && sumOfLengthsInBeatAtI == beat.0[0].length {
                            if beatAtI.0.count == 1 && beatAtI.0[0].tied == true {
                                beatMeetsConditions = true
                            } else {
                                beatMeetsConditions = false
                            }
                            numberOfGoodBeats += 1
                        } else {
                            beatMeetsConditions = false
                        }
                    }
                    
                    var sumOfLengthsAcrossBeats = 0
                    for i in 0...(numberOfGoodBeats - 1) {
                        sumOfLengthsAcrossBeats += displayBeamsAndDots[measureIndex][beatIndex + i].0[0].length
                    }
                    
                    let halfBeat = Double(beat.0[0].length) / 2.0
                    let halfBeatBeams = 1
                    
                    var sumOfHalfBeats = Double(sumOfLengthsAcrossBeats) / halfBeat
                    
                    if sumOfHalfBeats % 1 != 0 {
                        sumOfHalfBeats = roundDown(sumOfHalfBeats / 2) * 2
                        numberOfGoodBeats -= 1
                    }
                    
                    let reverseBinaryOfSum = String(Int(sumOfHalfBeats), radix: 2).characters.reverse()
                    var newBeams : [Int] = []
                    
                    for i in 0...(reverseBinaryOfSum.count - 1) {
                        if Array(reverseBinaryOfSum)[i] == "1" {
                            newBeams.append(halfBeatBeams - i)
                        }
                    }
                    
                    newBeams = newBeams.reverse()
                    
                    var previousBeam = newBeams[0]
                    var isNowDotted : [Bool] = []
                    
                    for beam in newBeams {
                        if passiveDisplay.skillLevel >= 2.0 {
                            if previousBeam == (beam - 1) {
                                isNowDotted.removeLast()
                                isNowDotted.append(true)
                            }
                            isNowDotted.append(false)
                        }
                        
                        
                    }
                    
                    var i = 0
                    for beam in newBeams {
                        let oldBeat = displayBeamsAndDots[measureIndex][beatIndex + i]
                        var newBeat = ([(length: oldBeat.0[0].length, beams: beam, noteType: oldBeat.0[0].noteType, false, (isNowDotted[i] && !(oldBeat.0[0].dotted)) ? true : oldBeat.0[0].dotted )], units: oldBeat.units)
                        
                        var lengthInHalfBeats = 0
                        switch beam {
                        case -2:
                            lengthInHalfBeats = 8
                        case -1:
                            lengthInHalfBeats = 4
                        case 0:
                            lengthInHalfBeats = 2
                        case 1:
                            lengthInHalfBeats = 1
                        default:
                            break
                        }
                        
                        var newNote : [(length: Int, beams: Int, noteType: Int, tied: Bool, dotted: Bool)] = []
                        
                        for i2 in 1...lengthInHalfBeats {
                            if i2 == 1 {
                                
                            } else if i2 % 2 == 1 {
                            
                            } else if i2 == lengthInHalfBeats {
                                var noteIndex = 0
                                for note in oldBeat.0 {
                                }
                                
                                
                            }
                        }
                        
                        i += 1
                    }
                    
                    
                }
            }
            beatIndex += 1
        }
        measureIndex += 1
    }
    */
    
    return displayBeamsAndDots // The next bit of functionality for displaying is in ViewController
}











