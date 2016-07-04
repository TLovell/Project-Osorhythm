//
//  CircleButton.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/29/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import UIKit
import Foundation

class CircleButton: UIView {
    var topCircle : UIView
    var bottomCircle : UIView
    var text : UILabel
    var frameTimer = NSTimer()
    
    init(x: Double, y: Double, radius: Double, visibleHeight: Double) {
        let frame = CGRectMake(CGFloat(x), CGFloat(y), CGFloat(2 * radius), CGFloat(2 * radius))
        self.bottomCircle = UIView(frame: CGRectMake(0.0, 0.0, CGFloat(2 * radius), CGFloat(2 * radius)))
        self.bottomCircle.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.bottomCircle.layer.cornerRadius = frame.width / 2

        self.topCircle = UIView(frame: CGRectMake(0.0, 0.0, CGFloat(2 * radius), CGFloat(2 * radius)))
        self.topCircle.backgroundColor = accentColor
        self.topCircle.layer.cornerRadius = frame.width / 2
        
        self.text = UILabel(frame: CGRectMake(0.0, 0.0, frame.width, (visibleHeight > radius * 2) ? frame.width : CGFloat(visibleHeight)))
        self.text.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.text.font = UIFont.systemFontOfSize(CGFloat(visibleHeight / 3))
        self.text.textAlignment = .Center
        self.text.text = ""
        
        super.init(frame: frame)
        self.addSubview(bottomCircle)
        self.addSubview(topCircle)
        self.addSubview(text)
        self.userInteractionEnabled = true
    }
    
    
    func framePassed() {
        self.text.alpha -= 0.03
    }
    
    
    func resetFrame(x: Double, y: Double, radius: Double, visibleHeight: Double) {
        
        let frame = CGRectMake(CGFloat(x), CGFloat(y), CGFloat(2 * radius), CGFloat(2 * radius))
        
        self.frame = frame
        
        self.text.frame = CGRectMake(0.0, 0.0, frame.width, (visibleHeight > radius * 2) ? frame.width : CGFloat(visibleHeight))
        
    }
    
    func setLabelText(string: String) {
        text.text = string
        text.alpha = 1.0
        
        if currentAppState == .CountOff {
            frameTimer.invalidate()
            frameTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("framePassed"), userInfo: nil, repeats: true)
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        tapAreaTouched()
        self.topCircle.backgroundColor = self.topCircle.backgroundColor?.colorWithAlphaComponent(0.5)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.topCircle.backgroundColor = accentColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}