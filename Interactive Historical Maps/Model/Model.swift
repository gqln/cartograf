//
//  Model.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/1/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import Foundation

class Model {
    
    static let shared = Model()
    
    let maps : [Map]
    var date : HistoricalDate
    var currentMap : Map?
    
    private init() {
        maps = []
        date = HistoricalDate.init(month: 0, year: 0)
    }
}
