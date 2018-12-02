//
//  MapElement.swift
//  Interactive Historical Maps
//
//  Created by Goki on 11/23/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation
import MapKit
import CoreData

protocol MapElement {
    var title : String? { get set }
    var start : Int32 { get set }
    var end : Int32 { get set }
    var startDate : HistoricalDate { get }
    var endDate : HistoricalDate { get }
    func annotation(for date: HistoricalDate) -> MKAnnotation
}

@objc(Point)
class Point : NSManagedObject, MKAnnotation, MapElement {
    var title: String? = ""
    @NSManaged var start: Int32
    @NSManaged var end: Int32
    
    @NSManaged var latitude : Double
    @NSManaged var longitude : Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var startDate: HistoricalDate {
        return HistoricalDate(start)
    }
    var endDate: HistoricalDate {
        return HistoricalDate(end)
    }
    
    init(from start: HistoricalDate, to end: HistoricalDate, at coordinate: CLLocationCoordinate2D) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let description = NSEntityDescription.entity(forEntityName: "Point", in: context)!
        super.init(entity: description, insertInto: context)
        
        self.start = Int32(start.rawValue)
        self.end = Int32(end.rawValue)
        
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    class func keyPathsForValuesAffectingCoordinate() -> Set<String> {
        return Set<String>([ #keyPath(start), #keyPath(end) ])
    }
    
    func annotation(for date: HistoricalDate) -> MKAnnotation {
        return self
    }
}

class OverlayPath : NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    override init() {
        coordinate = CLLocationCoordinate2D.init(latitude: 0, longitude: 0)
        boundingMapRect =  MKMapRect(x: 0, y: 0, width: MKMapSize.world.width, height: MKMapSize.world.height)
    }
}

class PathRenderer : MKOverlayPathRenderer {
    let mapPath : Path
    init(_ mapPath: Path) {
        self.mapPath = mapPath
        super.init(overlay: mapPath)
    }
    
    override func createPath() {
        let mapPoints = mapPath.points(for: Model.shared.date)
        let points = mapPoints.map { (mapPoint) -> CGPoint in
            self.point(for: mapPoint)
        }
        let mutablePath = CGMutablePath()
        for point in points {
            mutablePath.move(to: point)
        }
        path = mutablePath
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        context.addPath(path)
        context.setStrokeColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setLineWidth(lineWidth)
        context.strokePath()
    }
}

@objc(Path)
class Path : NSManagedObject, MapElement, MKOverlay  {
    var title: String? = ""
    var start: Int32 = Int32.min
    var end: Int32 = Int32.max
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D.init(latitude: 0, longitude: 0)
    }
    
    var points: [HistoricalDate : MKMapPoint] = [:]
    
    var boundingMapRect: MKMapRect = MKMapRect.world
    
    var startDate: HistoricalDate {
        return HistoricalDate(start)
    }
    var endDate: HistoricalDate {
        return HistoricalDate(end)
    }
    
    var sequence: [Int : MKAnnotation] = [:]
    
    func annotation(for date: HistoricalDate) -> MKAnnotation {
        return polyline(for: date)
    }
    
    init(on start: HistoricalDate, at location: CLLocationCoordinate2D) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let description = NSEntityDescription.entity(forEntityName: "Path", in: context)!
        super.init(entity: description, insertInto: context)
        self.start = Int32(start.rawValue)
        self.end = Int32(start.rawValue + HistoricalDate.ticks)
        //        self.sequence = [:]
        let origin = MKPolyline(coordinates: [location], count: 1)
        self.sequence[start.rawValue] = origin
    }
    
    
    func points(for date: HistoricalDate) -> [MKMapPoint] {
        let keys = points.keys.sorted(by: { (date1, date2) -> Bool in
            date1 < date2
        }).filter { (key) -> Bool in
            key <= date
        }
        
        var filtered : [MKMapPoint] = []
        for key in keys {
            filtered.append(points[key]!)
        }
        
        return filtered
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
        // Bad fix, return optional
        if keys.count != 0 {
            let last = keys.last!
            return sequence[last] as! MKPolyline
        } else {
            return MKPolyline.init()
        }
    }
    
    func endPoint(at date: HistoricalDate) -> CLLocationCoordinate2D {
        let polyline = self.polyline(for: date)
        let count = polyline.pointCount
        let lastPoint = polyline.points()[count - 1]
        return lastPoint.coordinate
    }
    
    func extend(on date: HistoricalDate, to point: MKMapPoint) {
        sequence = sequence.filter({ (arg0) -> Bool in
            let (key, _) = arg0
            return key < date.rawValue
        })
        
        points = points.filter({ (arg0) -> Bool in
            let (key, _) = arg0
            return key < date
        })
        
        points[date] = point
        
//        let previous = self.last()
//        let newCount = previous.pointCount + 1
//        let mapPoints = previous.points()
//
//        var newCoordinates : [CLLocationCoordinate2D] = []
//
//        for i in 0..<newCount-1 {
//            let oldCoordinate = mapPoints[i].coordinate
//            newCoordinates.append(oldCoordinate)
//        }
//        newCoordinates.append(point)
//
//        let newLine = MKPolyline(coordinates: newCoordinates, count: newCount)
//        self.sequence[date.rawValue] = newLine
    }
    
    func end(on date: HistoricalDate) {
        self.end = Int32(date.rawValue)
    }
}

//class Region : MapElement {
//    var name: String?
//
//    var start: HistoricalDate
//
//    var end: HistoricalDate
//
//    func annotation(for date: HistoricalDate) -> MKAnnotation {
//        return MKPolygon(coordinates: nil, count: 0)
//    }
//}
