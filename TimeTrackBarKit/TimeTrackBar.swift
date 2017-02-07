//
//  TimeBar.swift
//  TimeBar
//
//  Created by JingWen on 2015/10/13.
//  Copyright © 2015年 JingWen. All rights reserved.
//

import UIKit

@objc public enum ObjectType: Int{
    case normal, important, nothing
}

@objc public protocol TimeTrackBarDelgate:class{
    @objc optional func onTimePicked(_ date:Date, type:ObjectType)
}

@IBDesignable
open class TimeTrackBar: UIView {
    fileprivate var currentTime:DateComponents?{
        didSet{
            updateScalePos()
            updateObjectRectPos()
            setNeedsDisplay()
        }
    }
    fileprivate let cellMilliSeconds = 3600000.0 // 1 hour
    fileprivate var eachPosXMilliSeconds:CGFloat = 0.0
    fileprivate var scaleInfos = [ScaleInfo]() //24 hours
    fileprivate var objectRects = [ObjectRect]()
    fileprivate var middleTimeLinePosX:CGFloat = 0.0
    fileprivate var eachHourWidth:CGFloat = 0.0
    fileprivate var lastTouchPosX:CGFloat = 0.0
    open var frozen = false
    open var backGroundImage:UIImage?
    @IBInspectable open var moveSensitive:CGFloat = 0.2
    @IBInspectable open var showHours = 4.0
    @IBInspectable open var scaleTimeColor:UIColor = UIColor.gray
    @IBInspectable open var scaleTimeFontSize:CGFloat = 12.0
    @IBInspectable open var scaleTimeLineLength:CGFloat = 10.0;
    @IBInspectable open var scaleTimePosY:CGFloat = 0.0
    @IBInspectable open var currentTimeColor:UIColor = UIColor.yellow
    @IBInspectable open var currentTimeFontSize:CGFloat = 14.0
    @IBInspectable open var currentTimePosY:CGFloat = 0.0
    @IBInspectable open var objectRectsPosY:CGFloat = 0.0
    @IBInspectable open var objectRectsHeight:CGFloat = 0.0
    @IBInspectable open var middleLineTopSpace:CGFloat = 0.0
    @IBInspectable open var middleLineBottomSpace:CGFloat = 0.0
    
