//
//  DateExtensions.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

extension Date{
    
    func year() -> Int {
        return Calendar.current.component(.year, from: self)
        
    }
    
    func month() -> Int {
        return Calendar.current.component(.month, from: self)
        
    }
    
    func day() -> Int {
        return Calendar.current.component(.day, from: self)
        
    }
    
    func toISO8601String() -> String{
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        return formatter.string(from: self)
    }
    
    func getYearMonthDayFromISO8601Date() -> (year:Int,month:Int,day:Int){
        let year = self.year()
        let month = self.month()
        let day = self.day()
        return (year:year,month:month,day:day)
    }
}
