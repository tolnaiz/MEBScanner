import Foundation
import ExternalAccessory

class ConnectionManager: ObservableObject, ConnectionChangedDelegate{
    @Published var connected: Bool = false
    @Published var connectedDevices: [EAAccessory] = []

    var connection: Connection? = nil
    
    var currentHeader: String?
    
    var testMode: Bool = false
    private static var sharedManager: ConnectionManager = {
        var manager = ConnectionManager()
        return manager
    }()
    
    class func shared() -> ConnectionManager {
        return sharedManager
    }
 
    func connectionChanged(connected: Bool) {
        self.connected = connected
        if connected {
            print("Connected: true")
        }
    }
    
    func request(message: String, action: ((String) -> Void)? = nil){
        connection?.write(str: message.appending("\r"), action: action)
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryConnected), name: NSNotification.Name.EAAccessoryDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDisconnected), name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
        EAAccessoryManager.shared().registerForLocalNotifications()
        let man = EAAccessoryManager.shared()
        connectedDevices = man.connectedAccessories
    }
    
    func connect() -> Bool {
        if !testMode {
            let man = EAAccessoryManager.shared()
            let connected = man.connectedAccessories

            if connected.isEmpty {
                return false
            }
            
            for tmpAccessory in connected{
                print(tmpAccessory.manufacturer)
                print(tmpAccessory.modelNumber)
                connection = OBDConnection(accessory: tmpAccessory)
            }
        }else {
            connection = ConnectionMock()
        }
        connection?.addConnectionChangedDelegate(delegate: self)
        connection?.open()
        self.initialize()
        return true
    }
    
    func initialize() {
        request(message:"ATD")
        request(message:"ATZ")
        request(message:"ATE0")
        request(message:"ATL0")
        request(message:"ATSP7")
//        request(message:"ATSH17FC007B")
        request(message:"ATCM00000000")
//        request(message:"STCFCPA17FC007B,17FE007B")
//        request(message:"ATCRA17FE007B")
    }
    
    func disconnect() {
        connection?.close()
        connection = nil
    }
    
    func cancellAllOperations(){
        connection?.cancellAllOperations()
    }
    
    @objc private func accessoryConnected(notification: NSNotification) {
        let connectedAccessory = notification.userInfo![EAAccessoryKey] as! EAAccessory
        if !OBDConnection.supportsProtocol(accessory: connectedAccessory) {
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
