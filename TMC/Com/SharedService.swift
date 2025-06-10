// Companion for SwiftUI + Lumaa

import Foundation
import Network
import MultipeerConnectivity

public class LocalNetworkAuthorization: NSObject {
    private var browser: NWBrowser?
    private var netService: NetService?
    private var completion: ((Bool) -> Void)?
    
    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        self.completion = completion
        
        // Create parameters, and allow browsing over peer-to-peer link.
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        // Browse for a custom service type.
        let browser = NWBrowser(for: .bonjour(type: "_bonjour._tcp", domain: nil), using: parameters)
        self.browser = browser
        browser.stateUpdateHandler = { newState in
            switch newState {
                case let .failed(error):
                    print(error.localizedDescription)
                case .ready, .cancelled:
                    break
                case let .waiting(error):
                    print("Local network permission has been denied: \(error)")
                    self.reset()
                    self.completion?(false)
                default:
                    break
            }
        }
        
        self.netService = NetService(domain: "local.", type: "_lnp._tcp.", name: "LocalNetworkPrivacy", port: 1100)
        self.netService?.delegate = self
        
        self.browser?.start(queue: .main)
        self.netService?.publish()
    }
    
    private func reset() {
        self.browser?.cancel()
        self.browser = nil
        self.netService?.stop()
        self.netService = nil
    }
}

extension LocalNetworkAuthorization: NetServiceDelegate {
    public func netServiceDidPublish(_ sender: NetService) {
        self.reset()
        print("Local network permission has been granted")
        self.completion?(true)
    }
}

class PeerListStore: ObservableObject {
    static let shared: PeerListStore = .init()
    
    @Published var memories: [PeerModel] = []
}

struct PeerModel: Codable, Identifiable {
    var id = UUID()
    let batteryLevel: Int
    let device: String
    
    init(id: UUID = UUID(), battery: Int, device: String) {
        self.id = id
        self.batteryLevel = battery
        self.device = device
    }
}

class Peer2PeerConnectionManager: NSObject, ObservableObject {
    typealias ReceivedHandler = (PeerModel) -> Void
    
    /// MCSession is the class used to handle all communication between devices.
    private let session: MCSession
    /// MCPeerID identifies your device on the local network. In this example, you’re using the name you set for your phone.
    private let myPeerId = MCPeerID(displayName: getDeviceName())
    private var receivedHandler: ReceivedHandler?
    /// Service for MCNearbyServiceAdvertiser
    private static let service = "tmcbattery"
    /// MCNearbyServiceAdvertiser is the class that will handle making your device discoverable through MCSession. One of the requirements to advertise is that you have a service
    private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    /// peers, stores the devices discovered through the service set up
    @Published var peers: [MCPeerID] = []
    /// show the connected peer
    @Published var connectedPeer: MCPeerID? = nil
    /// Check if the manager is connecting to a peer
    @Published var isConnecting: Bool = false
    /// The connecting peer
    @Published var connectingPeer: MCPeerID? = nil
    /// The ongoing peer request
    @Published var peerRequest: MCPeerID? = nil
    /// The peer model that was sent
    @Published var peerContent: PeerModel? = nil
    /// This class handles all the work of discovering devices that have turned on advertising
    private var nearbyServiceBrowser: MCNearbyServiceBrowser
    /// The memory to be sent
    private var modelToSend: PeerModel?
    /// You likely won’t want to have your device advertising itself as being available all the time. Here, you start or stop advertising based on the value of isReceivingJobs
    var isReceivingModel: Bool = false {
        didSet {
            if isReceivingModel {
                /// Start advertising the peer
                nearbyServiceAdvertiser.startAdvertisingPeer()
            } else {
                /// Stop advertising the peer
                nearbyServiceAdvertiser.stopAdvertisingPeer()
                /// End the session
                endSession()
            }
        }
    }
    
    /// Initialize a shared instance of the connection manager
    static let shared : Peer2PeerConnectionManager = Peer2PeerConnectionManager()
    /// Initialize your session with your peer ID. You can choose whether you want encryption used for your messages. It’s not used here.
    init(_ receivedHandler: ReceivedHandler? = nil) {
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        /// Asign the receiving handler
        self.receivedHandler = receivedHandler
        /// Here, you initialized nearbyServiceAdvertiser with a Service Type. Multipeer Connectivity uses the service type to limit the way it handles discovering advertised devices. In this project, JobConnectionManager will only be able to discover devices that advertise with the service name of memorymanager-memories
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(
            peer: myPeerId,
            discoveryInfo: nil,
            serviceType: Peer2PeerConnectionManager.service
        )
        /// Initialize nearbyServiceBrowser before the call to super
        nearbyServiceBrowser = MCNearbyServiceBrowser(
            peer: myPeerId,
            serviceType: Peer2PeerConnectionManager.service
        )
        /// Here, you set the delegate for your advertiser, which will show the alert when an invitation is sent.
        super.init()
        session.delegate = self
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
    }
    
