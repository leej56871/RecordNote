//
//  ApplicationData.swift
//  RecordNote
//
//  Created by 이주환 on 2023/09/26.
//

import SwiftUI
import AVFoundation

struct recordData: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var startDate: String
    var endDate: String
    var duration: Int = 0
    var durationInString: String = ""
    var fav: Bool
    var tags: [String]
    var url: URL?

    var getName: String {
        return name
    }
    var getDuration: Int {
        return duration
    }
    var getDate: String {
        return startDate
    }
    
    mutating func stringToTime(time: String) -> Void {
        var minute: Int = Int(time)! / 60
        let hour: Int = minute / 60
        let second: Int = Int(time)! % 60
        var result: String
        
        var minuteInString: String = String(minute)
        var hourInString: String = String(hour)
        var secondInString: String = String(second)
        
        if minute < 10 {
            minuteInString = "0" + minuteInString
        }
        if hour < 10 {
            hourInString = "0" + hourInString
        }
        if second < 10 {
            secondInString = "0" + secondInString
        }
        minute = minute - 60 * hour
        result = hourInString + ":" + minuteInString + ":" + secondInString
        durationInString = result
    }
    
    mutating func calculateDuration(startDate: String, endDate: String) -> Void {
        let startDateArray = startDate.components(separatedBy: "-")
        let endDateArray = endDate.components(separatedBy: "-")
        print(startDateArray)
        print(endDateArray)
        
        var diff: [Int] = []
        var result = 0
        for i in startDateArray.indices {
            diff.append(Int(endDateArray[i])! - Int(startDateArray[i])!)
        }
        result += diff[0] * 31536000
        result += diff[1] * 2592000
        result += diff[2] * 86400
        result += diff[3] * 3600
        result += diff[4] * 60
        result += diff[5]
        
        duration = result
        stringToTime(time: String(result))
    }
}

public func dateFormatter(date: Date) -> String {
    let dateFormmater = DateFormatter()
    dateFormmater.dateFormat = "yyyy-MM-dd-HH-mm-ss"
    let result = dateFormmater.string(from: date)
    return result
}

class ApplicationData: ObservableObject {
    @Published var recordInfo: [recordData]
    @Published var favRecordInfo: [recordData]
    init() {
        recordInfo = []
        favRecordInfo = []
    }
    
    func addRecord(recordData: recordData) -> Void {
        recordInfo.append(recordData)
    }
    func addFavRecord(recordData: recordData) -> Void {
        favRecordInfo.append(recordData)
    }
}
