//
//  SwiftUI View.swift
//  todo
//
//  Created by Dagosh on 26.04.2025.
//
    import SwiftUI

    struct final: View {
        var body: some View {
            TabView {
                ContentView()
                    .padding()
                    .tabItem {
                        Image(systemName: "plus.app")
                        
                        Text("Add page")
                    }
                    .tag(1)
                
                time()
                    .padding()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Upcoming")
                    }
                    .tag(2)
                important()
                    .padding()
                    .tabItem {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Important")
                    }
                    .tag(3)
                deleter()
                    .padding()
                    .tabItem {
                        Image(systemName: "eraser")
                        Text("Delete")
                    }
                    .tag(4)
            }}}


    #Preview {
        final()
    }

