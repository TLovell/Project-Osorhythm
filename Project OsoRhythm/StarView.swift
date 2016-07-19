//
//  StarView.swift
//  Project OsoRhythm
//
//  Created by Trevor Lovell on 7/17/16.
//  Copyright © 2016 Trevor Lovell and Braeden Ayres. All rights reserved.
//

import Foundation
import UIKit

class StarView: UIView {
    var starImages : [UIImageView]
    var starCount : Int
    
    init(x: Double, y: Double, width: Double, starCount: Int) {
        let frame  = CGRect(x: x, y: y, width: width, height: width / 5.0)
        
        self.starCount = starCount
        
        self.starImages = []
        for i in 0...2 {
            let image = UIImage(assetIndentifier: ((i < starCount) ? .StarFilled : .Star))
            let imageView = UIImageView(frame: CGRect(x: Double(i) * Double(frame.height) * 2.0, y: 0.0, width: Double(frame.height), height: Double(frame.height)))
            imageView.image = image
            starImages.append(imageView)
        }
        
        super.init(frame: frame)
        
        for star in starImages {
            self.addSubview(star)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}