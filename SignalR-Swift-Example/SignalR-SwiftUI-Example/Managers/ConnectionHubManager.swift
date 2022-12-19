//
//  ConnectionHubManager.swift
//  SignalR-SwiftUI-Example
//
//  Created by Bobby Williams on 12/19/22.
//  Copyright © 2022 Jordan Camara. All rights reserved.
//

import SwiftUI
import SignalRSwift

class ConnectionHubManager: ObservableObject {
    static var shared = ConnectionHubManager()

    private var chatHub: HubProxy!
    private var connection: HubConnection!
    var name: String!
    @Published var statusMessage = ""
    @Published var chatMessage = ""

//    let serverURL = "http://swiftr.azurewebsites.net"
//    let hubName   = "chatHub"
    let serverURL = "http://10.0.1.23:8080/kioskHub"
    let hubName   = "kioskHub"

    init() {
        start()
    }

    func connect() {
        connection.start()
    }

    func sendMessage(_ message: String) {
        if let hub = chatHub {
            hub.invoke(method: "send", withArgs: [name ?? "Name: ", message])
        }
    }

    func start() {
        name = "Bobby Williams"
        connection = HubConnection(withUrl: serverURL) //SignalR("http://swiftr.azurewebsites.net")
        //        connection.signalRVersion = .v2_2_0

        chatHub = self.connection.createHubProxy(hubName: hubName)
        
        _ = chatHub.on(eventName: "broadcastMessage") { args in
            let text = self.chatMessage
            if let name = args[0] as? String, let message = args[1] as? String {
                self.chatMessage = "\(text)\n\n\(name): \(message)"
            }
        }

        // SignalR events

        connection.started = { [unowned self] in
            self.statusMessage = "Connected"
            print("BJW status: \((self.statusMessage))")
//            self.startButton.isEnabled = true
//            self.startButton.title = "Stop"
//            self.sendButton.isEnabled = true
        }

        connection.reconnecting = { [unowned self] in
            self.statusMessage = "Reconnecting..."
        }

        connection.reconnected = { [unowned self] in
            self.statusMessage = "Reconnected. Connection ID: \(self.connection!.connectionId!)"
//            self.startButton.isEnabled = true
//            self.startButton.title = "Stop"
//            self.sendButton.isEnabled = true
        }

        connection.closed = { [unowned self] in
            self.statusMessage = "Disconnected"
            print("BJW status: \((self.statusMessage))")
//            self.startButton.isEnabled = true
//            self.startButton.title = "Start"
//            self.sendButton.isEnabled = false
        }

        connection.connectionSlow = { print("Connection slow...") }

        connection.error = { [unowned self] error in
            let anError = error as NSError
            if anError.code == NSURLErrorTimedOut {
                self.connection.start()
            }
        }
        connect()
    }

}
