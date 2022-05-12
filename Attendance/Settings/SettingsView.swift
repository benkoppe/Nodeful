//
//  SettingsView.swift
//  Attendance
//
//  Created by Ben K on 9/17/21.
//

import SwiftUI
import Introspect

enum AddModes: String, CaseIterable, Equatable {
    case tap, swipe, both
    var id: String { self.rawValue.capitalized }
}

struct SettingsView: View {
    @EnvironmentObject var memberArray: MemberArray
    
    @Environment(\.dismiss) var dismiss
    @State private var history = false
    
    var body: some View {
        //NavigationView {
            Form {
                AddModePicker()
                NameModePicker()
                ChunkSettings()
                if UIDevice.current.userInterfaceIdiom == .phone {
                    SearchModePicker()
                }
                ColorSchemePicker()
                NameBox()
                UrlBox()
                ResetAll()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("History") {
                        history = true
                    }
                }
            }
            .sheet(isPresented: $history) {
                HistoryView()
            }
        //}
    }
    
    struct AddModePicker: View {
        @AppStorage("AddMode") var addMode: AddModes = .tap
        
        var body: some View {
            Section {
                Picker("Add Mode", selection: $addMode) {
                    ForEach(AddModes.allCases, id: \.self) {
                        Text($0.id)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Add Mode")
            } footer: {
                Text("The way you will add students to the attendance.")
            }
        }
    }
    
    struct NameModePicker: View {
        @AppStorage("nameMode") var nameMode: NameModes = .first
        
        var body: some View {
            Section {
                Picker("Name Mode", selection: $nameMode) {
                    ForEach(NameModes.allCases, id: \.self) {
                        Text($0.id)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Name Mode")
            } footer: {
                Text("This will determine how names are sorted and displayed.")
            }
        }
    }
    
    struct ChunkSettings: View {
        @EnvironmentObject var memberArray: MemberArray
        
        @AppStorage("chunksEnabled") var chunksEnabled: Bool = false
        @AppStorage("totalChunks") var totalChunks: Int = 4
        @AppStorage("yourChunk") var yourChunk: Int = 0
        
        var chunkedMembers: [[Member]] {
            memberArray.makeChunks(count: totalChunks)
        }
        
        var body: some View {
            Section {
                HStack {
                    Toggle("Enable Splitting", isOn: $chunksEnabled.animation())
                        .labelsHidden()
                        .tint(.blue)
                    Spacer()
                    Stepper("Total Chunks", value: $totalChunks, in: 2...8)
                        .labelsHidden()
                        .onChange(of: totalChunks) { totalChunks in
                            if totalChunks <= yourChunk {
                                self.yourChunk = totalChunks - 1
                            }
                        }
                        .disabled(!chunksEnabled)
                }
                
                if chunksEnabled {
                    VStack {
                        HStack {
                            Spacer()
                            ForEach(chunkedMembers.count > 3 ? 0..<4 : 0..<chunkedMembers.count, id: \.self) { index in
                                let chunk = chunkedMembers[index]
                                if let first = chunk.first?.lastName, let last = chunk.last?.lastName {
                                    Button(action: {
                                        yourChunk = index
                                    }) {
                                        Text(makeInsideText(index: index, first: first, last: last))
                                            .foregroundColor(index == yourChunk ? .blue : .primary)
                                            .minimumScaleFactor(0.2)
                                            .lineLimit(1)
                                    }
                                    .buttonStyle(.plain)
                                    Spacer()
                                    if index != 3 && index + 1 != chunkedMembers.count {
                                        Divider()
                                            .frame(minHeight: 1)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        if chunkedMembers.count > 4 {
                            Divider()
                            HStack {
                                Spacer()
                                ForEach(4..<chunkedMembers.count, id: \.self) { index in
                                    let chunk = chunkedMembers[index]
                                    if let first = chunk.first?.lastName, let last = chunk.last?.lastName {
                                        Button(action: {
                                            yourChunk = index
                                        }) {
                                            Text(makeInsideText(index: index, first: first, last: last))
                                                .foregroundColor(index == yourChunk ? .blue : .primary)
                                                .minimumScaleFactor(0.2)
                                                .lineLimit(1)
                                        }
                                        .buttonStyle(.plain)
                                        Spacer()
                                        if index + 1 != chunkedMembers.count {
                                            Divider()
                                                .frame(minHeight: 1)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } header: {
                Text("Alphabetical Chunking")
            } footer: {
                Text("Set your app to only display a specific portion of students, separated by last name.")
            }
        }
        
        func makeInsideText(index: Int, first: String, last: String) -> String {
            var finFirst = ""
            var finLast = ""
            if index > 0, let before = chunkedMembers[index - 1].last?.lastName.prefix(2), before == first.prefix(2) {
                finFirst = String(first.prefix(3))
            } else {
                finFirst = String(first.prefix(2))
            }
            if index < chunkedMembers.count - 1, let after = chunkedMembers[index + 1].first?.lastName.prefix(2), after == last.prefix(2) {
                finLast = String(last.prefix(3))
            } else {
                finLast = String(last.prefix(2))
            }
            return "\(finFirst) - \(finLast)"
        }
    }
    
    struct SearchModePicker: View {
        @AppStorage("alwaysSearch") var searchMode: Bool = true
        
        var body: some View {
            Section {
                Toggle("Always show search", isOn: $searchMode)
            } header: {
                Text("Search Mode")
            } footer: {
                Text("This will make the search bar always show, rather than only at the top.")
            }
        }
    }
    
    struct ColorSchemePicker: View {
        @AppStorage("colorScheme") var colorScheme: colorScheme = .system
        
        var body: some View {
            Section {
                Picker("Color Scheme", selection: $colorScheme) {
                    Text("System").tag(Nodeful.colorScheme.system)
                    Text("Dark").tag(Nodeful.colorScheme.dark)
                    Text("Light").tag(Nodeful.colorScheme.light)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Color Scheme")
            }
        }
    }
    
    struct NameBox: View {
        @AppStorage("names") var names: [String] = []
        @State private var inputNames: String = ""
        
        @FocusState private var isSelected: Bool
        
        var body: some View {
            Section {
                ZStack {
                    if inputNames.isEmpty {
                        TextEditor(text: .constant("Enter names here"))
                            .foregroundColor(.secondary)
                            .frame(height: 200)
                            .disabled(true)
                    }
                    
                    TextEditor(text: $inputNames)
                        .onAppear {
                            inputNames = names.joined(separator: "\n")
                        }
                        .disableAutocorrection(true)
                        .keyboardType(.asciiCapable)
                        .focused($isSelected)
                        .onChange(of: inputNames) { newValue in
                            names = newValue.components(separatedBy: "\n")
                            NotificationCenter.default.post(name: NSNotification.NameUpdate, object: nil, userInfo: nil)
                        }
                        .frame(height: 200)
                }
            } header: {
                HStack {
                    Text("Names")
                    Spacer()
                    Button("Done") {
                        isSelected = false
                    }
                    .disabled(!isSelected)
                }
            } footer: {
                Text("All student names. Enter each name on a new line. Press 'save' to save changes. All names must have a first and last name!")
            }
        }
    }
    
    struct UrlBox: View {
        @AppStorage("url") var url: String = ""
        
        var body: some View {
            Section {
                TextField("Google URL", text: $url)
                    .disableAutocorrection(true)
                    .keyboardType(.asciiCapable)
            } header: {
                Text("Script URL")
            } footer: {
                Text("URL used by app for connected spreadsheet. The setup tutorial video can be accessed [here](https://benkoppe.netlify.app/nodeful/setup/)")
            }
        }
    }
    
    struct ResetAll: View {
        @Environment(\.dismiss) var dismiss
        @State private var showWarning = false
        
        var body: some View {
            Section {
                Button("Permanently Reset Everything", role: .destructive) {
                    showWarning = true
                }
            } header: {
                Text("Reset Everything")
            } footer: {
                Text("This will erase all app content and restart.")
            }
            .alert("Are you sure?", isPresented: $showWarning, actions: {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    dismiss()
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
                }
            }, message: {
                Text("This action cannot be undone. Everything will be erased, including names and history.")
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
