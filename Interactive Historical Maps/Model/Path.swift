//
//  Path.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/2/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension Path {
//    var name: String?
//    var start: HistoricalDate
//    var end: HistoricalDate
    
    // var sequence: [Int : MKAnnotation] = [:]
    
    convenience init(on start: HistoricalDate, at location: CLLocationCoordinate2D) {
//        self.start = start
//        self.end = start

        let context = Model.shared.context
        let entity = NSEntityDescription.entity(forEntityName: "Path", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.set(start: start)
        self.set(end: end)
        
        self.sequence = NSDictionary(dictionary: [Int:MKAnnotation]())
        
//        let origin = MKPolyline(coordinates: [location], count: 1)
//        sequence[start.rawValue] = origin
//        (sequence as! NSDictionary).a
    }
    
   
}
