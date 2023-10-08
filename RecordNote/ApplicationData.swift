//
//  ApplicationData.swift
//  RecordNote
//
//  Created by 이주환 on 2023/09/26.
//

import SwiftUI
import AVFoundation
import RealmSwift

class RealmRecord: Object {
    @Persisted(primaryKey: true) var name: String
    @Persisted var startDate: String
    @Persisted var endDate: String
    @Persisted var fav: Bool
    @Persisted var duration: Int
    @Persisted var tags: String
    
     convenience init(name: String, startDate: String, endDate: String, fav: Bool, duration: Int, tags: String) {
         self.init()
         self.name = name
         self.startDate = startDate
         self.endDate = endDate
         self.fav = fav
         self.duration = duration
         self.tags = tags
    }
    
    var getName: String {
        return name
    }
    var getStartDate: String {
        return startDate
    }
    var getEndDate: String {
        return endDate
    }
    var getFav: Bool {
        return fav
    }
    var getDuration: Int {
        return duration
    }
}

struct recordData: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var startDate: String
    var endDate: String
    var duration: Int = 0
    var durationInString: String = ""
    var fav: Bool
    var tags: String

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
    let realm = try! Realm()
    
    init() {
        recordInfo = []
        favRecordInfo = []
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = path.appendingPathComponent("recordNote")
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
            for i in contents {
                let temp = i.absoluteString.components(separatedBy: "/").last!.trimmingCharacters(in: [" "])
                if let temp = realm.object(ofType: RealmRecord.self, forPrimaryKey: temp) {
                    print("There is data in realm!")
                    temp.fav ? favRecordInfo.append(recordData(name: temp.name, startDate: temp.startDate, endDate: temp.endDate, fav: temp.fav, tags: temp.tags)) : recordInfo.append(recordData(name: temp.name, startDate: temp.startDate, endDate: temp.endDate, fav: temp.fav, tags: temp.tags))
                }
            }
        } catch {
            print("Error in init() of ApplicationData! or no such data in realm yet!")
        }
        print("recordInfo: ", recordInfo)
        print("favrecordInfo: ", favRecordInfo)
        
        
        
    }
    func generateRealmRecord(recordData: recordData) -> RealmRecord {
        return RealmRecord(name: recordData.name, startDate: recordData.startDate, endDate: recordData.endDate, fav: recordData.fav, duration: recordData.getDuration, tags: recordData.tags)
    }
    
    func addRecord(recordData: recordData) -> Void {
        recordInfo.append(recordData)
    }
    func addFavRecord(recordData: recordData) -> Void {
        favRecordInfo.append(recordData)
    }
    func addToRealm(data: RealmRecord) -> Void {
        try! realm.write {
            realm.add(data, update: .modified)
        }
    }
    func deleteFromRealm(url: String) -> Void {
        if let temp = realm.object(ofType: RealmRecord.self, forPrimaryKey: url) {
            try! realm.write {
                realm.delete(temp)
            }
        }
        else {
            print("No such Data in Realm!")
        }
    }
    
    func recToFav(index: Array.Index) -> Void {
        recordInfo[index].fav.toggle()
        favRecordInfo.append(recordInfo[index])
        addToRealm(data: generateRealmRecord(recordData: recordInfo[index]))
        recordInfo.remove(at: index)
    }
    
    func favToRec(index: Array.Index) -> Void {
        favRecordInfo[index].fav.toggle()
        recordInfo.append(favRecordInfo[index])
        addToRealm(data: generateRealmRecord(recordData: favRecordInfo[index]))
        favRecordInfo.remove(at: index)
    }
}
