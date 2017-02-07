//
//  ScaleInfo.swift
//  TimeBar
//
//  Created by JingWen on 2015/10/14.
//  Copyright © 2015年 JingWen. All rights reserved.
//
//

import UIKit

class ScaleInfo {
    var posX:CGFloat = -1.0{
        didSet{
            if(posX < minPostX){ //scroll left
                posX = maxPostX - (minPostX - posX)
            }else if(posX > self.maxPostX){ //scroll right
                posX = minPostX + (posX - maxPostX)
            }
        }
    }
    
    var second:Int = 0{
        didSet{
            hour = second / 3600
            minute = second % 3600 / 60
            self.second = second % 3600 % 3600
            time = String.localizedStringWithFormat("%02d:%02d", hour, minute)
        }
    }
    var hour=0
    var minute=0
    var time:String
    var scaleTimeColor:UIColor = UIColor.gray
    var scaleTimeLineLength:CGFloat = 10.0;
    fileprivate var minPostX:CGFloat = 0.0
    fileprivate var maxPostX:CGFloat = 0.0
    
    init(){
        self.time = String(format: "%02d:%02d", hour, minute)
    }
    
    func isInRange(_ posX:CGFloat, width:CGFloat) -> Bool{
        return self.posX >= posX && self.posX <= width;
    }
    
    func setPosRange(_ start:CGFloat, end:CGFloat){
        self.minPostX = start;
        self.maxPostX = end;
    }
    
    func draw(_ context:CGContext, posY:CGFloat, textSize:CGSize, withAttributes attrs: [String : AnyObject]){
        time.draw(in: CGRect(x: CGFloat(posX - textSize.width / 2.0), y: posY, width: textSize.width,  height: textSize.height), withAttributes: attrs)
        context.move(to: CGPoint(x: CGFloat(posX), y: posY + textSize.height));
        context.addLine(to: CGPoint(x: CGFloat(posX), y: posY + textSize.height + scaleTimeLineLength));
        context.setStrokeColor(scaleTimeColor.cgColor)
        context.strokePath();
    }
}
