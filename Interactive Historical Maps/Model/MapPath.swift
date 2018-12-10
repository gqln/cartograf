//
//  MapPath.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/9/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation
import MapKit

class MapPath: MapElement {
    var name: String? { didSet { path.name = name } }
    
    var start: HistoricalDate { return path.start }
    var end: HistoricalDate { return path.end }
    
    var path : Path
    
    var sequence : [Int : MKPolyline] = [:]
    
    var justAdded : MKOverlay?
    
    var textDescription: String? {
        didSet { path.textDescription = textDescription }
    }
    
    init(with path: Path) {
        self.path = path
        self.textDescription = path.textDescription != nil ? path.textDescription! : ""
    }
    
    init(on start: HistoricalDate, at coordinate: CLLocationCoordinate2D, on map: Map) {
        self.path = Path(on: start, at: coordinate)
        
        self.textDescription = ""
        
        self.path.map = map
        
        self.sequence = [:]
        let origin = MKPolyline(coordinates: [coordinate], count: 1)
        sequence[start.rawValue] = origin
        
    }
    
    func annotation(for date: HistoricalDate) -> MKAnnotation? {
        return polyline(for: date)
    }
    
    func last() -> MKPolyline {
        let keys = sequence.keys.sorted()
        let last = keys.last!
        let previous = sequence[last]!
        return previous
    }
    
    // Overlays with editing should be allowed to return nil
    func polyline(for date: HistoricalDate) -> MKPolyline? {
        let keys = sequence.keys.sorted().filter { (key) -> Bool in
            key <= date.rawValue
        }
        
        if keys.count > 0 {
            let last = keys.last!
            return sequence[last]!
        }
        return nil
    }
    
    func endPoint(at date: HistoricalDate) -> CLLocationCoordinate2D {
        let polyline = self.polyline(for: date)!
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
        self.path.set(end: date)
    }

}

