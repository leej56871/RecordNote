//
//  ApplicationData.swift
//  RecordNote
//
//  Created by 이주환 on 2023/09/26.
//

import Foundation
import AVFoundation
import RealmSwift

class RealmRecord: Object {
    @Persisted var name: String
    @Persisted (primaryKey: true) var startDate: String
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

class RealmNote: Object {
    @Persisted var name: String
    @Persisted (primaryKey: true) var date: String
    @Persisted var fav: Bool
    @Persisted var note: String
    
    convenience init(name: String, date: String, note: String, fav: Bool) {
        self.init()
        self.name = name
        self.date = date
        self.note = note
        self.fav = fav
    }
    
    var getName: String {
        return name
    }
    var getDate: String {
        return date
    }
    var getNote: String {
        return note
    }
}

struct noteData: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var note: String
    var date: String
    var fav: Bool
    
    var getName: String {
        return name
    }
    var getDate: String {
        return date
    }
    var getNote: String {
        return note
    }
    mutating func fixNote(newNote: String) -> Void {
        note = newNote
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
    @Published var recordInfo: [recordData] = []
    @Published var favRecordInfo: [recordData] = []
    @Published var noteInfo: [noteData] = []
    @Published var favNoteInfo: [noteData] = []
    let realm = try! Realm()
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    init() {
        let dir = path.appendingPathComponent("recordNote")
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
            for i in contents {
                let fileName = i.absoluteString.components(separatedBy: "/").last!.trimmingCharacters(in: [" "])
                if let temp = realm.object(ofType: RealmRecord.self, forPrimaryKey: fileName.components(separatedBy: ".").first!) {
                    temp.fav ? favRecordInfo.append(recordData(name: temp.name, startDate: temp.startDate, endDate: temp.endDate, duration: temp.getDuration, fav: temp.fav, tags: temp.tags)) : recordInfo.append(recordData(name: temp.name, startDate: temp.startDate, endDate: temp.endDate, duration: temp.getDuration, fav: temp.fav, tags: temp.tags))
                }
            }
        } catch {
            print("Error in init() of ApplicationData! or no such data in realm yet!")
        }
        let notes = realm.objects(RealmNote.self)
        for i in notes {
            i.fav ? favNoteInfo.append(noteData(name: i.name, note: i.note, date: i.date, fav: i.fav)) : noteInfo.append(noteData(name: i.name, note: i.note, date: i.date, fav: i.fav))
        }
    }
    
    func generateRealmRecord(recordData: recordData) -> RealmRecord {
        return RealmRecord(name: recordData.name, startDate: recordData.startDate, endDate: recordData.endDate, fav: recordData.fav, duration: recordData.getDuration, tags: recordData.tags)
    }
    
    func generateRealmNote(noteData: noteData) -> RealmNote {
        return RealmNote(name: noteData.name, date: noteData.date, note: noteData.note, fav: noteData.fav)
    }
    
    func addRecord(recordData: recordData) -> Void {
        recordInfo.append(recordData)
    }
    
    func addFavRecord(recordData: recordData) -> Void {
        favRecordInfo.append(recordData)
    }
    
    func addRecordToRealm(data: RealmRecord) -> Void {
        try! realm.write {
            realm.add(data, update: .modified)
        }
    }
    
    func addNoteToRealm(data: RealmNote) -> Void {
        try! realm.write {
            realm.add(data, update: .modified)
        }
    }
    
    func deleteRecord(date: String) -> Void {
        try! realm.write {
            let temp = realm.objects(RealmRecord.self).where {
                $0.startDate == date
            }
            realm.delete(temp)
        }
        do {
            let dir = path.appendingPathComponent("recordNote")
            let fileURL = dir.appendingPathComponent(date + ".m4a")
            try FileManager.default.removeItem(at: fileURL)
        } catch let e {
            print("Removal FileManager failed!")
            print(e.localizedDescription)
        }
    }
    
    func deleteNote(date: String) {
        try! realm.write {
            let temp = realm.objects(RealmNote.self).where {
                $0.date == date
            }
            realm.delete(temp)
        }
    }
    
    func recToFav(index: Array.Index) -> Void {
        recordInfo[index].fav.toggle()
        favRecordInfo.append(recordInfo[index])
        addRecordToRealm(data: generateRealmRecord(recordData: recordInfo[index]))
        recordInfo.remove(at: index)
    }
    
    func favToRec(index: Array.Index) -> Void {
        favRecordInfo[index].fav.toggle()
        recordInfo.append(favRecordInfo[index])
        addRecordToRealm(data: generateRealmRecord(recordData: favRecordInfo[index]))
        favRecordInfo.remove(at: index)
    }
    
    func addNote(noteData: noteData) -> Void {
        noteInfo.append(noteData)
        addNoteToRealm(data: generateRealmNote(noteData: noteData))
    }
    
    func updateNote(noteData: noteData) -> Void {
        let target = realm.objects(RealmNote.self).where {
            $0.getDate == noteData.getDate
        }.first!
        try! realm.write {
            target.name = noteData.getName
            target.note = noteData.getNote
            target.fav = noteData.fav
        }
        let after = realm.objects(RealmNote.self).where {
            $0.getDate == noteData.getDate
        }.first!
    }
    
    func noteToFav(index: Array.Index) -> Void {
        noteInfo[index].fav.toggle()
        favNoteInfo.append(noteInfo[index])
        addNoteToRealm(data: generateRealmNote(noteData: noteInfo[index]))
        noteInfo.remove(at: index)
    }
    
    func favToNote(index: Array.Index) -> Void {
        favNoteInfo[index].fav.toggle()
        noteInfo.append(favNoteInfo[index])
        addNoteToRealm(data: generateRealmNote(noteData: favNoteInfo[index]))
        favNoteInfo.remove(at: index)
    }
}