    /// Get the memories shared from the network
    public func getMemories(_ receivedHandler: ReceivedHandler? = nil) {
        self.receivedHandler = receivedHandler
    }
    
    /// End the session
    public func endSession() {
        self.session.disconnect()
    }
    
    /// Start browsing for devices
    func startBrowsing() {
        nearbyServiceBrowser.startBrowsingForPeers()
    }
    
    /// Stop browsing
    func stopBrowsing() {
        nearbyServiceBrowser.stopBrowsingForPeers()
    }
    
    /// Invite peer
    func invitePeer(_ peerID: MCPeerID, to memory: PeerModel) {
        /// Save the job until it’s needed
        modelToSend = memory
        /// Create a context. This is serializing the job’s name into Data
        let context = Data("\(memory.device)||\(memory.batteryLevel)".utf8)
        /// Ask your service browser invite a peer using the other device’s peer ID, passing the serialized job name as the context
        nearbyServiceBrowser.invitePeer(peerID, to: session, withContext: context, timeout: TimeInterval(120))
    }
    
    /// Send a memory to a connected peer
    func send(_ memory: PeerModel, to peer: MCPeerID) {
        do {
            /// Create the data from the memory in json format
            let data = try JSONEncoder().encode(memory)
            /// Send the data to the peer
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            /// Print the error
            print(error.localizedDescription)
        }
    }
}

extension Peer2PeerConnectionManager: MCNearbyServiceAdvertiserDelegate {
    /// Once your device is advertising that it’s available for jobs, it’ll need a way to handle requests to connect and receive the job. MCNearbyServiceAdvertiserDelegate needs to handle this request. Here, you can decide whether you want your app to automatically accept the invitation or ask users if they want to allow the connection.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        /// The context passed in gets converted to a string. When you get to the section about sending data, you’ll see how this happens. For now, you need to understand that any type of Data can be passed here and converted however you need.
        guard let context = context, let memoryText = String(data: context, encoding: .utf8) else {
            return
        }
//        let title = "Accept invite from " + "\(peerID.displayName)"
//        let message = "Accept: " + "\"\(memoryText)\""
        let split = memoryText.split(separator: /\|\|/)
        let model = PeerModel(battery: Int(split[1]) ?? -1, device: String(split[0]))
        print("Intercepted advert from \(model.device)")
        self.peerRequest = peerID
        self.peerContent = model
        self.endSession()
        self.modelToSend = nil
        invitationHandler(true, self.session)
    }
}

extension Peer2PeerConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        print("New peer: \(peerID.displayName)")
        /// When the browser discovers a peer, it adds it to peers
        if !peers.contains(peerID) {
            peers.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = peers.firstIndex(of: peerID) else { return }
        /// When the browser looses a peer, it removes it from the list
        peers.remove(at: index)
    }
}

extension Peer2PeerConnectionManager: MCSessionDelegate {
    
    /// This function is used to connect two devices together.
    ///
    /// - Parameters:
    ///   - session: The session used to connect the two devices.
    ///   - peerID: The ID of the peer device.
    ///   - state: The state of the connection.
    ///
    /// - Returns: Nothing.
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .connected:
                print("Connected to \(peerID.displayName)")
                DispatchQueue.main.async {
                    self.connectedPeer = peerID
                }
                DispatchQueue.main.async {
                    self.isConnecting = false
                    self.connectingPeer = nil
                }
                guard let memoryToSend = modelToSend else { return }
                send(memoryToSend, to: peerID)
            case .notConnected:
                print("Not connected: \(peerID.displayName)")
                DispatchQueue.main.async {
                    self.connectedPeer = nil
                }
                DispatchQueue.main.async {
                    self.isConnecting = false
                    self.connectingPeer = nil
                }
            case .connecting:
                print("Connecting to: \(peerID.displayName)")
                DispatchQueue.main.async {
                    self.isConnecting = true
                    self.connectingPeer = peerID
                }
            @unknown default:
                print("Unknown state: \(state)")
                DispatchQueue.main.async {
                    self.isConnecting = false
                    self.connectingPeer = nil
                }
        }
    }
    
    /// This function is used to receive data from a peer in a session.
    ///
    /// - Parameters:
    ///   - session: The session that the data is being received from.
    ///   - data: The data that is being received.
    ///   - peerID: The peer that is sending the data.
    ///
    /// - Returns: Nothing.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Received content from \(peerID.displayName)")
        guard let memory = try? JSONDecoder()
            .decode(PeerModel.self, from: data) else { return }
        DispatchQueue.main.async {
            self.receivedHandler?(memory)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

private func getDeviceName() -> String {
    #if os(iOS)
    let deviceName = UIDevice.current.name
    #elseif os(macOS)
    let deviceName = Host.current().localizedName ?? "Mac" // fallback name
    #endif
    
    return deviceName
}
