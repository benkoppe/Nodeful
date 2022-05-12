//
//  SetupView.swift
//  Attendance
//
//  Created by Ben K on 5/9/22.
//

import SwiftUI

struct SetupView: View {
    @State private var tab = 0
    
    var body: some View {
        TabView(selection: $tab) {
            WelcomeView(tab: $tab)
                .tag(0)
            InputView()
                .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .interactiveDismissDisabled()
    }
    
    struct WelcomeView: View {
        @Binding var tab: Int
        
        var body: some View {
            VStack(spacing: 30) {
                Text("Welcome!")
                    .font(.system(size: 60))
                    .bold()
                    .foregroundColor(.primary)
                Text("This app requires a little setup. Please open [this video](https://benkoppe.netlify.app/nodeful/setup/) on a separate computer and follow its instructions.")
                    .italic()
                    .padding(.horizontal)
                    .padding(.vertical, 1)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    withAnimation { tab = 1 }
                }) {
                    Text("Next \(Image(systemName: "chevron.right"))")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .padding()
            }
            .padding()
        }
    }
    
    struct InputView: View {
        let placeholder = "Enter all names here, with each new name on a new line. All names must have first and last names!"
        @State private var inputNames: String = "Enter all names here, with each new name on a new line. All names must have first and last names!"
        
        @AppStorage("names") var names: [String] = []
        @AppStorage("url") var url: String = ""
        
        @Environment(\.dismiss) var dismiss
        
        enum FocusedField {
            case name, url
        }
        @FocusState private var focusedField: FocusedField?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                HStack {
                    Spacer()
                    Text("Setup")
                        .font(.system(size: 40))
                        .bold()
                    Spacer()
                }
                .padding()
                
                Text("Name List")
                    .font(.headline)
                    .padding([.top, .horizontal])
                    .padding(.bottom, 10)
                TextEditor(text: $inputNames)
                    .padding(5)
                    .frame(height: 200)
                    .disableAutocorrection(true)
                    .keyboardType(.asciiCapable)
                    .focused($focusedField, equals: .name)
                    .overlay (
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
                    .foregroundColor(self.inputNames == placeholder ? .tertiaryLabel : .primary)
                    .onTapGesture {
                        if self.inputNames == placeholder {
                            self.inputNames = ""
                        }
                    }
                    .onChange(of: inputNames) { newValue in
                        names = newValue.components(separatedBy: "\n")
                    }
                
                Text("Google URL")
                    .font(.headline)
                    .padding([.top, .horizontal])
                    .padding(.bottom, 10)
                TextField("https://script.google.com/macros/s/...", text: $url)
                    .padding(7)
                    .overlay (
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
                    .disableAutocorrection(true)
                    .keyboardType(.asciiCapable)
                    .focused($focusedField, equals: .url)
                    .submitLabel(.done)
                
                
                Spacer()
                
                HStack {
                    let isDisabled = ( (inputNames.isEmpty || inputNames == placeholder) || url.isEmpty)
                    
                    Spacer()
                    Button(action: {
                        NotificationCenter.default.post(name: NSNotification.NameUpdate, object: nil, userInfo: nil)
                        dismiss()
                    }) {
                        Text("Get Started \(Image(systemName: "chevron.down"))")
                            .foregroundColor(.white)
                            .padding()
                            .background(isDisabled ? Color.gray : Color.blue)
                            .animation(.default, value: inputNames)
                            .animation(.default, value: url)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, 50)
                    .disabled(isDisabled)
                    Spacer()
                }
            }
            .padding()
        }
    }
    
    
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
            .preferredColorScheme(.dark)
    }
}
