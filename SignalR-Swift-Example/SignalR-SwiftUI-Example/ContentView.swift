//
//  ContentView.swift
//  SignalR-SwiftUI-Example
//
//  Created by Bobby Williams on 12/19/22.
//  Copyright © 2022 Jordan Camara. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var hubManager = ConnectionHubManager.shared
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("STATUS: \(hubManager.statusMessage)")
                .padding(20)
            Text("MESSAGE: \(hubManager.chatMessage)")
            Button("Start") {
                hubManager.start()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            Button("Send Message") {
                hubManager.sendMessage("This is a test")
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
