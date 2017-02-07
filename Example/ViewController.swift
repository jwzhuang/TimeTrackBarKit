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
    
    override func viewDidAppear(_ animated: Bool) {
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
    @IBAction func clickNormal(_ sender: UIButton) {
        let currentTime = trackBar.getCurrentTime()
        //        trackBar.reset()
        trackBar.addObjectRect(.normal, startDate: currentTime.addingTimeInterval(-1 * 60 * 60), endDate: currentTime.addingTimeInterval(1 * 60 * 60))
    }
    @IBAction func clickImportant(_ sender: UIButton) {
        let currentTime = trackBar.getCurrentTime()
        //        trackBar.reset()
        trackBar.addObjectRect(.important, startDate: currentTime.addingTimeInterval(-1 * 60 * 60), endDate: currentTime.addingTimeInterval(1 * 60 * 60))
    }
    
    //MARK: TimeTrackBarDelgate
    func onTimePicked(_ date: Date, type: ObjectType) {
        timeLabel.text = dateformatterDate(date)
        
        switch type{
        case .normal:
            typeLabel.text = "Normal"
        case .important:
            typeLabel.text = "Important"
        case .nothing:
            typeLabel.text = "Nothing"
        }
    }
    
    //MARK: Private Method
    func dateformatterDate(_ date: Date) -> String
    {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: date)
        
        
    }
}

