//
//  CircleButton.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 6/29/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class CircleButton: UIButton {
    var topCircle : UIView
    var bottomCircle : UIView
    var text : UILabel
    var frameTimer = NSTimer()
    var fadeInTimer = NSTimer()
    
    enum ButtonType {
        case TapCircle
        case NextExercise
        case TryAgain
        case Listen
    }
    
    var type : ButtonType
    
    init(x: Double, y: Double, radius: Double, type: ButtonType, visibleHeight: Double) {
        let frame = CGRectMake(CGFloat(x), CGFloat(y), CGFloat(2 * radius), CGFloat(2 * radius))
        self.bottomCircle = UIView(frame: CGRectMake(0.0, 0.0, CGFloat(2 * radius), CGFloat(2 * radius)))
        self.bottomCircle.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.bottomCircle.alpha = 0.0
        self.bottomCircle.layer.cornerRadius = frame.width / 2
        
        self.topCircle = UIView(frame: CGRectMake(0.0, 0.0, CGFloat(2 * radius), CGFloat(2 * radius)))
        self.topCircle.backgroundColor = accentColor
        self.topCircle.alpha = 0.0
        self.topCircle.layer.cornerRadius = frame.width / 2
        
        self.text = UILabel(frame: CGRectMake(0.0, 0.0, frame.width, (visibleHeight > radius * 2) ? frame.width : CGFloat(visibleHeight)))
        self.text.adjustsFontSizeToFitWidth = true
        self.text.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.text.font = UIFont.systemFontOfSize(CGFloat(visibleHeight / 3))
        self.text.textAlignment = .Center
        self.text.text = ""
        self.text.numberOfLines = 2
        
        self.type = type
        
        super.init(frame: frame)
        self.addSubview(bottomCircle)
        self.addSubview(topCircle)
        self.addSubview(text)
        self.userInteractionEnabled = false
        if type == .TapCircle { self.multipleTouchEnabled = true }
        fadeInTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(CircleButton.fadeIn), userInfo: nil, repeats: true)
    }
    
    init(x: Double, y: Double, radius: Double, type: ButtonType) {
        let frame = CGRectMake(CGFloat(x), CGFloat(y), CGFloat(2 * radius), CGFloat(2 * radius))
        self.bottomCircle = UIView(frame: CGRectMake(0.0, 0.0, CGFloat(2 * radius), CGFloat(2 * radius)))
        self.bottomCircle.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.bottomCircle.alpha = 0.0
        self.bottomCircle.layer.cornerRadius = frame.width / 2
        
        self.topCircle = UIView(frame: CGRectMake(0.0, 0.0, CGFloat(2 * radius), CGFloat(2 * radius)))
        self.topCircle.backgroundColor = accentColor
        self.topCircle.alpha = 0.0
        self.topCircle.layer.cornerRadius = frame.width / 2
        
        self.text = UILabel(frame: CGRectMake(frame.width / 6, 0.0, frame.width * (2 / 3), frame.height))
        self.text.adjustsFontSizeToFitWidth = true
        self.text.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.text.font = UIFont.systemFontOfSize(frame.height / 7)
        self.text.textAlignment = .Center
        self.text.text = ""
        self.text.numberOfLines = 2
        
        self.type = type
        
        super.init(frame: frame)
        self.addSubview(bottomCircle)
        self.addSubview(topCircle)
        self.addSubview(text)
        self.userInteractionEnabled = false
        if type == .TapCircle { self.multipleTouchEnabled = true }
        fadeInTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(CircleButton.fadeIn), userInfo: nil, repeats: true)
    }
    
    init(x: Double, y: Double, radius: Double, type: ButtonType, text: String) {
        let frame = CGRectMake(CGFloat(x), CGFloat(y), CGFloat(2 * radius), CGFloat(2 * radius))
        self.bottomCircle = UIView(frame: CGRectMake(0.0, 0.0, CGFloat(2 * radius), CGFloat(2 * radius)))
        self.bottomCircle.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.bottomCircle.alpha = 0.0
        self.bottomCircle.layer.cornerRadius = frame.width / 2
        
        self.topCircle = UIView(frame: CGRectMake(0.0, 0.0, CGFloat(2 * radius), CGFloat(2 * radius)))
        self.topCircle.backgroundColor = accentColor
        self.topCircle.alpha = 0.0
        self.topCircle.layer.cornerRadius = frame.width / 2
        
        self.text = UILabel(frame: CGRectMake(frame.width / 6, 0.0, frame.width * (2 / 3), frame.height))
        self.text.adjustsFontSizeToFitWidth = true
        self.text.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.text.font = UIFont.systemFontOfSize(frame.height / 7)
        self.text.textAlignment = .Center
        self.text.text = text
        self.text.numberOfLines = 2
        
        self.type = type
        
        super.init(frame: frame)
        self.addSubview(bottomCircle)
        self.addSubview(topCircle)
        self.addSubview(self.text)
        self.userInteractionEnabled = false
        if type == .TapCircle { self.multipleTouchEnabled = true }
        fadeInTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(CircleButton.fadeIn), userInfo: nil, repeats: true)
    }
    
    func framePassed() {
        self.text.alpha -= 0.03
    }
    
    
    func resetFrame(x: Double, y: Double, radius: Double, visibleHeight: Double) {
        
        self.frame = CGRect(x: x, y: y, width: radius * 2, height: radius * 2)
        
        self.text.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: (visibleHeight > radius * 2) ? frame.width : CGFloat(visibleHeight))
        self.text.font = UIFont.systemFontOfSize(CGFloat(visibleHeight / 3))
        
        self.topCircle.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        self.topCircle.layer.cornerRadius = frame.width / 2
        
        self.bottomCircle.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        self.bottomCircle.layer.cornerRadius = frame.width / 2
        
    }
    
    
    func setLabelText(string: String) {
        text.text = string
        text.alpha = 1.0
        
        if currentAppState == .CountOff {
            frameTimer.invalidate()
            frameTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(CircleButton.framePassed), userInfo: nil, repeats: true)
        }
    }
    
    func fade() {
        self.topCircle.alpha -= 0.07
        if topCircle.alpha <= 0.0 {
            self.removeFromSuperview()
        }
    }
    
    func fadeOut() {
        self.userInteractionEnabled = false
        self.bottomCircle.alpha = 0.0
        NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(CircleButton.fade), userInfo: nil, repeats: true)
    }
    
    func fadeIn() {
        self.topCircle.alpha += 0.07
        self.text.alpha += 0.07
        if topCircle.alpha >= 1.0 {
            self.bottomCircle.alpha = 1.0
            self.text.alpha = 1.0
            if topCircle.backgroundColor == accentColor {
                self.userInteractionEnabled = true
            }
            fadeInTimer.invalidate()
        }
    }
    
    func disableInteraction() {
        self.topCircle.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        userInteractionEnabled = false
    }
    
    func enableInteraction() {
        self.topCircle.backgroundColor = accentColor
        userInteractionEnabled = true
    }
    
    
    func autoTouched() {
        tapAreaTouched()
        AudioServicesPlaySystemSound(1104)
        AudioServicesPlaySystemSound(1057)
    }
    
    var autoTouchTimers : [NSTimer] = []
    
    func autoPlay() {
        
        for touch in currentAnswerKey {
            autoTouchTimers.append(NSTimer.scheduledTimerWithTimeInterval(touch.time, target: self, selector: #selector(autoTouched), userInfo: nil, repeats: false))
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        self.topCircle.backgroundColor = self.topCircle.backgroundColor?.colorWithAlphaComponent(0.9)
        if type == .TapCircle {
            tapAreaTouched()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        self.topCircle.backgroundColor = accentColor
        self.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}