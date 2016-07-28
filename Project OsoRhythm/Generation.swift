//
//  Generation.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/4/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation


func pickLeastPlayed(list: [SkillSet]) -> SkillSet {
    
    var leastPlayedList = [(plays: list.first!.plays, index: 0)]
    
    for i in 0...(list.count - 1) {
        if list[i].plays < leastPlayedList.first!.plays {
            leastPlayedList.removeAll()
            leastPlayedList.append((plays: list[i].plays, i))
        }
        if list[i].plays == leastPlayedList.first!.plays {
            leastPlayedList.append((plays: list[i].plays, i))
        }
    }
    
    return list[leastPlayedList.randomItem().index]
}

// This function creates several lists of SkillSet instances that can be used for generation. It does so in such a way that should dodge bugs and compatibility errors in later functions.
func createGenerationLists() -> (primaryList : [SkillSet], basicMasteredList : [SkillSet], mixList : [MixtureSkill], mixSubList: [SourceMix], mixTimeList: [SourceMix], mixSubListAsPrimary: [SourceMix], mixTimeListAsPrimary: [SourceMix]) {
    var unlockedList : [SkillSet] = []
    var basicMasteredList : [SkillSet] = []
    var intensityMatchList : [SkillSet] = []
    var primaryList : [SkillSet] = []
    var subList : [SubDivisionSkill] = []
    var timeList : [TimeSignatureSkill] = []
    var mixList : [MixtureSkill] = []
    
    for skillSet in skillSetList {
        if !skillSet.locked {
            unlockedList.append(skillSet)
        }
    }
    
    // Basic mastered list is all of the skills that the user has passed the first level of. Since the user is more comfortable with these, these will "fill in the blanks" around the primarySkill explained below.
    for skillSet in unlockedList {
        if skillSet.skillLevel >= 1.0 {
            basicMasteredList.append(skillSet)
        }
    }
    for skillSet in unlockedList{
        if (skillSet.skillLevel * 10) % 10 == intensity * 10 {
            intensityMatchList.append(skillSet)
        }
    }
    
    // Every exercise has a primary skill that it tests the user on. The primary skill does not need to be "basic mastered".
    for skillSet in intensityMatchList {
        switch skillSet {
        case is SubDivisionSkill:
            if !getSkillSetFromName((skillSet as! SubDivisionSkill).compatibleTimeSigs).intersection(basicMasteredList).isEmpty {
                primaryList.append(skillSet)
            }
        case is TimeSignatureSkill:
            if !getSkillSetFromName((skillSet as! TimeSignatureSkill).compatibleSubDivs).intersection(basicMasteredList).isEmpty {
                primaryList.append(skillSet)
            }
        default :
            break
        }
    }
    
    for skillSet in basicMasteredList {
        switch skillSet {
        case is SubDivisionSkill :
            let skillSetSub = (skillSet as! SubDivisionSkill)
            if !getSkillSetFromName(skillSetSub.compatibleTimeSigs).intersection(basicMasteredList).isEmpty {
                subList.append(skillSetSub)
            }
        case is TimeSignatureSkill:
            let skillSetTime = (skillSet as! TimeSignatureSkill)
            if !getSkillSetFromName(skillSetTime.compatibleSubDivs).intersection(basicMasteredList).isEmpty {
                timeList.append(skillSetTime)
            }
        default :
            break
        }
    }
    
    
    for skillSet in (basicMasteredList.intersection(skillSetListMix) as! [MixtureSkill]) {
        if !skillSet.listAvailableSources(basicMasteredList, basicMasteredList: basicMasteredList, asPrimary: false).isEmpty {
            mixList.append(skillSet)
        }
    }
    
    for skillSet in (intensityMatchList.intersection(skillSetListMix) as! [MixtureSkill]) {
        if !skillSet.listAvailableSources(basicMasteredList, basicMasteredList: basicMasteredList, asPrimary: true).isEmpty {
            primaryList.append(skillSet)
        }
    }
    
    
    // Complex signatures need to have subMixture available
    if !mixList.contains(subMixture) {
        if let index = primaryList.indexOf(complexSigs) { primaryList.removeAtIndex(index) }
        if let index = timeList.indexOf(complexSigs) { timeList.removeAtIndex(index) }
    }
    
    return (primaryList, basicMasteredList, mixList, subMixture.listAvailableSources(subList, basicMasteredList: timeList, asPrimary: false), timeMixture.listAvailableSources(timeList, basicMasteredList: subList, asPrimary: false), subMixture.listAvailableSources(basicMasteredList, basicMasteredList: basicMasteredList, asPrimary: true), timeMixture.listAvailableSources(basicMasteredList, basicMasteredList: basicMasteredList, asPrimary: true))
}

