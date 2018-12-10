//
//  MapPoint.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/9/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation
import MapKit

class MapPoint: MKPointAnnotation, MapElement {

    var name: String? { didSet { point.name = name } }
    var new: Bool = false
    
    var calloutView : CalloutView!
    var point : Point
    
    var start : HistoricalDate { didSet { point.startInt32 = start.rawInt32 } }
    var end : HistoricalDate { didSet { point.endInt32 = end.rawInt32 } }
    
    var textDescription: String? {
        didSet { point.textDescription = textDescription }
    }
    
    override var coordinate : CLLocationCoordinate2D {
        didSet {
            point.latitude = coordinate.latitude
            point.longitude = coordinate.longitude
        }
    }
    
    init(with point: Point) {
        self.point = point
        self.start = point.start
        self.end = point.end
        self.name = point.name
        self.textDescription = point.textDescription != nil ? point.textDescription! : ""
        
        super.init()
        
        self.coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
    }
    
    init(from start: HistoricalDate, to end: HistoricalDate, at coordinate: CLLocationCoordinate2D, on map: Map) {
        self.point = Point(from: start, to: end, at: coordinate)
        self.start = start
        self.end = end
        self.textDescription = ""
        
        self.point.map = map
        
        super.init()
        
        self.coordinate = coordinate
    }
    
    func annotation(for date: HistoricalDate) -> MKAnnotation? {
        return self
    }

    
}
