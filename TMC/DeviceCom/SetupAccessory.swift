//Made by Lumaa

import SwiftUI
import CoreBluetooth
#if canImport(AccessorySetupKit)
import AccessorySetupKit

@available(iOS 18.0, *)
struct SetupAccessory: View {
    @State private var bluetooth: BluetoothManager = .init()
    @State private var session: ASAccessorySession = .init()
    
    @State private var uuidType: UUIDType = .short
    
    @State private var state: ProcessState = .stale
    private var stateText: String {
        switch self.state {
            case .stale:
                "Waiting action"
            case .fail:
                "Setup failed"
            case .success:
                "Setup succeeded"
        }
    }
    
    var body: some View {
        GroupBox {
            Picker(selection: $uuidType) {
                ForEach(UUIDType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                        .id(type)
                }
            } label: {
                Text("UUID Type")
            }
            .pickerStyle(.segmented)
            
            Button {
                showMyPicker(using: uuidType == .long ? BluetoothManager.airPodsServiceUUID : BluetoothManager.smthServiceUUID)
            } label: {
                Text("Show AirPods Setup with selected")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                showMyPicker(using: uuidType == .long ? BluetoothManager.airPodsServiceUUID : BluetoothManager.smthServiceUUID)
            } label: {
                Text("Show AirPods Setup with both")
            }
            .buttonStyle(.borderedProminent)
            
            Text(stateText)
                .padding(.vertical)
        }
        .onAppear {
            setupSession()
        }
    }
    
    private func setupSession() {
        session.activate(on: DispatchQueue.main) { event in
            switch event.eventType {
                case .activated:
                    print("Activated")
                case .accessoryAdded:
                    print("Accessory Added")
                case .accessoryRemoved, .accessoryChanged:
                    print("Accessory changed/removed")
                case .invalidated:
                    print("Invalidated")
                case .migrationComplete:
                    print("Migrated")
                case .pickerDidPresent:
                    print("Picker presented")
                case .pickerDidDismiss:
                    print("Picker dismissed")
                case .unknown:
                    print("Something")
                @unknown default:
                    print("Unknown")
            }
        }
    }
    
    private func showMyPicker(using uuid: CBUUID = BluetoothManager.airPodsServiceUUID) {
        var descriptor = ASDiscoveryDescriptor()
        descriptor.bluetoothServiceUUID = uuid
        
        let displayName = "AirPods Pro (1st Gen)"
        let productImage = UIImage.airPodsPro
        
        var items: [ASPickerDisplayItem] = []
        items.append(ASPickerDisplayItem(name: displayName, productImage: productImage, descriptor: descriptor))
        
        session.showPicker(for: items) { error in
            if let error {
                state = .fail
                print(error)
            } else {
                state = .success
            }
        }
    }
    
    private func showBothPicker() {
        var descriptora = ASDiscoveryDescriptor()
        descriptora.bluetoothServiceUUID = BluetoothManager.airPodsServiceUUID
        
        var descriptorb = ASDiscoveryDescriptor()
        descriptorb.bluetoothServiceUUID = BluetoothManager.smthServiceUUID
        
        var items: [ASPickerDisplayItem] = []
        items.append(ASPickerDisplayItem(name: "AirPods Pro (1st Gen) A", productImage: UIImage.airPodsPro, descriptor: descriptora))
        items.append(ASPickerDisplayItem(name: "AirPods Pro (1st Gen) B", productImage: UIImage.airPodsPro, descriptor: descriptorb))
        
        session.showPicker(for: items) { error in
            if let error {
                state = .fail
                print(error)
            } else {
                state = .success
            }
        }
    }
    
    private enum ProcessState {
        case stale
        case fail
        case success
    }
    
    private enum UUIDType: String, CaseIterable {
        case long = "Long"
        case short = "Short"
    }
}

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager?
    var airPodsPeripheral: CBPeripheral?
    
    static let airPodsServiceUUID = CBUUID(string: "0000FD7D-0000-1000-8000-00805F9B34FB")
    static let smthServiceUUID = CBUUID(string: "110B")
    
    override init() {
        super.init()
        self.requestBluetoothAuthorization()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func requestBluetoothAuthorization() {
        let tempManager = CBCentralManager(delegate: self, queue: nil)
        tempManager.stopScan() // Just to trigger the permission dialog
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Start scanning for peripherals with the AirPods service UUID
            centralManager?.scanForPeripherals(withServices: [Self.airPodsServiceUUID], options: nil)
            print("Scanning for AirPods Pro...")
        } else {
            // Handle other states if necessary
            print("Bluetooth is not available")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        airPodsPeripheral = peripheral
        centralManager?.stopScan()
        centralManager?.connect(peripheral, options: nil)
        print("Discovered AirPods Pro, attempting to connect...")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Connected to AirPods Pro
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Handle connection failure
    }
}
#endif
