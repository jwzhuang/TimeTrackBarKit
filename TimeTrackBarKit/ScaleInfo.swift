//
//  ScaleInfo.swift
//  TimeBar
//
//  Created by JingWen on 2015/10/14.
//  Copyright © 2015年 JingWen. All rights reserved.
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
    var scaleTimeColor:UIColor = UIColor.grayColor()
    var scaleTimeLineLength:CGFloat = 10.0;
    private var minPostX:CGFloat = 0.0
    private var maxPostX:CGFloat = 0.0
    
    init(){
        self.time = String(format: "%02d:%02d", hour, minute)
    }
    
    func isInRange(posX:CGFloat, width:CGFloat) -> Bool{
        return self.posX >= posX && self.posX <= width;
    }
    
    func setPosRange(start:CGFloat, end:CGFloat){
        self.minPostX = start;
        self.maxPostX = end;
    }
    
    func draw(context:CGContextRef, posY:CGFloat, textSize:CGSize, withAttributes attrs: [String : AnyObject]){
        time.drawInRect(CGRectMake(CGFloat(posX - textSize.width / 2.0), posY, textSize.width,  textSize.height), withAttributes: attrs)
        CGContextMoveToPoint(context, CGFloat(posX), posY + textSize.height);
        CGContextAddLineToPoint(context, CGFloat(posX),posY + textSize.height + scaleTimeLineLength);
        CGContextSetStrokeColorWithColor(context, scaleTimeColor.CGColor)
        CGContextStrokePath(context);
    }
}