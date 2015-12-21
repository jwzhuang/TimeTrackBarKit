//
//  FileRect.swift
//  TimeBar
//
//  Created by JingWen on 2015/10/13.
//  Copyright © 2015年 JingWen. All rights reserved.
//

import UIKit


class ObjectRect {
    
    var posX:CGFloat
    var posY:CGFloat = 10.0
    var width:CGFloat
    var height:CGFloat = 10.0
    var type:ObjectType = .Normal
    var startDate:NSDate
    var endDate:NSDate
    
    init(posX:CGFloat, posY:CGFloat, width:CGFloat, height:CGFloat, type:ObjectType, startDate:NSDate, endDate:NSDate){
        self.posX = posX
        self.posY = posY
        self.width = width
        self.height = height
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
    }
    
    //MARK: Public Method
    func draw(context:CGContextRef, barX:CGFloat = 0, barWidth:CGFloat) ->(){
        switch type{
        case .Normal:
            CGContextSetFillColorWithColor(context, UIColor.blueColor().CGColor)
        case .Important:
            CGContextSetFillColorWithColor(context, UIColor.redColor().CGColor)
        case .Nothing:
            return
        }
        if isInRange(barX, width: barWidth){
            if self.posX < barX && self.posX + self.width > barX{ //cut at left
                CGContextFillRect(context, CGRectMake(barX, posY, posX + self.width, height))
            }else if self.posX < barWidth && self.posX + self.width > barWidth{ //cut at right
                CGContextFillRect(context, CGRectMake(posX, posY, barWidth, height))
            }else{
                CGContextFillRect(context, CGRectMake(posX, posY, width, height))
            }
        }
    }
    
    //MARK: Public Method
    func isInRange(barX:CGFloat, width barWidth:CGFloat) -> Bool{
        if (self.posX + self.width < barX) || self.posX > barWidth{
            return false
        }
        return true
    }
    
}