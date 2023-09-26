//
//  ContentView.swift
//  RecordNote
//
//  Created by 이주환 on 2023/09/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appData: ApplicationData
    var body: some View {
        NavigationView {
            HStack {
                Spacer()
                NavigationLink(destination: RecordView()) {
                    Text("Record")
                        .padding()
                        .font(.largeTitle)
                        .frame(minWidth: 140)
                        .foregroundColor(Color.red)
                        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.red, lineWidth: 5))
                }
                Spacer()
                NavigationLink(destination: NoteView()) {
                    Text("Note")
                        .padding()
                        .font(.largeTitle)
                        .frame(minWidth: 140)
                        .foregroundColor(Color.yellow)
                        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.yellow, lineWidth: 5))
                }
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ApplicationData())
    }
}
