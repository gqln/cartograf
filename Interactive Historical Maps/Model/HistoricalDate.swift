//
//  HistoricalDate.swift
//  
//
//  Created by Goki on 11/25/18.
//

import Foundation

class HistoricalDate : CustomStringConvertible, Hashable {
    
    static let ticks : Int = 5
    
    var rawValue : Int
    var adjustedValue : Int { return rawValue / HistoricalDate.ticks }
    var rawMonth : Int { return (adjustedValue % 12 < 0) ? (adjustedValue % 12 + 12) : (adjustedValue % 12) }
    var rawYear : Int { return Int(floor(Double(adjustedValue) / 12.0)) }
    
    var month : String { return HistoricalDate.months[rawMonth] }
    var year : String {
        return rawYear >= 0 ? "\(rawYear) AD" : "\(abs(rawYear)) BC"
    }
    
    init(month: Int, year: Int) {
        rawValue = (year * 12 + month) * HistoricalDate.ticks
    }
    
    private init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init(_ rawValue: Int32) {
        self.rawValue = Int(rawValue)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
    
    var description: String { return "\(month) \(year)" }
    var copy: HistoricalDate { return HistoricalDate(self.rawValue) }
    
    static let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    static var zero : HistoricalDate { return HistoricalDate(month: 0, year: 0) }
    
    static func + (lhs: HistoricalDate, rhs: Int) -> HistoricalDate {
        return HistoricalDate(lhs.rawValue + rhs)
    }
    
    static func += (lhs: inout HistoricalDate, rhs: Int) {
        lhs.rawValue += rhs
    }
    
    static func == (lhs: HistoricalDate, rhs: HistoricalDate) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    static func < (lhs: HistoricalDate, rhs: HistoricalDate) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func > (lhs: HistoricalDate, rhs: HistoricalDate) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
    static func > (lhs: HistoricalDate, rhs: Int) -> Bool {
        return lhs.rawValue > rhs
    }
    
    static func <= (lhs: HistoricalDate, rhs: HistoricalDate) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    
    static func >= (lhs: HistoricalDate, rhs: HistoricalDate) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    
    static postfix func -- (lhs: inout HistoricalDate) {
        return lhs.rawValue -= 1
    }
}
