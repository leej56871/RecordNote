//
//  NoteView.swift
//  RecordNote
//
//  Created by 이주환 on 2023/09/27.
//

import SwiftUI

struct NoteView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State private var currentURL: URL?
    @State private var targetIndex: Array.Index?
    @State private var targetBool: Bool?
    @State private var editState: Bool = false
    @State private var newNoteState: Bool = true
    
    var body: some View {
        return Group {
            NavigationView {
                if !editState {
                    NoteListView(targetIndex: $targetIndex, targetBool: $targetBool, editState: $editState, newNoteState: $newNoteState)
                }
                else {
                    NoteEditView(targetIndex: $targetIndex, targetBool: $targetBool, editState: $editState, newNoteState: $newNoteState)
                }
            }.navigationBarBackButtonHidden(editState)
        }
    }
}

struct NoteListView: View {
    @EnvironmentObject private var appData: ApplicationData
    @Binding var targetIndex: Array.Index?
    @Binding var targetBool: Bool?
    @Binding var editState: Bool
    @Binding var newNoteState: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Notes")
                    .font(.title)
                    .bold()
                Spacer()
            }.padding()
            Divider()
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    appData.addNote(noteData: noteData(name: "untitled", note: "Write note here", date: dateFormatter(date: Date()), fav: false))
                    editState.toggle()
                    newNoteState = true
                    targetBool = false
                    targetIndex = appData.noteInfo.endIndex - 1
                }, label: {
                    Image(systemName: "plus")
                        .font(.title)
                })
            }.padding()
            Spacer()
            VStack {
                List {
                    ForEach(appData.favNoteInfo.indices, id: \.self) { index in
                        Button(action: {
                            editState.toggle()
                            targetBool = true
                            targetIndex = index
                        }, label: {
                            Text(appData.favNoteInfo[index].getName)
                                .font(.title)
                        })
                        
                    }.onDelete(perform: { indexSet in
                        appData.deleteNote(date: appData.favNoteInfo[indexSet.first!].getDate)
                        appData.favNoteInfo.remove(atOffsets: indexSet)
                    })
                    ForEach(appData.noteInfo.indices, id: \.self) { index in
                        Button(action: {
                            editState.toggle()
                            targetBool = false
                            targetIndex = index
                        }, label: {
                            Text(appData.noteInfo[index].getName)
                                .font(.title)
                        })
                    }.onDelete(perform: { indexSet in
                        appData.deleteNote(date: appData.noteInfo[indexSet.first!].getDate)
                        appData.noteInfo.remove(atOffsets: indexSet)
                    })
                }.padding()
                    .listStyle(PlainListStyle())
            }
        }
    }
}

struct NoteEditView: View {
    @EnvironmentObject var appData: ApplicationData
    @Binding var targetIndex: Array.Index?
    @Binding var targetBool: Bool?
    @Binding var editState: Bool
    @Binding var newNoteState: Bool
    
    var body: some View {
        VStack {
            HStack {
                TextField("", text: targetBool! ? $appData.favNoteInfo[targetIndex!].name : $appData.noteInfo[targetIndex!].name)
                    .padding()
                Spacer()
                Button(action: {
                    if newNoteState {
                        targetIndex = appData.noteInfo.endIndex - 1
                        targetBool = false
                    }
                    appData.updateNote(noteData: targetBool! ? appData.favNoteInfo[targetIndex!] : appData.noteInfo[targetIndex!])
                    newNoteState = false
                    editState = false
                }, label: {
                    Text("Save")
                        .foregroundStyle(Color.blue)
                })
            }.padding()
                .frame(height: 100)
            Divider()
            // Bug or an errror using TextEditor so used TextField
            TextField("", text: targetBool! ? $appData.favNoteInfo[targetIndex!].note : $appData.noteInfo[targetIndex!].note, axis: .vertical)
                    .padding()
                    .allowsTightening(true)
                    .background(Color.gray)
            Spacer()
        }.padding()
    }
}