    @IBOutlet open weak var delegate:TimeTrackBarDelgate?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        backGroundImage = getDefaultImage()
        commInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        backGroundImage = getDefaultImage()
        commInit()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        setupBackGroundImage()
        eachHourWidth = self.bounds.size.width / CGFloat(showHours);
        eachPosXMilliSeconds = CGFloat(CGFloat(cellMilliSeconds) / eachHourWidth)
        middleTimeLinePosX = self.bounds.size.width / 2.0
        setupVectorScale()
        updateScalePos();
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        showScaleTime()
        showObjectRect()
        showCurrentTime()
    }
    
    // MARK: Touch Event
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first;
        lastTouchPosX = (touch?.location(in: self).x)!;
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let touch = touches.first
        
        if let currentPosX = touch?.location(in: self).x{
            let posXDefference = currentPosX - lastTouchPosX
            if(abs(posXDefference) < moveSensitive){
                return
            }
            lastTouchPosX = currentPosX
            if !frozen{
                updateCurrentTimeByPosX(posXDefference)
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        var objectType:ObjectType = .nothing
        
        let now = getCurrentTime()
        
        for objectRect in objectRects{
            if isGreaterThanDate(now, dateToCompare: objectRect.startDate as Date) && isLessThanDate(now, dateToCompare: objectRect.endDate as Date){
                objectType = objectRect.type
            }
        }
        delegate?.onTimePicked!(getCurrentTime(), type: objectType)
    }
    
    // MARK: Public Method
    func addObjectInfos(_ objectInfos:[ObjectInfo]){
        for objectInfo in objectInfos{
            addObjectRect(objectInfo.filetype, startDate: objectInfo.startDate as Date, endDate: objectInfo.endDate as Date)
        }
        setNeedsDisplay()
    }
    
    
    open func addObjectRect(_ type:ObjectType, startDate:Date, endDate:Date){
        let objectRect = createObjectRect(type, startDate: startDate, endDate: endDate)
        objectRects.append(objectRect)
        setNeedsDisplay()
    }
    
    func setCurrentTime(_ date:Date){
        currentTime = (Calendar.current as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: date)
    }
    
    open func getCurrentTime() -> Date{
        return Calendar.current.date(from: currentTime!)!;
    }
    
    func reset(){
        objectRects.removeAll()
        currentTime = currentNSDateComponents()
    }
    
    // MARK: Private Method
    fileprivate func commInit(){
        currentTime = currentNSDateComponents()
        for _ in 0..<24{
            scaleInfos.append(ScaleInfo())
        }
    }
    
    fileprivate func currentNSDateComponents() -> DateComponents{
        return (Calendar.current as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: Date())
    }
    
    fileprivate func createObjectRect(_ type:ObjectType, startDate:Date, endDate:Date) -> ObjectRect{
        
        let startSeconds = startDate.timeIntervalSince1970 * 1.0;
        let endSeconds = endDate.timeIntervalSince1970 * 1.0;
        let currentSeconds = (Calendar.current.date(from: currentTime!)?.timeIntervalSince1970)! * 1.0;
        
    
        let posX = middleTimeLinePosX + CGFloat(((startSeconds - currentSeconds) / 3600.0 * Double(eachHourWidth)))
        let width = (endSeconds - startSeconds) / 3600.0 * Double(eachHourWidth)
        
        return ObjectRect(posX: CGFloat(posX), posY: objectRectsPosY, width: CGFloat(width), height: objectRectsHeight, type: type, startDate: startDate, endDate: endDate)
    }
    
    fileprivate func getDefaultImage() -> UIImage?{
        let bundle = Bundle(for: TimeTrackBar.self)
        return UIImage(named: "background", in: bundle, compatibleWith: nil)
}
    
    func isGreaterThanDate(_ currentDate:Date, dateToCompare : Date) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if currentDate.compare(dateToCompare) == ComparisonResult.orderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(_ currentDate:Date, dateToCompare : Date) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if currentDate.compare(dateToCompare) == ComparisonResult.orderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    fileprivate func setupBackGroundImage(){
        #if !(TARGET_INTERFACE_BUILDER)
            UIGraphicsBeginImageContext(self.frame.size);
            backGroundImage!.draw(in: self.bounds);
            let newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.backgroundColor = UIColor(patternImage: newImage!)
        #else
            self.backgroundColor = UIColor.darkGrayColor()
        #endif
        
    }
    
    fileprivate func setupVectorScale(){
        for scaleInfo in scaleInfos{
            scaleInfo.posX = -1
            scaleInfo.scaleTimeColor = scaleTimeColor
            scaleInfo.scaleTimeLineLength = scaleTimeLineLength
            scaleInfo.second = 3600 * scaleInfos.index(where: {$0 === scaleInfo})!
            scaleInfo.setPosRange(0.0, end: 24.0 * eachHourWidth)
        }
    }
    
    fileprivate func showCurrentTime(){
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(currentTimeColor.cgColor)
        context?.move(to: CGPoint(x: CGFloat(middleTimeLinePosX), y: middleLineTopSpace))
        context?.addLine(to: CGPoint(x: CGFloat(middleTimeLinePosX), y: self.bounds.size.height - middleLineBottomSpace))
        context?.strokePath()
        
        let font = UIFont.systemFont(ofSize: currentTimeFontSize)
        let paragraphSytle = NSMutableParagraphStyle()
        paragraphSytle.alignment = NSTextAlignment.center
        
        let attribute = [NSParagraphStyleAttributeName:paragraphSytle, NSFontAttributeName:font, NSForegroundColorAttributeName:currentTimeColor]
        
        let currentTimeString = String(format: "%04d-%02d-%02d %02d:%02d:%02d", (currentTime?.year)!, (currentTime?.month)!, (currentTime?.day)!, (currentTime?.hour)!, (currentTime?.minute)!, (currentTime?.second)!)
        
        let textSize: CGSize = currentTimeString.size(attributes: attribute)
        
        currentTimeString.draw(in: CGRect(x: middleTimeLinePosX - textSize.width / 2.0, y: currentTimePosY, width: textSize.width,  height: textSize.height), withAttributes: attribute)
        context?.saveGState()
    }
    
    fileprivate func showScaleTime(){
        let context = UIGraphicsGetCurrentContext()
        let font = UIFont.systemFont(ofSize: scaleTimeFontSize)
        
        let paragraphSytle = NSMutableParagraphStyle()
        paragraphSytle.alignment = NSTextAlignment.center
        
        let attribute = [NSParagraphStyleAttributeName:paragraphSytle, NSFontAttributeName:font, NSForegroundColorAttributeName:scaleTimeColor]
        let textSize: CGSize = "00:00".size(attributes: attribute)
        
        for scaleinfo in scaleInfos{
            if (scaleinfo.isInRange(0.0, width: self.bounds.size.width)){
                scaleinfo.draw(context!, posY: scaleTimePosY, textSize: textSize, withAttributes: attribute)  
            }
        }
        context?.saveGState()
    }
    
    fileprivate func showObjectRect(){
        let context = UIGraphicsGetCurrentContext()
        for objectRect in objectRects{
            objectRect.draw(context!, barWidth: self.bounds.size.width)
        }
        context?.saveGState()
    }
    
    fileprivate func updateObjectRectPos(){
        
        for objectRect in objectRects{
            let startSeconds = objectRect.startDate.timeIntervalSince1970 * 1.0
            let endSeconds = objectRect.endDate.timeIntervalSince1970 * 1.0
            let currentSeconds = (Calendar.current.date(from: currentTime!)?.timeIntervalSince1970)! * 1.0;
            let newPosX = middleTimeLinePosX + (CGFloat(startSeconds - currentSeconds) / 3600.0 * eachHourWidth)
            let newWidth = CGFloat(endSeconds - startSeconds) / 3600.0 * eachHourWidth
            objectRect.posX = CGFloat(newPosX)
            objectRect.width = CGFloat(newWidth)
        }
    }
    
    fileprivate func updateScalePos(){
        for scaleInfo in scaleInfos{
            if let now = currentTime{
                var secDifference = 3600 * (scaleInfo.hour - now.hour!)
                secDifference += 60 * (scaleInfo.minute - now.minute!)
                secDifference += scaleInfo.second - now.second!
                
                scaleInfo.setPosRange(0.0, end: 24.0 * eachHourWidth)
                scaleInfo.posX = middleTimeLinePosX + (CGFloat(secDifference) / 3600.0 * eachHourWidth)
            }
        }
    }
    
    fileprivate func updateCurrentTimeByPosX(_ posXDefference:CGFloat){
        let moveSeconds = posXDefference * eachPosXMilliSeconds
        let timeStamp = (Calendar.current.date(from: currentTime!)?.timeIntervalSince1970)! * 1000 - Double(moveSeconds);
        currentTime = (Calendar.current as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: Date(timeIntervalSince1970: timeStamp / 1000))
    }
}