struct ExerciseProperties {
    var primarySkill: SkillSet
    var mixtureBool: (Bool, Bool)
    var primarySubSkill: (SubDivisionSkill, Int, Bool)
    var secondarySubSkill: (SubDivisionSkill, Int, Bool)
    var timeSignatureSkill: (TimeSignatureSkill, Int, Bool)
    var mixedTimeSignatureSkill: (Bool, TimeSignatureSkill, Int, Bool)
    var mixedTimeSubSkill: (SubDivisionSkill, Int, Bool)
    
    
    init(primarySkill: SkillSet, mixtureBool: (Bool, Bool), primarySubSkill: (SubDivisionSkill, Int, Bool), secondarySubSkill: (SubDivisionSkill, Int, Bool), timeSignatureSkill: (TimeSignatureSkill, Int, Bool), mixedTimeSignatureSkill: (Bool, TimeSignatureSkill, Int, Bool), mixedTimeSubSkill: (SubDivisionSkill, Int, Bool)) {
        self.primarySkill = primarySkill
        self.mixtureBool = mixtureBool
        self.primarySubSkill = primarySubSkill
        self.secondarySubSkill = secondarySubSkill
        self.timeSignatureSkill = timeSignatureSkill
        self.mixedTimeSignatureSkill = mixedTimeSignatureSkill
        self.mixedTimeSubSkill = mixedTimeSubSkill
    }
}

internal var exerciseProperties : ExerciseProperties?

