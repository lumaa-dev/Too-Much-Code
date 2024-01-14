//Made by Lumaa

import SwiftUI
import Network
#if canImport(UIKit)
import UIKit
#endif
#if canImport(IOKit)
import IOKit.ps
#endif

struct BatteryView: View {
    @ObservedObject var sharedService = SharedService()
    @State var currentDevice: Device = .init(name: "Unknown Name", batteryLevel: -100)
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("\(currentDevice.name) (Current)")
                    .font(.headline)
                Text("Battery Level: \(currentDevice.batteryLevel)%")
                    .font(.subheadline)
            }
            
            ForEach(sharedService.devices) { device in
                VStack(alignment: .leading) {
                    Text(device.name)
                        .font(.headline)
                    Text("Battery Level: \(device.batteryLevel)%")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle(String("Batteries"))
        .onAppear {
            let battery = BatteryControl.getBatteryPercent()
            if battery != -1 {
                sharedService.sendBatteryLevel(battery)
            }
            
            if currentDevice.batteryLevel <= 0 {
                #if os(iOS)
                let deviceName = UIDevice.current.name
                #elseif os(macOS)
                let deviceName = Host.current().localizedName ?? "Mac" // fallback name
                #endif
                
                currentDevice = .init(name: deviceName, batteryLevel: battery)
            }
        }
    }
}

// Get Device Battery on Mac: https://stackoverflow.com/questions/34571222/get-battery-percentage-on-mac-in-swift
// Get Device Battery on iPhone: https://stackoverflow.com/questions/64843993/how-to-get-the-systems-battery-percentage-in-swift-5
struct BatteryControl {
    static func getBatteryPercent() -> Int {
        #if os(iOS)
        UIDevice.current.isBatteryMonitoringEnabled = true
        print("iPhoneBattery: \(UIDevice.current.batteryLevel)")
        return Int(UIDevice.current.batteryLevel * 100)
        #elseif os(macOS)
        // Take a snapshot of all the power source info
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        
        // Pull out a list of power sources
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        
        // For each power source...
        for ps in sources {
            // Fetch the information for a given power source out of our snapshot
            let info = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as! [String: AnyObject]
            
            // Pull out the name and capacity
            if let name = info[kIOPSNameKey] as? String,
               let capacity = info[kIOPSCurrentCapacityKey] as? Int,
               let max = info[kIOPSMaxCapacityKey] as? Int {
                print("\(name): \(capacity) of \(max)")
                
                return capacity
            }
        }
        return -1
        #endif
    }
}

#Preview {
    BatteryView()
}
