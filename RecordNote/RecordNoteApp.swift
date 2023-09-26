//
//  RecordNoteApp.swift
//  RecordNote
//
//  Created by 이주환 on 2023/09/26.
//

import SwiftUI

@main
struct RecordNoteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ApplicationData())
        }
    }
}
