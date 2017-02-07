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
    var type:ObjectType = .normal
    var startDate:Date
    var endDate:Date
    
    init(posX:CGFloat, posY:CGFloat, width:CGFloat, height:CGFloat, type:ObjectType, startDate:Date, endDate:Date){
        self.posX = posX
        self.posY = posY
        self.width = width
        self.height = height
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
    }
    
    //MARK: Public Method
    func draw(_ context:CGContext, barX:CGFloat = 0, barWidth:CGFloat) ->(){
        switch type{
        case .normal:
            context.setFillColor(UIColor.blue.cgColor)
        case .important:
            context.setFillColor(UIColor.red.cgColor)
        case .nothing:
            return
        }
        if isInRange(barX, width: barWidth){
            if self.posX < barX && self.posX + self.width > barX{ //cut at left
                context.fill(CGRect(x: barX, y: posY, width: posX + self.width, height: height))
            }else if self.posX < barWidth && self.posX + self.width > barWidth{ //cut at right
                context.fill(CGRect(x: posX, y: posY, width: barWidth, height: height))
            }else{
                context.fill(CGRect(x: posX, y: posY, width: width, height: height))
            }
        }
    }
    
    //MARK: Public Method
    func isInRange(_ barX:CGFloat, width barWidth:CGFloat) -> Bool{
        if (self.posX + self.width < barX) || self.posX > barWidth{
            return false
        }
        return true
    }
    
}
