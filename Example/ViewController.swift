//
//  ViewController.swift
//  TimeBar
//
//  Created by JingWen on 2015/10/13.
//  Copyright © 2015年 JingWen. All rights reserved.
//

import UIKit
import TimeTrackBarKit

class ViewController: UIViewController,TimeTrackBarDelgate {
    
    @IBOutlet weak var trackBar: TimeTrackBar!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupTimeTrackBar()
    }
    
    func setupTimeTrackBar() {
        let trackBarHalfHeight:CGFloat = trackBar.bounds.size.height / 2
        trackBar.objectRectsHeight = 10.0
        trackBar.objectRectsPosY = trackBar.bounds.size.height - (trackBar.objectRectsHeight + 3)
        trackBar.scaleTimePosY = trackBarHalfHeight - trackBar.objectRectsHeight
        trackBar.middleLineTopSpace = trackBarHalfHeight + trackBar.objectRectsHeight
        trackBar.delegate = self
        trackBar.layoutSubviews()
    }
    
    
    //MARK: Actions
    @IBAction func clickNormal(sender: UIButton) {
        let currentTime = trackBar.getCurrentTime()
        //        trackBar.reset()
        trackBar.addObjectRect(type: .Normal, startDate: currentTime.dateByAddingTimeInterval(-1 * 60 * 60), endDate: currentTime.dateByAddingTimeInterval(1 * 60 * 60))
    }
    @IBAction func clickImportant(sender: UIButton) {
        let currentTime = trackBar.getCurrentTime()
        //        trackBar.reset()
        trackBar.addObjectRect(type: .Important, startDate: currentTime.dateByAddingTimeInterval(-1 * 60 * 60), endDate: currentTime.dateByAddingTimeInterval(1 * 60 * 60))
    }
    
    //MARK: TimeTrackBarDelgate
    func onTimePicked(date: NSDate, type: ObjectType) {
        timeLabel.text = dateformatterDate(date)
        
        switch type{
        case .Normal:
            typeLabel.text = "Normal"
        case .Important:
            typeLabel.text = "Important"
        case .Nothing:
            typeLabel.text = "Nothing"
        }
    }
    
    //MARK: Private Method
    func dateformatterDate(date: NSDate) -> String
    {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.stringFromDate(date)
        
        
    }
}

