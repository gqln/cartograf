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
    var rawEra : Int { return rawYear >= 0 ? 1 : 0 }
    
    var rawInt32 : Int32 { return Int32(rawValue) }
    
    var month : String { return HistoricalDate.months[rawMonth] }
    var year : String {
        return rawYear >= 0 ? "\(rawYear) AD" : "\(abs(rawYear)) BC"
    }
    
    init(month: Int, year: Int) {
        rawValue = (year * 12 + month) * HistoricalDate.ticks
    }
    
    init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
    
    func change(year: Int) {
        let month = rawMonth
        let historicalDate = HistoricalDate(month: month, year: year)
        self.rawValue = historicalDate.rawValue
    }
    
    func change(month: Int) {
        let year = rawYear
        let historicalDate = HistoricalDate(month: month, year: year)
        self.rawValue = historicalDate.rawValue
    }
    
    func change(era: Int) {
        let month = rawMonth
        let year = Int(rawYear.magnitude)
        let adjusted = era == 0 ? -1 * year : 1 * year
        let historicalDate = HistoricalDate(month: month, year: adjusted)
        self.rawValue = historicalDate.rawValue
    }
    
    var description: String { return "\(month) \(year)" }
    var copy: HistoricalDate { return HistoricalDate(self.rawValue) }
    var past: HistoricalDate { return HistoricalDate(self.rawValue - 48 * HistoricalDate.ticks) }
    var future: HistoricalDate { return HistoricalDate(self.rawValue + 48 * HistoricalDate.ticks) }
    
    static let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    static let eras = ["BC", "AD"]
    
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
    
    static func <= (lhs: HistoricalDate, rhs: HistoricalDate) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    
    static func >= (lhs: HistoricalDate, rhs: HistoricalDate) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
}
