//
//  FileInfo.swift
//  TimeBar
//
//  Created by JingWen on 2015/10/13.
//  Copyright © 2015年 JingWen. All rights reserved.
//

import UIKit

class ObjectInfo {
    var filetype:ObjectType
    var startDate:NSDate
    var endDate:NSDate
    
    init(filetype:ObjectType, startDate:NSDate, endDate:NSDate){
        self.filetype = filetype
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func compareTo(fileInfo:ObjectInfo) -> NSComparisonResult{
        return self.startDate.compare(fileInfo.startDate)
    }
    
    func getStartMillis() -> NSTimeInterval{
        return self.startDate.timeIntervalSince1970 * 1000;
    }
    
    func getEndMillis() -> NSTimeInterval{
        return self.endDate.timeIntervalSince1970 * 1000;
    }
}