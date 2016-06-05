//
//  Generation.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/4/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation

func createGenerationLists() -> (primaryList : [SkillSet], subList : [SubDivisionSkill], timeList : [TimeSignatureSkill], mixList : [MixtureSkill], mixSubList: [SourceMix], mixTimeList: [SourceMix]) {
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
    for skillSet in unlockedList {
        if skillSet.skillLevel >= 1 {
            basicMasteredList.append(skillSet)
        }
    }
    for skillSet in unlockedList{
        if (skillSet.skillLevel * 10) % 10 == intensity * 10 {
            intensityMatchList.append(skillSet)
        }
    }
    
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
        if !skillSet.listAvailableSources(basicMasteredList, basicMasteredList: basicMasteredList).isEmpty {
            mixList.append(skillSet)
            if (skillSet.skillLevel * 10) % 10 == intensity * 10 {
                primaryList.append(skillSet)
            }
        }
    }
    
    if !mixList.contains(subMixture) {
        if let index = primaryList.indexOf(complexSigs) { primaryList.removeAtIndex(index) }
        if let index = timeList.indexOf(complexSigs) { timeList.removeAtIndex(index) }
    }
    
    return (primaryList, subList, timeList, mixList, subMixture.listAvailableSources(subList, basicMasteredList: timeList), timeMixture.listAvailableSources(timeList, basicMasteredList: subList))
}


func generationProperties() -> (primarySkill: SkillSet, mixtureBool: (Bool, Bool), primarySubSkill: (SubDivisionSkill, Int, Bool), secondarySubSkill: (SubDivisionSkill, Int, Bool), timeSignatureSkill: (TimeSignatureSkill, Int, Bool), mixedTimeSignatureSkill: (Bool, TimeSignatureSkill, Int, Bool), mixedTimeSubSkill: (SubDivisionSkill, Int, Bool)) {
    var lists = createGenerationLists()
    
    while lists.primaryList.isEmpty {
        intensity += 0.1
        if intensity >= 1.0 {
            intensity = 0.0
        }
        lists = createGenerationLists()
    }
    
    var exercisePrimarySubSkill : (SubDivisionSkill, Int, Bool) = (quarterNotes, 0, true)
    var exerciseSecondarySubSkill : (SubDivisionSkill, Int, Bool) = (quarterNotes, 0, true)
    var exerciseTimeSignature : (TimeSignatureSkill, Int, Bool) = (dupleSigs, 0, true)
    var exerciseMixedTimeSignature : (Bool, TimeSignatureSkill, Int, Bool) = (false, dupleSigs, 0, true)
    var exerciseMixedTimeSubSkill : (SubDivisionSkill, Int, Bool) = (quarterNotes, 0, true)
    
    let primarySkill = lists.primaryList.randomItem()
    
    var mixtureBool = (false, false)
    mixtureBool.0 = (lists.mixList.contains(subMixture)) ? Bool(random(2)) : false
    if primarySkill == complexSigs { mixtureBool.0 = true }
    mixtureBool.1 = (lists.mixList.contains(timeMixture) && !(primarySkill is TimeSignatureSkill) && !(mixtureBool.0)) ? Bool(random(2)) : false
    exerciseMixedTimeSignature.0 = mixtureBool.1
    
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
        
        exerciseTimeSignature.0 = ((getSkillSetFromName(exerciseSecondarySubSkill.0.compatibleTimeSigs) as! [TimeSignatureSkill]).intersection(lists.timeList)).randomItem()
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
        
        exerciseSecondarySubSkill.0 = (getSkillSetFromName(exerciseTimeSignature.0.compatibleSubDivs) as! [SubDivisionSkill]).intersection(lists.subList).randomItem()
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
            
            let mixSources = (lists.mixSubList).randomItem().getSubSkills()
            
            exercisePrimarySubSkill = (mixSources.primary, Int(roundDown(mixSources.primary.skillLevel)), true)
            exerciseSecondarySubSkill = (mixSources.secondary, Int(roundDown(mixSources.secondary.skillLevel)), true)
            
            exerciseTimeSignature.0 = (getSkillSetFromName(mixSources.secondary.compatibleTimeSigs) as! [TimeSignatureSkill]).intersection(lists.timeList).randomItem()
            exerciseTimeSignature.1 = Int(roundDown(exerciseTimeSignature.0.skillLevel))
            exerciseMixedTimeSignature.0 = false
            
        } else {
            mixtureBool = (false, true)
            
            let mixSources = (lists.mixTimeList).randomItem().getTimeSkills()
            
            exerciseTimeSignature = (mixSources.primary, Int(roundDown(mixSources.primary.skillLevel)), true)
            exerciseMixedTimeSignature = (true, mixSources.secondary, Int(roundDown(mixSources.secondary.skillLevel)), true)
            
            exercisePrimarySubSkill.0 = (getSkillSetFromName(mixSources.primary.compatibleSubDivs) as! [SubDivisionSkill]).intersection(lists.subList).randomItem()
            exercisePrimarySubSkill.1 = Int(roundDown(exerciseSecondarySubSkill.0.skillLevel))
            exerciseSecondarySubSkill = exercisePrimarySubSkill
            exerciseSecondarySubSkill.1 -= 1
        }
    default:
        break
    }
    
    if mixtureBool.0 == false && exerciseTimeSignature.0 == complexSigs {
        mixtureBool.0 = true
        let mixSource = lists.mixSubList.randomItem().getSubSkills()
        exercisePrimarySubSkill = (mixSource.primary, Int(roundDown(mixSource.primary.skillLevel)), true)
        exercisePrimarySubSkill = (mixSource.secondary, Int(roundDown(mixSource.secondary.skillLevel)), true)
    }
    
    exerciseMixedTimeSubSkill.0 = (getSkillSetFromName(exerciseMixedTimeSignature.1.compatibleSubDivs) as! [SubDivisionSkill]).intersection(lists.subList).randomItem()
    exerciseMixedTimeSubSkill.1 = Int(roundDown(exerciseMixedTimeSubSkill.0.skillLevel))
    
    return (primarySkill, mixtureBool, exercisePrimarySubSkill, exerciseSecondarySubSkill, exerciseTimeSignature, exerciseMixedTimeSignature, exerciseMixedTimeSubSkill)
}


