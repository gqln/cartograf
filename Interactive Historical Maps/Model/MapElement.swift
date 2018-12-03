//
//  MapElement.swift
//  Interactive Historical Maps
//
//  Created by Goki on 11/23/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation
import MapKit

protocol MapElement {
    var name : String? { get set }
    var start : HistoricalDate { get set }
    var end : HistoricalDate { get set }
    func annotation(for date: HistoricalDate) -> MKAnnotation
}
