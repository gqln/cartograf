//
//  Point.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/2/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation
import MapKit

class Point : MKPointAnnotation, MapEntity, MapElement, ValidDateRangeDelegate {
    var name: String?
    var start: HistoricalDate
    var end: HistoricalDate
    var new: Bool
    
    var calloutView : CalloutView!
    
    init(from start: HistoricalDate, to end: HistoricalDate, at coordinate: CLLocationCoordinate2D) {
        
        self.start = start
        self.end = end
        self.new = false
        super.init()
        
        self.coordinate = coordinate
    }
    
    func annotation(for date: HistoricalDate) -> MKAnnotation {
        return self
    }
    
    func isValid(end newEnd: HistoricalDate) -> (valid: Bool, message: String) {
        if start < newEnd {
            return (true, "")
        } else {
            return (false, "End must occur after start.")
        }
    }
    
    func isValid(start newStart: HistoricalDate) -> (valid: Bool, message: String) {
        if newStart < end {
            return (true, "")
        } else {
            return (false, "Start must occur before end.")
        }
    }
}
