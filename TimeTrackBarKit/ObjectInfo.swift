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
    var startDate:Date
    var endDate:Date
    
    init(filetype:ObjectType, startDate:Date, endDate:Date){
        self.filetype = filetype
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func compareTo(_ fileInfo:ObjectInfo) -> ComparisonResult{
        return self.startDate.compare(fileInfo.startDate)
    }
    
    func getStartMillis() -> TimeInterval{
        return self.startDate.timeIntervalSince1970 * 1000;
    }
    
    func getEndMillis() -> TimeInterval{
        return self.endDate.timeIntervalSince1970 * 1000;
    }
}
