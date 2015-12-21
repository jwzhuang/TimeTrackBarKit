//
//  TimeBar.swift
//  TimeBar
//
//  Created by JingWen on 2015/10/13.
//  Copyright © 2015年 JingWen. All rights reserved.
//

import UIKit

@objc public enum ObjectType: Int{
    case Normal, Important, Nothing
}

@objc public protocol TimeTrackBarDelgate:class{
    optional func onTimePicked(date:NSDate, type:ObjectType)
}

@IBDesignable
public class TimeTrackBar: UIView {
    private var currentTime:NSDateComponents?{
        didSet{
            updateScalePos()
            updateObjectRectPos()
            setNeedsDisplay()
        }
    }
    private let cellMilliSeconds = 3600000.0 // 1 hour
    private var eachPosXMilliSeconds:CGFloat = 0.0
    private var scaleInfos = [ScaleInfo]() //24 hours
    private var objectRects = [ObjectRect]()
    private var middleTimeLinePosX:CGFloat = 0.0
    private var eachHourWidth:CGFloat = 0.0
    private var lastTouchPosX:CGFloat = 0.0
    public var frozen = false
    public var backGroundImage:UIImage?
    @IBInspectable public var moveSensitive:CGFloat = 0.2
    @IBInspectable public var showHours = 4.0
    @IBInspectable public var scaleTimeColor:UIColor = UIColor.grayColor()
    @IBInspectable public var scaleTimeFontSize:CGFloat = 12.0
    @IBInspectable public var scaleTimeLineLength:CGFloat = 10.0;
    @IBInspectable public var scaleTimePosY:CGFloat = 0.0
    @IBInspectable public var currentTimeColor:UIColor = UIColor.yellowColor()
    @IBInspectable public var currentTimeFontSize:CGFloat = 14.0
    @IBInspectable public var currentTimePosY:CGFloat = 0.0
    @IBInspectable public var objectRectsPosY:CGFloat = 0.0
    @IBInspectable public var objectRectsHeight:CGFloat = 0.0
    @IBInspectable public var middleLineTopSpace:CGFloat = 0.0
    @IBInspectable public var middleLineBottomSpace:CGFloat = 0.0
    