internal func generateExercise() -> [[(String, Int)]] {
    let properties = generationProperties()
    
    var timeSignature : (String, String) = ("", "")
    timeSignature.0 = properties.timeSignatureSkill.0.selectSource(properties.timeSignatureSkill.1, andUnder: properties.timeSignatureSkill.2)!
    timeSignature.1 = (properties.mixedTimeSignatureSkill.0) ?  properties.mixedTimeSignatureSkill.1.selectSource(properties.mixedTimeSignatureSkill.2, andUnder: properties.mixedTimeSignatureSkill.3)! : timeSignature.0
    
    var measureInfo : [(Int, Int)] = []
    
    func numberOfBeatsInTimeSig(timeSig: String, timeType: Int) -> Int {
        var returnedInt = 0
        switch timeType {
        case 1:
            for character in Array(timeSig.characters) {
                if character == "2" || character == "3" {
                    returnedInt += 1
                }
            }
        case 2:
            returnedInt = Int(String(timeSig.characters.prefix(1)))!
        case 3:
            returnedInt = Int(String(timeSig.characters.prefix(Int(timeSig.startIndex.distanceTo(timeSig.characters.indexOf("/")!)))))! / 3
        default:
            break
        }
        return returnedInt
    }
    
    for i in 0...3 {
        if i % 2 == 1 && properties.mixedTimeSignatureSkill.0 {
            let timeType = properties.mixedTimeSignatureSkill.1.timeType
            measureInfo.append((numberOfBeatsInTimeSig(timeSignature.1, timeType: timeType), timeType))
        } else {
            let timeType = properties.timeSignatureSkill.0.timeType
            measureInfo.append((numberOfBeatsInTimeSig(timeSignature.0, timeType: timeType), timeType))
            
        }
    }
    
    var exerciseBeatSkills : [[(SubDivisionSkill, Int, Bool)]] = []
    
    var measureIndex = 0
    for measure in measureInfo {
        var measureBeatSkills : [(SubDivisionSkill, Int, Bool)] = []
        if measure.1 == 1 {
            let primaryIs3 = properties.primarySubSkill.0.compatibleTimeSigs[0] == "b.3"
            for character in timeSignature.0.characters {
                if character == "2" { measureBeatSkills.append((primaryIs3) ? properties.secondarySubSkill : properties.primarySubSkill) }
                if character == "3" { measureBeatSkills.append((primaryIs3) ? properties.primarySubSkill : properties.secondarySubSkill)}
            }
        } else {
            if properties.mixedTimeSignatureSkill.0 && measureIndex % 2 == 1 {
                for _ in 1...(measure.0) {
                    measureBeatSkills.append(properties.mixedTimeSubSkill)
                }
            } else {
                let primaryIndex = random(measure.0) + 1
                for index in 1...(measure.0) {
                    if index == primaryIndex {
                        measureBeatSkills.append(properties.primarySubSkill)
                    } else {
                        measureBeatSkills.append(properties.secondarySubSkill)
                    }
                }
            }
        }
        measureIndex += 1
        exerciseBeatSkills.append(measureBeatSkills)
    }
    
    var generatedExercise : [[(String, Int)]] = []
    measureIndex = 0
    
    for measure in exerciseBeatSkills {
        var generatedMeasure : [(String, Int)] = []
        for beat in measure {
            var generatedBeat : (String, Int) = ("", 0)
            generatedBeat.0 = beat.0.selectSource(beat.1, andUnder: beat.2)!
            generatedBeat.1 = (measureInfo[measureIndex].1 == 1) ? (getSkillSetFromName(beat.0.compatibleTimeSigs[0]) as! TimeSignatureSkill).timeType : measureInfo[measureIndex].1
            generatedMeasure.append(generatedBeat)
        }
        generatedExercise.append(generatedMeasure)
        measureIndex += 1
    }
    
    return generatedExercise
    
}
