import Foundation
import ExternalAccessory

class OBDManager: ObservableObject, ConnectionChangedDelegate, ReportDelegate{
    @Published var connected: Bool = false
    @Published var connectedDevices: [EAAccessory] = []

    var connection: Connection? = nil
    private let semaphore = DispatchSemaphore(value: 0)

    var response: String?
    
    private static var sharedManager: OBDManager = {
            let manager = OBDManager()
            return manager
    }()
    
    class func shared() -> OBDManager {
        return sharedManager
    }
 
    func ConnectionChanged(connected: Bool) {
        self.connected = connected
        if connected {
            print("Connected: true")
        }
    }
    
    func request(message: String) -> String {
        send(message: message)
        semaphore.wait()
        return response ?? ""
    }
    
    func send(message: String) {
        connection?.write(str: message.appending("\r"))
    }
    
    func reportReceived(report: [UInt8]) {
        response = String(bytes: report, encoding: .isoLatin1)
        var rows = response!.components(separatedBy: "\r").filter({ $0 != ">" && $0 != ""})
        print(rows)
        
        if rows.count > 1 {
            rows = rows.map {
                if $0[1] == ":" {
                    return String($0.dropFirst(2))
                }else{
                    return $0
                }
            }
        }
        response = rows.joined(separator: "\r")
        semaphore.signal()
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryConnected), name: NSNotification.Name.EAAccessoryDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDisconnected), name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
        EAAccessoryManager.shared().registerForLocalNotifications()
    }
    
    func connect() {
        let man = EAAccessoryManager.shared()
        let connected = man.connectedAccessories

        for tmpAccessory in connected{
            print(tmpAccessory.manufacturer)
            print(tmpAccessory.modelNumber)
            connection = Connection(accessory: tmpAccessory)
            connection?.addReportDelegate(self)
            connection?.addConnectionChangedDelegate(delegate: self)
            connection?.open()
        }
        initialize()
    }
    
    func initialize() {
        request(message:"ATD")
        request(message:"ATZ")
        request(message:"ATE0")
        request(message:"ATL0")
        request(message:"ATSP7")
        request(message:"ATSH17FC007B")
        request(message:"ATCM00000000")
        request(message:"STCFCPA17FC007B,17FE007B")
//        request(message:"ATCRA17FE007B")
    }
    
    func disconnect() {
        connection?.close()
        connection = nil
    }
    
    @objc private func accessoryConnected(notification: NSNotification) {
        let connectedAccessory = notification.userInfo![EAAccessoryKey] as! EAAccessory
        if !Connection.supportsProtocol(accessory: connectedAccessory) {
            return
        }
        print("EAController::accessoryConnected")
        connectedDevices.append(connectedAccessory)
    }
    
    @objc private func accessoryDisconnected(notification: NSNotification) {
        print("EAController::accessoryDisconnected")
        let connectedAccessory = notification.userInfo![EAAccessoryKey] as! EAAccessory

        connectedDevices.removeFirst(object: connectedAccessory)
        connection?.close()
    }
}
