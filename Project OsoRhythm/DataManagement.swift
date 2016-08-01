//
//  DataManagement.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 7/24/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation
import CoreData
import UIKit

internal func viewLoadedDataManagement() {
    var skillList = skillSetList
    skillList.append(passiveDisplay)
    
    let appDel : AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context : NSManagedObjectContext = appDel.managedObjectContext
    
    let request = NSFetchRequest(entityName: "SkillSet")
    request.returnsObjectsAsFaults = false
    
    var results : NSArray = []
    do {
        try results = context.executeFetchRequest(request)
    } catch {
        print("Request Failed")
    }
    
    if results.count == 0 {
        initialSave()
    } else {
        load()
    }
}

func initialSave() {
    var skillList = skillSetList
    skillList.append(passiveDisplay)
    
    let appDel : AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context : NSManagedObjectContext = appDel.managedObjectContext
    
    for skillSet in skillList {
        
        let description = NSEntityDescription.entityForName("SkillSet", inManagedObjectContext: context)
        let newSkillSet = NSManagedObject(entity: description!, insertIntoManagedObjectContext: context)
        
        newSkillSet.setValue(skillSet.name, forKey: "name")
        newSkillSet.setValue(skillSet.skillLevel, forKey: "skillLevel")
        

    }
    
    do {
        try context.save()
    } catch {
        print("Save Failed")
    }
}

func load() {
    var skillList = skillSetList
    skillList.append(passiveDisplay)
    
    let appDel : AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context : NSManagedObjectContext = appDel.managedObjectContext
    
    for skillSet in skillList {
        let request = NSFetchRequest(entityName: "SkillSet")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", skillSet.name)
        
        var results : NSArray = []
        do {
            try results = context.executeFetchRequest(request)
        } catch {
            print("Request Failed")
        }
        
        if results.count == 1 {
            skillSet.skillLevel = results[0].valueForKey("skillLevel") as! Double
        } else {
            print("results.count == \(results.count)")
        }
    }
    
    updateLocks()
    
}

internal func save() {
    var skillList = skillSetList
    skillList.append(passiveDisplay)
    
    let appDel : AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context : NSManagedObjectContext = appDel.managedObjectContext
    
    for skillSet in skillList {
        let request = NSFetchRequest(entityName: "SkillSet")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", skillSet.name)
        
        var results : NSArray = []
        do {
            try results = context.executeFetchRequest(request)
        } catch {
            print("Request Failed")
        }
        if results.count == 1 {
            results[0].setValue(skillSet.skillLevel, forKey: "skillLevel")
        }
        
    }
    
    do {
        try context.save()
    } catch {
        print("Save Failed")
    }
}


