//
//  ContentView.swift
//  Attendance
//
//  Created by Ben K on 9/17/21.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    
    var body: some View {
        NavigationView {
            MemberList()
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $firstLaunch) {
            SetupView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
