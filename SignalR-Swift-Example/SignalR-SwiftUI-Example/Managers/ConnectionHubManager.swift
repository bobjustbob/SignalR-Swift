//
//  ConnectionHubManager.swift
//  SignalR-SwiftUI-Example
//
//  Created by Bobby Williams on 12/19/22.
//  Copyright © 2022 Jordan Camara. All rights reserved.
//

import SwiftUI
import SignalRSwift

enum ConnectionStatus: String {
    case notRunning, running, connected, disconnected, error
}

class ConnectionHubManager: ObservableObject {
    static var shared = ConnectionHubManager()

    private var chatHub: HubProxy!
    private var connection: HubConnection!
    @Published var clientUserName: String!
    @Published var statusMessage    = ""
    @Published var chatMessage      = ""
    @Published var status           = ConnectionStatus.notRunning
    @Published var isBusy           = false
    var isRunning: Bool             { status == .running }
    var isConnected: Bool           { status == .connected }
    var isDisconnected: Bool        { status == .disconnected }

    let serverURL = "http://swiftr.azurewebsites.net"
    let hubName   = "chatHub"


    init() {
        start()
    }

    func connect(_ name: String) {
        clientUserName = name
        statusMessage = "Connecting..."
        isBusy = true
        connection.start()
    }

    func disconnect() {
        isBusy = true
        statusMessage = "Disconnecting..."
        connection.stop()
    }

    func sendMessage(_ message: String) {
        if let hub = chatHub {
            hub.invoke(method: "send", withArgs: [clientUserName ?? "Name: ", message])
        }
    }

    func start() {
        guard isRunning == false else { return }

        isBusy = true
        statusMessage = "Starting..."
        connection = HubConnection(withUrl: serverURL) //SignalR("http://swiftr.azurewebsites.net")
        //        connection.signalRVersion = .v2_2_0

        chatHub = self.connection.createHubProxy(hubName: hubName)
        
        _ = chatHub.on(eventName: "broadcastMessage") { args in
            let text = self.chatMessage
            if let name = args[0] as? String, let message = args[1] as? String {
                if self.chatMessage.isEmpty {
                    self.chatMessage = "\(name): \(message)"
                } else {
                    self.chatMessage = "\(text)\n\(name): \(message)"
                }
            }
        }

        // SignalR events

        connection.started = { [unowned self] in
            self.status = .connected
            self.isBusy = false
            self.statusMessage = "Connected"
            print("BJW status: \((self.statusMessage))")
        }

        connection.reconnecting = { [unowned self] in
            self.isBusy = true
            self.statusMessage = "Reconnecting..."
        }

        connection.reconnected = { [unowned self] in
            self.isBusy = false
            self.status = .connected
            self.statusMessage = "Reconnected. Connection ID: \(self.connection!.connectionId!)"
        }

        connection.closed = { [unowned self] in
            self.status = .disconnected
            self.isBusy = false
            self.statusMessage = "Disconnected"
            print("BJW status: \((self.statusMessage))")
        }

        connection.connectionSlow = { print("Connection slow...") }

        connection.error = { [unowned self] error in
            self.isBusy = false
            self.status = .error
            let anError = error as NSError
            if anError.code == NSURLErrorTimedOut {
                self.connection.start()
            }
        }
        status = .running
        isBusy = false
        statusMessage = "Running"
    }
}
