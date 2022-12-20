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
    @State private var textToSend = "Sample text"
    @State private var name = "John Doe"

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Name") {
                        TextField("Name", text: $name)
                    }
                    Section("Send") {
                        TextField("text to send", text: $textToSend)
                        Button("Send Message") {
                            hubManager.sendMessage(textToSend)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                    }
                    Section("Received Messsages") {
                    Text(hubManager.chatMessage)
                        .frame(minHeight: 40.0)
                    }
                }
                Spacer()
            }
            .navigationTitle("Send Message")
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Connect") {
                        hubManager.connect(name)
                    }
                    .disabled(hubManager.isConnected || hubManager.isBusy)
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Disconnect") {
                        hubManager.disconnect()
                    }
                    .disabled(hubManager.isDisconnected || hubManager.isBusy || hubManager.isRunning)
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
                ToolbarItemGroup(placement:.bottomBar) {
                    Text(hubManager.statusMessage)
                        .padding(20)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