// Selects items from the lists created above that will be the subjects/properties/information needed for exercise generation
func generationProperties() -> (primarySkill: SkillSet, mixtureBool: (Bool, Bool), primarySubSkill: (SubDivisionSkill, Int, Bool), secondarySubSkill: (SubDivisionSkill, Int, Bool), timeSignatureSkill: (TimeSignatureSkill, Int, Bool), mixedTimeSignatureSkill: (Bool, TimeSignatureSkill, Int, Bool), mixedTimeSubSkill: (SubDivisionSkill, Int, Bool)) {
    var lists = createGenerationLists()
    
    while lists.primaryList.isEmpty {
        intensity -= 0.1
        intensity = round(intensity * 10) / 10
        print(intensity)
        if intensity < 0.0 {
            intensity = 0.9
        }
        lists = createGenerationLists()
    }
    
    var exercisePrimarySubSkill : (SubDivisionSkill, Int, Bool) = (quarterNotes, 0, true)
    var exerciseSecondarySubSkill : (SubDivisionSkill, Int, Bool) = (quarterNotes, 0, true)
    var exerciseTimeSignature : (TimeSignatureSkill, Int, Bool) = (dupleSigs, 0, true)
    var exerciseMixedTimeSignature : (Bool, TimeSignatureSkill, Int, Bool) = (false, dupleSigs, 0, true)
    var exerciseMixedTimeSubSkill : (SubDivisionSkill, Int, Bool) = (quarterNotes, 0, true)
    
    let primarySkill = pickLeastPlayed(lists.primaryList)
    
    primarySkill.plays += 1
    
    print("Primary Skill: \(primarySkill.name)")
    
    
    var subList : [SubDivisionSkill] = []
    var timeList : [TimeSignatureSkill] = []
    
    var primaryInclusiveMasteredList = lists.basicMasteredList
    if !(primaryInclusiveMasteredList.contains(primarySkill)) { primaryInclusiveMasteredList.append(primarySkill) }
    
    for skillSet in primaryInclusiveMasteredList {
        switch skillSet {
        case is SubDivisionSkill :
            let skillSetSub = (skillSet as! SubDivisionSkill)
            if !getSkillSetFromName(skillSetSub.compatibleTimeSigs).intersection(primaryInclusiveMasteredList).isEmpty {
                subList.append(skillSetSub)
            }
        case is TimeSignatureSkill:
            let skillSetTime = (skillSet as! TimeSignatureSkill)
            if !getSkillSetFromName(skillSetTime.compatibleSubDivs).intersection(primaryInclusiveMasteredList).isEmpty {
                timeList.append(skillSetTime)
            }
        default :
            break
        }
    }
    
    
    var mixtureBool = (false, false)
    mixtureBool.0 = (lists.mixList.contains(subMixture)) ? Bool(random(2)) : false
    if primarySkill == complexSigs { mixtureBool.0 = true }
    mixtureBool.1 = (lists.mixList.contains(timeMixture) && !(primarySkill is TimeSignatureSkill) && !(mixtureBool.0)) ? Bool(random(2)) : false
    exerciseMixedTimeSignature.0 = mixtureBool.1
    
    // All of the other properties (with few exceptions) are chosen based on the primarySkill selected above
    switch primarySkill {
    case is SubDivisionSkill:
        
        exercisePrimarySubSkill = (primarySkill as! SubDivisionSkill, Int(roundDown(primarySkill.skillLevel + 1)), false)
        
        var mixSourceList : [SourceMix] = []
        
        for item in lists.mixSubList {
            if exercisePrimarySubSkill.0 == item.getSubSkills().primary {
                mixSourceList.append(item)
            }
        }
        
        if mixSourceList.isEmpty { mixtureBool.0 = false }
        
        if mixtureBool.0 {
            exerciseSecondarySubSkill.0 = getSubSkillSetFromDivision(mixSourceList.randomItem().secondary)
            exerciseSecondarySubSkill.1 = Int(roundDown(exerciseSecondarySubSkill.0.skillLevel))
        } else {
            exerciseSecondarySubSkill = (exercisePrimarySubSkill.0, Int(roundDown(primarySkill.skillLevel)), true)
        }
        
        exerciseTimeSignature.0 = ((getSkillSetFromName(exerciseSecondarySubSkill.0.compatibleTimeSigs) as! [TimeSignatureSkill]).intersection(timeList)).randomItem()
        exerciseTimeSignature.1 = Int(roundDown(exerciseTimeSignature.0.skillLevel))
        
        mixSourceList = []
        
        for item in lists.mixTimeList {
            if exerciseTimeSignature.0 == item.getTimeSkills().primary {
                mixSourceList.append(item)
            }
        }
        
        if mixSourceList.isEmpty {mixtureBool.1 = false }
        
        if mixtureBool.1 {
            exerciseMixedTimeSignature.0 = true
            exerciseMixedTimeSignature.1 = getTimeSkillSetFromType(mixSourceList.randomItem().secondary)
            exerciseMixedTimeSignature.2 = Int(roundDown(exerciseMixedTimeSignature.1.skillLevel))
        } else {
            exerciseMixedTimeSignature.0 = false
        }
        
        
    case is TimeSignatureSkill:
        
        exerciseTimeSignature = (primarySkill as! TimeSignatureSkill, Int(roundDown(primarySkill.skillLevel + 1)), false)
        
        exerciseSecondarySubSkill.0 = (getSkillSetFromName(exerciseTimeSignature.0.compatibleSubDivs) as! [SubDivisionSkill]).intersection(subList).randomItem()
        exerciseSecondarySubSkill.1 = Int(roundDown(exerciseSecondarySubSkill.0.skillLevel))
        
        var mixSourceList : [SourceMix] = []
        
        for item in lists.mixTimeList {
            if exerciseTimeSignature.0 == item.getTimeSkills().primary {
                mixSourceList.append(item)
            }
        }
        
        if mixSourceList.isEmpty { mixtureBool.1 = false }
        
        if mixtureBool.1 {
            exerciseMixedTimeSignature.0 = true
            exerciseMixedTimeSignature.1 = getTimeSkillSetFromType(mixSourceList.randomItem().secondary)
            exerciseMixedTimeSignature.2 = Int(roundDown(exerciseMixedTimeSignature.1.skillLevel))
        } else {
            exerciseMixedTimeSignature.0 = false
        }
        
        mixSourceList = []
        
        for item in lists.mixSubList {
            if exerciseSecondarySubSkill.0 == item.getSubSkills().secondary {
                mixSourceList.append(item)
            }
        }
        
        if mixSourceList.isEmpty { mixtureBool.0 = false }
        
        if mixtureBool.0 {
            exercisePrimarySubSkill.0 = getSubSkillSetFromDivision(mixSourceList.randomItem().primary)
            exercisePrimarySubSkill.1 = Int(roundDown(exercisePrimarySubSkill.0.skillLevel))
        } else {
            exercisePrimarySubSkill = (exerciseSecondarySubSkill.0, Int(roundDown(exerciseSecondarySubSkill.0.skillLevel)), true)
            exerciseSecondarySubSkill.0 = exercisePrimarySubSkill.0
            exerciseSecondarySubSkill.1 = (exercisePrimarySubSkill.1 - 1 == 0) ? 1 : exercisePrimarySubSkill.1 - 1
        }
        
    case is MixtureSkill:
        if (primarySkill as! MixtureSkill).mixType == 0 {
            mixtureBool = (true, false)
            
            let mixSources = (lists.mixSubListAsPrimary).randomItem().getSubSkills()
            
            exercisePrimarySubSkill = (mixSources.primary, Int(roundDown(mixSources.primary.skillLevel)), true)
            exerciseSecondarySubSkill = (mixSources.secondary, Int(roundDown(mixSources.secondary.skillLevel)), true)
            
            exerciseTimeSignature.0 = (getSkillSetFromName(mixSources.secondary.compatibleTimeSigs) as! [TimeSignatureSkill]).intersection(timeList).randomItem()
            exerciseTimeSignature.1 = Int(roundDown(exerciseTimeSignature.0.skillLevel))
            exerciseMixedTimeSignature.0 = false
            
        } else {
            mixtureBool = (false, true)
            
            let mixSources = (lists.mixTimeListAsPrimary).randomItem().getTimeSkills()
            
            exerciseTimeSignature = (mixSources.primary, Int(roundDown(mixSources.primary.skillLevel)), true)
            exerciseMixedTimeSignature = (true, mixSources.secondary, Int(roundDown(mixSources.secondary.skillLevel)), true)
            
            exercisePrimarySubSkill.0 = (getSkillSetFromName(mixSources.primary.compatibleSubDivs) as! [SubDivisionSkill]).intersection(subList).randomItem()
            exercisePrimarySubSkill.1 = Int(roundDown(exerciseSecondarySubSkill.0.skillLevel))
            exerciseSecondarySubSkill = exercisePrimarySubSkill
            exerciseSecondarySubSkill.1 -= 1
        }
    default:
        break
    }
    
    //Complex time signatures require mixed subdivisions (one duple and one triple), which is handled here
    if mixtureBool.0 == false && exerciseTimeSignature.0 == complexSigs {
        mixtureBool.0 = true
        let mixSource = lists.mixSubList.randomItem().getSubSkills()
        exercisePrimarySubSkill = (mixSource.primary, Int(roundDown(mixSource.primary.skillLevel)), true)
        exercisePrimarySubSkill = (mixSource.secondary, Int(roundDown(mixSource.secondary.skillLevel)), true)
    }
    
    //Mixed time signatures require a third Subdivision skill, so that the mixed measures will always have a compatible skill to work with
    exerciseMixedTimeSubSkill.0 = (getSkillSetFromName(exerciseMixedTimeSignature.1.compatibleSubDivs) as! [SubDivisionSkill]).intersection(subList).randomItem()
    exerciseMixedTimeSubSkill.1 = Int(roundDown(exerciseMixedTimeSubSkill.0.skillLevel))
    
    exerciseProperties = ExerciseProperties(primarySkill: primarySkill, mixtureBool: mixtureBool, primarySubSkill: exercisePrimarySubSkill, secondarySubSkill: exerciseSecondarySubSkill, timeSignatureSkill: exerciseTimeSignature, mixedTimeSignatureSkill: exerciseMixedTimeSignature, mixedTimeSubSkill: exerciseMixedTimeSubSkill)
    
    return (primarySkill, mixtureBool, exercisePrimarySubSkill, exerciseSecondarySubSkill, exerciseTimeSignature, exerciseMixedTimeSignature, exerciseMixedTimeSubSkill)
}




