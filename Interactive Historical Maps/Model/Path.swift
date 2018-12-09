//
//  Path.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/2/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation
import MapKit

class Path : MapEntity, MapElement, ValidDateRangeDelegate {
    var name: String?
    var start: HistoricalDate
    var end: HistoricalDate
    
    var sequence: [Int : MKAnnotation]
    
    func annotation(for date: HistoricalDate) -> MKAnnotation {
        return polyline(for: date)
    }
    
    init(on start: HistoricalDate, at location: CLLocationCoordinate2D) {
        self.start = start
        self.end = start
        self.sequence = [:]
        let origin = MKPolyline(coordinates: [location], count: 1)
        sequence[start.rawValue] = origin
    }
    
    func last() -> MKPolyline {
        let keys = sequence.keys.sorted()
        let last = keys.last!
        let previous = sequence[last] as! MKPolyline
        return previous
    }
    
    // Overlays with editing should be allowed to return nil
    func polyline(for date: HistoricalDate) -> MKPolyline {
        let keys = sequence.keys.sorted().filter { (key) -> Bool in
            key <= date.rawValue
        }
        
        // FIX ERROR, return optional
        
        let last = keys.last!
        return sequence[last] as! MKPolyline
    }
    
    func endPoint(at date: HistoricalDate) -> CLLocationCoordinate2D {
        let polyline = self.polyline(for: date)
        let count = polyline.pointCount
        let lastPoint = polyline.points()[count - 1]
        return lastPoint.coordinate
    }
    
    func extend(on date: HistoricalDate, to point: CLLocationCoordinate2D) {
        sequence = sequence.filter({ (arg0) -> Bool in
            let (key, _) = arg0
            return key < date.rawValue
        })
        
        let previous = self.last()
        let newCount = previous.pointCount + 1
        let points = previous.points()
        
        var newCoordinates : [CLLocationCoordinate2D] = []
        
        for i in 0..<newCount-1 {
            let oldCoordinate = points[i].coordinate
            newCoordinates.append(oldCoordinate)
        }
        newCoordinates.append(point)
        
        let newLine = MKPolyline(coordinates: newCoordinates, count: newCount)
        self.sequence[date.rawValue] = newLine
    }
    
    func end(on date: HistoricalDate) {
        self.end = date
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
