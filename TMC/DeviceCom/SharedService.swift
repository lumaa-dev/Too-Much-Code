//Made by ChatGPT-3.5 and fixed by Lumaa

import SwiftUI
import Foundation
import Network

struct Device: Identifiable {
    let id = UUID()
    let name: String
    var batteryLevel: Int
}

@Observable
class SharedService: ObservableObject {
    var devices: [Device] = []
    private var listener: NWListener?
    
    init() {
        startListening()
    }
    
    private func startListening() {
        do {
            listener = try NWListener(using: .tcp, on: 0)
            listener?.stateUpdateHandler = { state in
                switch state {
                    case .ready:
                        print("Listener ready")
                    case .failed(let error):
                        print("Listener failed with error: \(error)")
                    default:
                        break
                }
            }
            
            listener?.newConnectionHandler = { newConnection in
                newConnection.stateUpdateHandler = { state in
                    switch state {
                        case .ready:
                            print("New connection ready")
                            self.receiveDeviceInfo(using: newConnection)
                        case .failed(let error):
                            print("New connection failed with error: \(error)")
                        default:
                            break
                    }
                }
                
                newConnection.start(queue: .main)
            }
            
            listener?.start(queue: .main)
        } catch {
            print("Failed to create listener with error: \(error)")
        }
    }
    
    func sendBatteryLevel(_ batteryLevel: Int) {
        // Convert the battery level to a string
        let batteryLevelString = "\(batteryLevel)"
        
        // Send the battery level to all connected devices
        for device in devices {
            sendBatteryLevel(batteryLevelString, to: device)
        }
    }
    
    private func sendBatteryLevel(_ batteryLevel: String, to device: Device) {
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(device.name), port: NWEndpoint.Port(integerLiteral: 0))
        let connection = NWConnection(to: endpoint, using: .tcp)
        
        connection.stateUpdateHandler = { newState in
            switch newState {
                case .ready:
                    print("Connection ready")
                    #if os(iOS)
                    let deviceName = UIDevice.current.name
                    #elseif os(macOS)
                    let deviceName = Host.current().localizedName ?? "Mac" // fallback name
                    #endif
                    self.sendMessage("\(deviceName),\(batteryLevel)", using: connection)
                case .failed(let error):
                    print("Connection failed with error: \(error)")
                default:
                    break
            }
        }
        
        connection.start(queue: .main)
    }
    
    private func sendMessage(_ message: String, using connection: NWConnection) {
        let messageData = message.data(using: .utf8)
        connection.send(content: messageData, completion: .contentProcessed { error in
            if let error = error {
                print("Send failed with error: \(error)")
            } else {
                print("Message sent successfully")
            }
        })
    }
    
    private func receiveDeviceInfo(using connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, context, isComplete, error in
            if let data = data, let receivedString = String(data: data, encoding: .utf8) {
                print("Received data: \(receivedString)")
                
                // Parse the received data and update the devices list
                let components = receivedString.components(separatedBy: ",")
                if components.count == 2, let name = components.first, let batteryLevel = Int(components.last ?? "-100") {
                    let device = Device(name: name, batteryLevel: batteryLevel)
                    self.devices.append(device)
                }
                
                connection.send(content: "ACK".data(using: .utf8), completion: .contentProcessed { _ in
                    print("ACK sent")
                })
            } else if let error = error {
                print("Receive failed with error: \(error)")
            }
        }
    }
}
