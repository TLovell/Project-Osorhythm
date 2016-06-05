//
//  SkillSet.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/4/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation

internal struct SourceMix {
    var primary = 0
    var secondary = 0
    
    init(primary: Int, secondary: Int) {
        self.primary = primary
        self.secondary = secondary
    }
}

internal class SkillSet {
    var name = "No Name"
    var technicalName = "No Technical Name"
    var type = 0
    var skillLevel = 0.0
    var locked = false
    var uses = 1
    
    
    
    init() {}
}

extension SkillSet: Equatable {}

internal func ==(lhs: SkillSet, rhs: SkillSet) -> Bool {
    return lhs.name == rhs.name
}


internal class SubDivisionSkill: SkillSet {
    var sources: [[String]] = []
    var division = 0
    var compatibleTimeSigs : [String] = []
    
    init(name: String, technicalName: String, division: Int, sources: [[String]], compatibleTimeSigs: [String], skillLevel: Double) {
        super.init()
        self.name = name
        self.technicalName = technicalName
        self.division = division
        self.sources = sources
        self.compatibleTimeSigs = compatibleTimeSigs
        self.skillLevel = skillLevel
        self.type = 0
    }
    
    init(skillSet: SkillSet) {
        
    }
    
    func selectSource(level: Int, andUnder: Bool) -> String? {
        var sourceIndex: Int = andUnder ? random(level) : level
        
        while sourceIndex >= self.sources.count {
            sourceIndex -= 1
        }
        
        return self.sources[sourceIndex][random(self.sources[sourceIndex].count)]
    }
}

internal class TimeSignatureSkill: SkillSet {
    var sources: [[String]] = []
    var compatibleSubDivs : [String] = []
    var timeType = 0
    
    init(name: String, technicalName: String, timeType: Int, sources: [[String]], compatibleSubDivs: [String], skillLevel: Double) {
        super.init()
        self.name = name
        self.technicalName = technicalName
        self.timeType = timeType
        self.sources = sources
        self.compatibleSubDivs = compatibleSubDivs
        self.skillLevel = skillLevel
        self.type = 1
    }
    
    func selectSource(level: Int, andUnder: Bool) -> String? {
        var sourceIndex: Int = andUnder ? random(level) : level
        
        while sourceIndex >= self.sources.count {
            sourceIndex -= 1
        }
        
        return self.sources[sourceIndex][random(self.sources[sourceIndex].count)]
    }
}

internal class MixtureSkill: SkillSet {
    var sources: [[SourceMix]] = []
    var mixType = 0
    
    init(name: String, technicalName: String, mixType: Int, sources: [[SourceMix]], skillLevel: Double) {
        super.init()
        self.name = name
        self.technicalName = technicalName
        self.mixType = mixType
        self.sources = sources
        self.skillLevel = skillLevel
        self.type = 2
    }
    
    func selectSource(level: Int, andUnder: Bool) -> SourceMix? {
        var sourceIndex: Int = andUnder ? random(level) : level
        
        while sourceIndex >= self.sources.count {
            sourceIndex -= 1
        }
        
        return self.sources[sourceIndex][random(self.sources[sourceIndex].count)]
    }
}





internal let quarterNotes = SubDivisionSkill(name: "Quarter Notes", technicalName: "a.1", division: 1, sources: [["1"], ["0"]], compatibleTimeSigs: ["b.2"], skillLevel: 1.5)
internal let eighthNotes = SubDivisionSkill(name: "Eighth Notes", technicalName: "a.2", division: 2, sources: [["10", "11", "00"], ["01"]], compatibleTimeSigs: ["b.2"], skillLevel: 1.5)
internal let tripletNotes = SubDivisionSkill(name: "Triplet Notes", technicalName: "a.3", division: 3, sources: [["100", "111", "000"], ["101", "110"], ["011", "001", "010"]], compatibleTimeSigs: ["b.3"], skillLevel: 0.5)
internal let sixteenthNotes = SubDivisionSkill(name: "Sixteenth Notes", technicalName: "a.4", division: 4, sources: [["1000", "1111", "1010", "0000"], ["1011", "1110"], ["1101", "1100", "1001", "0010", "0011"], ["0111", "0110", "0101", "0100", "0001"]], compatibleTimeSigs: ["b.2"], skillLevel: 0.4)
internal let quintupletNotes = SubDivisionSkill(name: "Quintuplet Notes", technicalName: "a.5", division: 5, sources: [["10000", "11111", "00000"]], compatibleTimeSigs: [], skillLevel: 0.3)

internal let sextupletNotes = SubDivisionSkill(name: "Sextuplet Notes", technicalName: "a.6", division: 6, sources: [["111111", "101010", "000000"], ["100100", "101011", "101110", "101111", "111110", "111011"], ["100001", "100110", "111000", "100011"], ["110000", "101100", "100010", "101000"], ["011000"]], compatibleTimeSigs: ["b.3"], skillLevel: 0.2)

internal let dupleSigs = TimeSignatureSkill(name: "Duple Signatures", technicalName: "b.2", timeType: 2, sources: [["4/4"], ["3/4", "2/4"], ["2/2", "1/4"], ["5/4", "6/4"]], compatibleSubDivs: ["a.1", "a.2", "a.4"], skillLevel: 1.5)
internal let tripleSigs = TimeSignatureSkill(name: "Triple Signatures", technicalName: "b.3", timeType: 3, sources: [["6/8", "12/8"], ["9/8", "3/8"]], compatibleSubDivs: ["a.3"], skillLevel: 0.5)
internal let complexSigs = TimeSignatureSkill(name: "Complex Signatures", technicalName: "b.1", timeType: 1, sources: [["2+3", "2+2+3"], ["3+2", "2+3+2", "3+2+2", "2+2+2+3", "3+3+3"], ["3+3+2", "3+2+3", "2+3+3", "2+2+2+2+3"]], compatibleSubDivs: ["a.1", "a.2", "a.3", "a.4", "a.6"], skillLevel: 0.3)

