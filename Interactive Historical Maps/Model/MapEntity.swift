//
//  MapElement.swift
//  Interactive Historical Maps
//
//  Created by Goki on 11/23/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation
import MapKit

protocol MapEntity {
    var name : String? { get set }
    var start : HistoricalDate { get }
    var end : HistoricalDate { get }
}

protocol MapElement : MapEntity {
    func annotation(for date: HistoricalDate) -> MKAnnotation?
}

extension Element : MapEntity {
    var start : HistoricalDate { return HistoricalDate(Int(self.startInt32)) }
    var end : HistoricalDate { return HistoricalDate(Int(self.endInt32)) }
    
    func set(start: HistoricalDate) {
        self.startInt32 = start.rawInt32
    }
    
    func set(end: HistoricalDate) {
        self.endInt32 = end.rawInt32
    }
}
