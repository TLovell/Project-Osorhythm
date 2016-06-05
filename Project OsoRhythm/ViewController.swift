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
    
    func initialize() {
        for skillSet in skillSetList {
            if skillSet == quarterNotes || skillSet == dupleSigs || skillSet == eighthNotes {
                skillSet.skillLevel = (Double(random(40)) + 10) / 10
            } else {
                skillSet.skillLevel = Double(random(50)) / 10
            }
        }
    }
    
    @IBAction func generateButton(sender: AnyObject) {
        intensity = (intensity == 0.9) ? 0.0 : intensity + 0.1
        Display.text = String(generateExercise())
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