internal let subMixture = MixtureSkill(name: "SubDivision Mixture", technicalName: "c.1", mixType: 0, sources: [[SourceMix(primary: 3, secondary: 2), SourceMix(primary: 3, secondary: 1)], [SourceMix(primary: 2, secondary: 3), SourceMix(primary: 3, secondary: 4)], [SourceMix(primary: 4, secondary: 3)]], skillLevel: 0.5)
internal let timeMixture = MixtureSkill(name: "TimeSignature Mixture", technicalName: "c.2", mixType: 1, sources: [[SourceMix(primary: 2, secondary: 2), SourceMix(primary: 3, secondary: 3)], [SourceMix(primary: 2, secondary: 3), SourceMix(primary: 3, secondary: 2)], [SourceMix(primary: 1, secondary: 3), SourceMix(primary: 1, secondary: 2),]], skillLevel: 0.5)

internal let nilSkillSet = SkillSet()

internal let skillSetListSub = [quarterNotes, eighthNotes, tripletNotes, sixteenthNotes, quintupletNotes, sextupletNotes]

internal let skillSetListTime = [dupleSigs, tripleSigs, complexSigs]

internal let skillSetListMix = [subMixture, timeMixture]

internal let skillSetList = [quarterNotes, eighthNotes, tripletNotes, sixteenthNotes, quintupletNotes, sextupletNotes, dupleSigs, tripleSigs, complexSigs, subMixture, timeMixture]

internal extension SourceMix {
    func getSubSkills() -> (primary: SubDivisionSkill, secondary: SubDivisionSkill) {
        var returnedPrimary : SubDivisionSkill = quarterNotes
        var returnedSecondary : SubDivisionSkill = quarterNotes
        for skillSet in skillSetListSub {
            if skillSet.division == self.primary {
                returnedPrimary = skillSet
            } else if skillSet.division == self.secondary {
                returnedSecondary = skillSet
            }
        }
        return (returnedPrimary, returnedSecondary)
    }
    func getTimeSkills() -> (primary: TimeSignatureSkill, secondary: TimeSignatureSkill) {
        var returnedPrimary : TimeSignatureSkill = dupleSigs
        var returnedSecondary : TimeSignatureSkill = dupleSigs
        for skillSet in skillSetListTime {
            if skillSet.timeType == self.primary {
                returnedPrimary = skillSet
            } else if skillSet.timeType == self.secondary {
                returnedSecondary = skillSet
            }
        }
        return (returnedPrimary, returnedSecondary)
    }
}

internal func getSkillSetFromName(name: String) -> SkillSet {
    var skillReturned = nilSkillSet
    for skillSet in skillSetList {
        if name == skillSet.technicalName || name == skillSet.name {
            skillReturned = skillSet
        }
    }
    return skillReturned
}

internal func getSkillSetFromName(array: [String]) -> [SkillSet] {
    var skillReturned : [SkillSet] = []
    for name in array {
        for skillSet in skillSetList {
            if name == skillSet.technicalName || name == skillSet.name {
                skillReturned.append(skillSet)
            }
        }
    }
    return skillReturned
}

internal func getSubSkillSetFromDivision(division: Int) -> SubDivisionSkill {
    var skillReturned : SubDivisionSkill = quarterNotes
    for skillSet in skillSetListSub {
        if division == skillSet.division {
            skillReturned = skillSet
        }
    }
    return skillReturned
}

internal func getTimeSkillSetFromType(timeType: Int) -> TimeSignatureSkill {
    var skillReturned: TimeSignatureSkill = dupleSigs
    for skillSet in skillSetListTime {
        if timeType == skillSet.timeType {
            skillReturned = skillSet
        }
    }
    return skillReturned
}

internal extension MixtureSkill {
    func listAvailableSources(availableList: [SkillSet], basicMasteredList: [SkillSet]) -> [SourceMix] {
        var listUnderLevel : [SourceMix] = []
        var returnedList : [SourceMix] = []
        
        let sourceMaxIndex : Int = (self.skillLevel < Double(self.sources.count)) ? Int(roundDown(self.skillLevel) - 1) : self.sources.count - 1
        
        
        if sourceMaxIndex >= 0 {
            for i in 0...sourceMaxIndex {
                for item in self.sources[i] {
                    listUnderLevel.append(item)
                }
            }
            
            if self.mixType == 0 {
                for item in listUnderLevel {
                    if availableList.contains(item.getSubSkills().primary) && availableList.contains(item.getSubSkills().secondary) {
                        if !getSkillSetFromName(item.getSubSkills().primary.compatibleTimeSigs).intersection(basicMasteredList).isEmpty && !getSkillSetFromName(item.getSubSkills().secondary.compatibleTimeSigs).intersection(basicMasteredList).isEmpty {
                            returnedList.append(item)
                        }
                    }
                }
            } else if self.mixType == 1 {
                for item in listUnderLevel {
                    if availableList.contains(item.getTimeSkills().primary) && availableList.contains(item.getTimeSkills().secondary) {
                        if !getSkillSetFromName(item.getTimeSkills().primary.compatibleSubDivs).intersection(basicMasteredList).isEmpty && !getSkillSetFromName(item.getTimeSkills().secondary.compatibleSubDivs).intersection(basicMasteredList).isEmpty {
                            returnedList.append(item)
                        }
                    }
                }
                
            }
        }
        return returnedList
    }
}