// Takes the properties chosen above and creates an exercise.
internal func generateExercise() -> (exercise: [[(String, Int)]], timeSignature: (String, String), primaryBeats: [[Bool]], primarySkill: SkillSet) {
    let properties = generationProperties()
    
    var timeSignature : (String, String) = ("", "")
    timeSignature.0 = properties.timeSignatureSkill.0.selectSource(properties.timeSignatureSkill.1, andUnder: properties.timeSignatureSkill.2)!
    timeSignature.1 = (properties.mixedTimeSignatureSkill.0) ?  properties.mixedTimeSignatureSkill.1.selectSource(properties.mixedTimeSignatureSkill.2, andUnder: properties.mixedTimeSignatureSkill.3)! : timeSignature.0
    
    var measureInfo : [(Int, Int)] = []
    
    func numberOfBeatsInTimeSig(timeSig: String, timeType: Int) -> (Int, timeSig: String) {
        var returnedInt = 0
        var numberOf8s = 0
        var returnedTimeSig = ""
        switch timeType { // Complex signatures come in a different format than duple and triple signatures, and are "translated" here
        case 1:
            for character in Array(timeSig.characters) {
                if character == "2" || character == "3" {
                    returnedInt += 1
                    numberOf8s += Int(String(character))!
                }
            }
            
        case 2:
            returnedInt = Int(String(timeSig.characters.prefix(1)))!
            returnedTimeSig = timeSig
        case 3:
            returnedInt = Int(String(timeSig.characters.prefix(Int(timeSig.startIndex.distanceTo(timeSig.characters.indexOf("/")!)))))! / 3
            returnedTimeSig = timeSig
        default:
            break
        }
        if numberOf8s >= 1 {
            returnedTimeSig = "\(numberOf8s)/8"
        }
        
        return (returnedInt, returnedTimeSig)
    }
    
    var returnedTimeSig = ("", "")
    
    for i in 0...3 { // Mixed time signatures occur on odd measure numbers
        if i % 2 == 1 && properties.mixedTimeSignatureSkill.0 {
            let timeType = properties.mixedTimeSignatureSkill.1.timeType
            let numberOfBeats = numberOfBeatsInTimeSig(timeSignature.1, timeType: timeType)
            measureInfo.append((numberOfBeats.0, timeType))
            returnedTimeSig.1 = numberOfBeats.timeSig
        } else {
            let timeType = properties.timeSignatureSkill.0.timeType
            let numberOfBeats = numberOfBeatsInTimeSig(timeSignature.0, timeType: timeType)
            measureInfo.append((numberOfBeats.0, timeType))
            returnedTimeSig = (numberOfBeats.timeSig, numberOfBeats.timeSig)
        }
    }
    
    var exerciseBeatSkills : [[(SubDivisionSkill, Int, Bool)]] = []
    var exerciseBeatIsPrimary : [[Bool]] = []
    
    var measureIndex = 0
    for measure in measureInfo {
        var measureBeatSkills : [(SubDivisionSkill, Int, Bool)] = []
        var measureBeatIsPrimary : [Bool] = []
        if measure.1 == 1 { // Complex time signatures are formatted so that which beats are duple and which are triple are predetermined.
            let primaryIs3 = properties.primarySubSkill.0.compatibleTimeSigs[0] == "b.3"
            for character in timeSignature.0.characters {
                if character == "2" {
                    if primaryIs3 {
                        measureBeatSkills.append(properties.secondarySubSkill)
                        measureBeatIsPrimary.append(false)
                    } else {
                        measureBeatSkills.append(properties.primarySubSkill)
                        measureBeatIsPrimary.append(true)
                    }
                }
                
                if character == "3" {
                    if primaryIs3 {
                        measureBeatSkills.append(properties.primarySubSkill)
                        measureBeatIsPrimary.append(true)
                    } else {
                        measureBeatSkills.append(properties.secondarySubSkill)
                        measureBeatIsPrimary.append(false)
                    }
                }
            }
        } else {
            if properties.mixedTimeSignatureSkill.0 && measureIndex % 2 == 1 {
                for _ in 1...(measure.0) {
                    measureBeatSkills.append(properties.mixedTimeSubSkill)
                    measureBeatIsPrimary.append(false)
                }
            } else {
                let primaryIndex = random(measure.0) + 1
                for index in 1...(measure.0) {
                    if index == primaryIndex {
                        measureBeatSkills.append(properties.primarySubSkill)
                        measureBeatIsPrimary.append(true)
                    } else {
                        measureBeatSkills.append(properties.secondarySubSkill)
                        measureBeatIsPrimary.append(false)
                    }
                }
            }
        }
        measureIndex += 1
        exerciseBeatSkills.append(measureBeatSkills)
        exerciseBeatIsPrimary.append(measureBeatIsPrimary)
    }
    
    var generatedExercise : [[(String, Int)]] = []
    measureIndex = 0
    
    for measure in exerciseBeatSkills {
        var generatedMeasure : [(String, Int)] = []
        for beat in measure {
            var generatedBeat : (String, Int) = ("", 0)
            generatedBeat.0 = beat.0.selectSource(beat.1, andUnder: beat.2, isPrimary: beat.2)! // the source selected from the skill instance will be one above the current skillLevel of the user if it is the primary skill, and if not it will be selected from the highest level passed "andUnder".
            generatedBeat.1 = (measureInfo[measureIndex].1 == 1) ? (getSkillSetFromName(beat.0.compatibleTimeSigs[0]) as! TimeSignatureSkill).timeType : measureInfo[measureIndex].1
            generatedMeasure.append(generatedBeat)
        }
        generatedExercise.append(generatedMeasure)
        measureIndex += 1
    }
    
    return (generatedExercise, returnedTimeSig, exerciseBeatIsPrimary, properties.primarySkill)
    
}
