//Made by Lumaa
#if os(iOS)

import SwiftUI
import Foundation
import BackgroundTasks

struct BackgroundBattery {
    static var main: BackgroundBattery = .init()
    
    var sharedService = Peer2PeerConnectionManager()
    
    init() {}
    
    func createTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BGIdentifier.battery.rawValue, using: nil) { task in
            let batteryLevel = BatteryControl.getBatteryPercent()
            let currentDevice = PeerModel(battery: batteryLevel, device: UIDevice.current.name)
            
            self.sendBattery(currentDevice)
            
            task.setTaskCompleted(success: true)
        }
    }
    
    func sendBattery(_ currentDevice: PeerModel) {
        sharedService.startBrowsing()
        
        if !sharedService.peers.isEmpty {
            for device in sharedService.peers {
                sharedService.invitePeer(device, to: currentDevice)
                sharedService.send(currentDevice, to: device)
                
                print("Sent \(currentDevice.batteryLevel) to \(device.displayName)")
            }
        }
    }
    
    func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: BGIdentifier.battery.rawValue)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60) // wait 1 minute
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BG: Submitted \(request.identifier) at \(request.earliestBeginDate ?? .distantFuture)")
        } catch {
            print("BG: Could not schedule sending battery: \(error)")
            print(error)
        }
    }
}

enum BGIdentifier: String {
    case battery = "fr.lumaa.TMC.battery"
}
#endif
