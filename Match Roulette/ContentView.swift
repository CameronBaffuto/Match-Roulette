//
//  ContentView.swift
//  Match Mixer
//
//  Created by Cameron Baffuto on 3/29/23.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            ClubView()
                .tabItem {
                    Label("Clubs", systemImage: "checkerboard.shield")
                }
            InternationalView()
                .tabItem {
                    Label("International", systemImage: "flag.fill")
                }
        }
        .accentColor(.pink)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CustomColor {
    static let backgroundColor = Color("BackgroundColor")
    static let darkGreenColor = Color("DarkGreenColor")
    // Add more here...
}
