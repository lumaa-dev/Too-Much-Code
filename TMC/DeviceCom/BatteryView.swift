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
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var sharedService = Peer2PeerConnectionManager()
    @State private var currentDevice: PeerModel = .init(battery: 0, device: "")
    
    @State private var peerEnabled: Bool = false
    @State private var sendingData: Bool = false
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("\(currentDevice.device) (Current)")
                    .font(.headline)
                Text("Battery Level: \(currentDevice.batteryLevel)%")
                    .font(.subheadline)
            }
            
            if let connected = sharedService.peerContent {
                VStack(alignment: .leading) {
                    Text("\(connected.device)")
                        .font(.headline)
                    Text("Battery Level: \(connected.batteryLevel)%")
                        .font(.subheadline)
                }
            }
            
            if peerEnabled {
                Section(header: Text("Found Devices")) {
                    ForEach(sharedService.peers, id: \.self) { device in
                        HStack {
                            Text(device.displayName)
                                .font(.headline)
                            
                            Spacer()
                            
                            Button {
                                sharedService.invitePeer(device, to: currentDevice)
                                sharedService.send(currentDevice, to: device)
                            } label: {
                                if sendingData {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                } else {
                                    Text("Send battery")
                                }
                            }
                            .disabled(sendingData)
                        }
                    }
                }
            }
        }
        .navigationTitle(String("Batteries"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if peerEnabled {
                        sharedService.stopBrowsing()
                    } else {
                        sharedService.startBrowsing()
                    }
                    
                    peerEnabled.toggle()
                } label: {
                    Image(systemName: "antenna.radiowaves.left.and.right", variableValue: peerEnabled ? 1.0 : 0.0)
                        .foregroundStyle(peerEnabled ? Color.green : Color.blue)
                        .symbolEffect(.variableColor.cumulative.hideInactiveLayers.nonReversing, isActive: peerEnabled)
                }
            }
        }
        .onAppear {
            let battery = BatteryControl.getBatteryPercent()
            let auth = LocalNetworkAuthorization()
            auth.requestAuthorization { authorized in
                if !authorized {
                    dismiss()
                } else {
                    sharedService.isReceivingModel = true
                }
            }
            
            if currentDevice.batteryLevel <= 0 {
                #if os(iOS)
                let deviceName = UIDevice.current.name
                #elseif os(macOS)
                let deviceName = Host.current().localizedName ?? "Mac" // fallback name
                #endif
                
                currentDevice = PeerModel(battery: battery, device: deviceName)
            }
        }
        .onDisappear {
            let auth = LocalNetworkAuthorization()
            auth.requestAuthorization { authorized in
                if authorized {
                    sharedService.isReceivingModel = true
                }
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
