//
//  mainView.swift
//  todo
//
//  Created by Dagosh on 22.09.2025.
//

import SwiftUI

struct mainView: View {
    var body: some View {
        TabView {
            ContentView()
                .padding()
                .tabItem {
                    Image(systemName: "plus.app")

                    Text("Add page")
                }
                .tag(1)

            ExpiredTasksView()
                .padding()
                .tabItem {
                    Image(systemName: "eraser")
                    Text("Delete")
                }
                .tag(2)

        }
    }
}

