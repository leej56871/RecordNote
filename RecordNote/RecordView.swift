//
//  RecordView.swift
//  RecordNote
//
//  Created by 이주환 on 2023/09/27.
//

import SwiftUI
import AVFoundation

struct RecordView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State private var recordState: Bool = false
    @State private var playState: Bool = false
    @State private var tempStart: String = ""
    @State private var tempEnd: String = ""
    @State private var tempTags: [Int] = []
    @State private var currentRecord: recordData?
    @State private var currentURL: URL?
    @State private var rSession: recordSession?
    @State private var pSession: playSession?
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("Name")
                    .fontWeight(.bold)
                Spacer()
                Text("Duration")
                Spacer()
                Text("Fav")
            }
            .padding()
            Divider()
            ScrollView {
                LazyVStack {
                    ForEach(appData.favRecordInfo.indices, id: \.self) { index in
                        Button(action: {
                            currentRecord = appData.favRecordInfo[index]
                            let dir = path.appendingPathComponent("recordNote")
                            let fileURL = dir.appendingPathComponent(currentRecord!.getDate + ".m4a")
                            if !playState {
                                pSession = playSession(path: path)
                                pSession?.startPlaying(fileUrl: fileURL)
                                playState.toggle()
                            }
                            else {
                                pSession?.stopPlaying(url: fileURL)
                                playState.toggle()
                            }
                        }, label: {
                            HStack {
                                Text(appData.favRecordInfo[index].name)
                                Spacer()
                                Text(appData.favRecordInfo[index].durationInString)
                                Spacer()
                                Button(action: {
                                    appData.favRecordInfo[index].fav.toggle()
                                    appData.recordInfo.append(appData.favRecordInfo[index])
                                    appData.favRecordInfo.remove(at: index)
                                    
                                }, label: {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color.yellow)
                                })
                            }.padding()
                                .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
                        })
                    }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                    
                    ForEach(appData.recordInfo.indices, id: \.self) { index in
                        Button(action: { 
                            let dir = path.appendingPathComponent("recordNote")
                            currentRecord = appData.recordInfo[index]
                            let fileURL = dir.appendingPathComponent(currentRecord!.getDate + ".m4a")
                            if !playState {
                                pSession = playSession(path: path)
                                pSession?.startPlaying(fileUrl: fileURL)
                                playState.toggle()
                            }
                            else {
                                pSession?.stopPlaying(url: fileURL)
                                playState.toggle()
                            }
                        }, label: {
                            HStack {
                                Text(appData.recordInfo[index].name)
                                Spacer()
                                Text(appData.recordInfo[index].durationInString)
                                Spacer()
                                Button(action: {
                                    appData.recordInfo[index].fav.toggle()
                                    appData.favRecordInfo.append(appData.recordInfo[index])
                                    appData.recordInfo.remove(at: index)
                                }, label: {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color.gray)
                                })
                            }.padding()
                                .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
                        })
                    }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                    
                }
            }
            Spacer()
            VStack {
                Image(systemName: "waveform")
                    .resizable()

            }.padding()
                .opacity(recordState ? 1 : 0)
            Button(action: {
                let dir = path.appendingPathComponent("recordNote")
                recordState.toggle()
                if recordState {
                    tempStart = dateFormatter(date: Date())
                    currentRecord = recordData(name: tempStart, startDate: tempStart, endDate: "0000-00-00-00-00-00", fav: false, tags: [])
                    rSession = recordSession(record: currentRecord!, path: path)
                    rSession!.startRecording()
                }
                else {
                    tempEnd = dateFormatter(date: Date())
                    rSession!.stopRecording()
                    currentRecord!.endDate = tempEnd
                    currentRecord!.calculateDuration(startDate: currentRecord!.startDate, endDate: currentRecord!.endDate)
                    currentRecord!.url = dir.appendingPathComponent(currentRecord!.startDate + "m4a")
                    appData.addRecord(recordData: currentRecord!)
                }
                }, label: {
                    Image(systemName: recordState ? "pause.circle" : "record.circle")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color.red)
            })
        }.onAppear(perform: {
            
        })
    }
    
}

class recordSession {
    var session = AVAudioSession.sharedInstance()
    var recorder: AVAudioRecorder!
    var recordState: Bool = false
    var record: recordData
    var recordHistory: [recordData] = []
    let path: URL
    let dir: URL
    
    init(record: recordData, path: URL) {
        self.record = record
        self.path = path
        self.dir = path.appendingPathComponent("recordNote")
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: false)
        } catch {
            print("Failed to make a directory")
        }
    }
    
    func startRecording() -> Void {
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Error")
        }
        let filePath = dir.appendingPathComponent(record.getDate + ".m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: filePath, settings: settings)
            recorder.prepareToRecord()
            recorder.record()
            recordState = true
        } catch {
            print("Error2")
        }
    }
    
    func stopRecording() {
        recorder.stop()
        recordState = false
    }
    
}

class playSession {
    var session = AVAudioSession.sharedInstance()
    var player: AVAudioPlayer!
    let path: URL
    let dir: URL
    
    init(path: URL) {
        self.path = path
        self.dir = path.appendingPathComponent("recordNote")
    }
    
    func startPlaying(fileUrl: URL) {
        do {
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Error3")
        }
        
        do {
            let result = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            for i in result {
                print("file url is \(fileUrl)")
                print(i)
                print("dir is \(dir)")
            }
            player = try AVAudioPlayer(contentsOf: fileUrl)
            player.prepareToPlay()
            player.play()
            
        } catch {
            print("Error4")
        }
                                        
    }
    
    func stopPlaying(url: URL) {
        player.stop()
    }
}

struct RecordView_previews: PreviewProvider {
    static var previews: some View {
        RecordView()
            .environmentObject(ApplicationData())
    }
}
