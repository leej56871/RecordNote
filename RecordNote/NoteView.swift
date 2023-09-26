//
//  NoteView.swift
//  RecordNote
//
//  Created by 이주환 on 2023/09/27.
//

import SwiftUI

struct NoteView: View {
    @EnvironmentObject private var appData: ApplicationData
    
    var body: some View {
        VStack {
            Text("Note View")
        }
    }
}

struct NoteView_previews: PreviewProvider {
    static var previews: some View {
        NoteView().environmentObject(ApplicationData())
    }
}