    @IBOutlet public weak var delegate:TimeTrackBarDelgate?
    
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
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        setupBackGroundImage()
        eachHourWidth = self.bounds.size.width / CGFloat(showHours);
        eachPosXMilliSeconds = CGFloat(CGFloat(cellMilliSeconds) / eachHourWidth)
        middleTimeLinePosX = self.bounds.size.width / 2.0
        setupVectorScale()
        updateScalePos();
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        showScaleTime()
        showObjectRect()
        showCurrentTime()
    }
    
    // MARK: Touch Event
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch = touches.first;
        lastTouchPosX = (touch?.locationInView(self).x)!;
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        let touch = touches.first
        
        if let currentPosX = touch?.locationInView(self).x{
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
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        var objectType:ObjectType = .Nothing
        
        let now = getCurrentTime()
        
        for objectRect in objectRects{
            if isGreaterThanDate(now, dateToCompare: objectRect.startDate) && isLessThanDate(now, dateToCompare: objectRect.endDate){
                objectType = objectRect.type
            }
        }
        delegate?.onTimePicked!(getCurrentTime(), type: objectType)
    }
    
    // MARK: Public Method
    func addObjectInfos(objectInfos:[ObjectInfo]){
        for objectInfo in objectInfos{
            addObjectRect(type: objectInfo.filetype, startDate: objectInfo.startDate, endDate: objectInfo.endDate)
        }
        setNeedsDisplay()
    }
    
    
    public func addObjectRect(type type:ObjectType, startDate:NSDate, endDate:NSDate){
        let objectRect = createObjectRect(type: type, startDate: startDate, endDate: endDate)
        objectRects.append(objectRect)
        setNeedsDisplay()
    }
    
    func setCurrentTime(date:NSDate){
        currentTime = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
    }
    
    public func getCurrentTime() -> NSDate{
        return NSCalendar.currentCalendar().dateFromComponents(currentTime!)!;
    }
    
    func reset(){
        objectRects.removeAll()
        currentTime = currentNSDateComponents()
    }
    
    // MARK: Private Method
    private func commInit(){
        currentTime = currentNSDateComponents()
        for _ in 0..<24{
            scaleInfos.append(ScaleInfo())
        }
    }
    
    private func currentNSDateComponents() -> NSDateComponents{
        return NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: NSDate())
    }
    
    private func createObjectRect(type type:ObjectType, startDate:NSDate, endDate:NSDate) -> ObjectRect{
        
        let startSeconds = startDate.timeIntervalSince1970 * 1.0;
        let endSeconds = endDate.timeIntervalSince1970 * 1.0;
        let currentSeconds = (NSCalendar.currentCalendar().dateFromComponents(currentTime!)?.timeIntervalSince1970)! * 1.0;
        
    
        let posX = middleTimeLinePosX + CGFloat(((startSeconds - currentSeconds) / 3600.0 * Double(eachHourWidth)))
        let width = (endSeconds - startSeconds) / 3600.0 * Double(eachHourWidth)
        
        return ObjectRect(posX: CGFloat(posX), posY: objectRectsPosY, width: CGFloat(width), height: objectRectsHeight, type: type, startDate: startDate, endDate: endDate)
    }
    
    private func getDefaultImage() -> UIImage?{
        let bundle = NSBundle(forClass: TimeTrackBar.self)
        return UIImage(named: "background", inBundle: bundle, compatibleWithTraitCollection: nil)
}
    
    func isGreaterThanDate(currentDate:NSDate, dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if currentDate.compare(dateToCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(currentDate:NSDate, dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if currentDate.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    private func setupBackGroundImage(){
        #if !(TARGET_INTERFACE_BUILDER)
            UIGraphicsBeginImageContext(self.frame.size);
            backGroundImage!.drawInRect(self.bounds);
            let newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.backgroundColor = UIColor(patternImage: newImage)
        #else
            self.backgroundColor = UIColor.darkGrayColor()
        #endif
        
    }
    
    private func setupVectorScale(){
        for scaleInfo in scaleInfos{
            scaleInfo.posX = -1
            scaleInfo.scaleTimeColor = scaleTimeColor
            scaleInfo.scaleTimeLineLength = scaleTimeLineLength
            scaleInfo.second = 3600 * scaleInfos.indexOf({$0 === scaleInfo})!
            scaleInfo.setPosRange(0.0, end: 24.0 * eachHourWidth)
        }
    }
    
    private func showCurrentTime(){
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, currentTimeColor.CGColor)
        CGContextMoveToPoint(context, CGFloat(middleTimeLinePosX), middleLineTopSpace)
        CGContextAddLineToPoint(context, CGFloat(middleTimeLinePosX),self.bounds.size.height - middleLineBottomSpace)
        CGContextStrokePath(context)
        
        let font = UIFont.systemFontOfSize(currentTimeFontSize)
        let paragraphSytle = NSMutableParagraphStyle()
        paragraphSytle.alignment = NSTextAlignment.Center
        
        let attribute = [NSParagraphStyleAttributeName:paragraphSytle, NSFontAttributeName:font, NSForegroundColorAttributeName:currentTimeColor]
        
        let currentTimeString = String(format: "%04d-%02d-%02d %02d:%02d:%02d", (currentTime?.year)!, (currentTime?.month)!, (currentTime?.day)!, (currentTime?.hour)!, (currentTime?.minute)!, (currentTime?.second)!)
        
        let textSize: CGSize = currentTimeString.sizeWithAttributes(attribute)
        
        currentTimeString.drawInRect(CGRectMake(middleTimeLinePosX - textSize.width / 2.0, currentTimePosY, textSize.width,  textSize.height), withAttributes: attribute)
        CGContextSaveGState(context)
    }
    
    private func showScaleTime(){
        let context = UIGraphicsGetCurrentContext()
        let font = UIFont.systemFontOfSize(scaleTimeFontSize)
        
        let paragraphSytle = NSMutableParagraphStyle()
        paragraphSytle.alignment = NSTextAlignment.Center
        
        let attribute = [NSParagraphStyleAttributeName:paragraphSytle, NSFontAttributeName:font, NSForegroundColorAttributeName:scaleTimeColor]
        let textSize: CGSize = "00:00".sizeWithAttributes(attribute)
        
        for scaleinfo in scaleInfos{
            if (scaleinfo.isInRange(0.0, width: self.bounds.size.width)){
                scaleinfo.draw(context!, posY: scaleTimePosY, textSize: textSize, withAttributes: attribute)  
            }
        }
        CGContextSaveGState(context)
    }
    
    private func showObjectRect(){
        let context = UIGraphicsGetCurrentContext()
        for objectRect in objectRects{
            objectRect.draw(context!, barWidth: self.bounds.size.width)
        }
        CGContextSaveGState(context)
    }
    
    private func updateObjectRectPos(){
        
        for objectRect in objectRects{
            let startSeconds = objectRect.startDate.timeIntervalSince1970 * 1.0
            let endSeconds = objectRect.endDate.timeIntervalSince1970 * 1.0
            let currentSeconds = (NSCalendar.currentCalendar().dateFromComponents(currentTime!)?.timeIntervalSince1970)! * 1.0;
            let newPosX = middleTimeLinePosX + (CGFloat(startSeconds - currentSeconds) / 3600.0 * eachHourWidth)
            let newWidth = CGFloat(endSeconds - startSeconds) / 3600.0 * eachHourWidth
            objectRect.posX = CGFloat(newPosX)
            objectRect.width = CGFloat(newWidth)
        }
    }
    
    private func updateScalePos(){
        for scaleInfo in scaleInfos{
            if let now = currentTime{
                var secDifference = 3600 * (scaleInfo.hour - now.hour)
                secDifference += 60 * (scaleInfo.minute - now.minute)
                secDifference += scaleInfo.second - now.second
                
                scaleInfo.setPosRange(0.0, end: 24.0 * eachHourWidth)
                scaleInfo.posX = middleTimeLinePosX + (CGFloat(secDifference) / 3600.0 * eachHourWidth)
            }
        }
    }
    
    private func updateCurrentTimeByPosX(posXDefference:CGFloat){
        let moveSeconds = posXDefference * eachPosXMilliSeconds
        let timeStamp = (NSCalendar.currentCalendar().dateFromComponents(currentTime!)?.timeIntervalSince1970)! * 1000 - Double(moveSeconds);
        currentTime = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: NSDate(timeIntervalSince1970: timeStamp / 1000))
    }
}
