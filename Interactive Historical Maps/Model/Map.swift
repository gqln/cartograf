//
//  Map.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/1/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation

extension Map : MapEntity {

    var start : HistoricalDate { return HistoricalDate(Int(self.startInt32)) }
    var end : HistoricalDate { return HistoricalDate(Int(self.endInt32)) }
    
    var points : [MapPoint] {
        guard elements != nil else { return [] }
        guard let CDElements = Array(elements!) as? [Element] else { return [] }
        
        let CDFiltered = CDElements.filter { (element) -> Bool in element is Point }
        guard let CDPoints = CDFiltered as? [Point] else { return [] }
        let mapPoints = CDPoints.map({ (point) -> MapPoint in
            MapPoint(with: point)
        })
        return mapPoints
    }
    var paths : [MapPath] {
        return []
//        let CDElements = Array(elements!) as! [Element]
//        let CDPaths = CDElements.filter { (element) -> Bool in
//            element is Path
//        } as! [Path]
//        let mapPaths = CDPaths.map({ (path) -> MapPath in
//            MapPath(with: path)
//        })
//        return mapPaths
    }
    
    func set(start: HistoricalDate) {
        self.startInt32 = start.rawInt32
    }
    
    func set(end: HistoricalDate) {
        self.endInt32 = end.rawInt32
    }
}
