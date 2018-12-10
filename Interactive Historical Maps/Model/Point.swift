//
//  Point.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/2/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation
import MapKit
import CoreData

let model = Model.shared

extension Point {

    convenience init(from start: HistoricalDate, to end: HistoricalDate, at coordinate: CLLocationCoordinate2D) {
    
        let entity = NSEntityDescription.entity(forEntityName: "Point", in: model.context)!
        
        self.init(entity: entity, insertInto: model.context)
        self.set(start: start)
        self.set(end: end)
        
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
