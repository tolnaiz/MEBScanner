import Foundation
import ExternalAccessory

/// callback if the connection has changed
public protocol ConnectionChangedDelegate: AnyObject {
    func connectionChanged(connected: Bool)
}

protocol ReportDelegate {
    func reportReceived(report: [UInt8])
}

protocol Connection {
    func addConnectionChangedDelegate(delegate: ConnectionChangedDelegate)
    func open()
    func close()
    func cancellAllOperations()
    func write(str: String, action: ((String) -> Void)?)
}

public class OBDConnection : NSObject, StreamDelegate, Connection {
    
    var accessory: EAAccessory
    var session: EASession?
    
    var isClosed = true
    
    var reportReceivedDelegates = [ReportDelegate]()
    
    var connectionChangedDelegates = [ConnectionChangedDelegate]()
    
    let obdQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "me.tolnaiz.mebscanner.obdcommands"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public init(accessory: EAAccessory){
        self.accessory = accessory
    }
    
    public static func supportsProtocol(accessory: EAAccessory) -> Bool {
        return accessory.protocolStrings.contains("com.obdlink")
    }
    
    public func open(){
        if !isClosed {
            print("Connection already open")
            return
        }
        
        if let session = EASession(accessory: self.accessory, forProtocol: "com.obdlink") {
            self.session = session
            
            session.outputStream?.open()
            session.inputStream?.open()
            
            isClosed = false
            
            for del in self.connectionChangedDelegates {
                del.connectionChanged(connected: true)
            }
        }
    }
    
    public func addConnectionChangedDelegate(delegate: ConnectionChangedDelegate){
        connectionChangedDelegates.append(delegate)
    }
    
    public func cancellAllOperations() {
        obdQueue.cancelAllOperations()
    }
    
    public func close(){
        if isClosed {
            print("connection already closed")
            return
        }
        
        for del in self.connectionChangedDelegates{
            del.connectionChanged(connected: false)
        }
        
        obdQueue.cancelAllOperations()
        
        session?.outputStream?.close()
        session?.outputStream?.delegate = nil
        
        session?.inputStream?.close()
        session?.inputStream?.delegate = nil
        
        isClosed = true
    }
    
    func write(str: String, action: ((String) -> Void)?) {
        let data = str.data(using: .isoLatin1)! as NSData
        
        let request = CommandOperation(inputStream: session!.inputStream!, outputStream: session!.outputStream!, command: data)

        request.onResponse = action
        request.queuePriority = .high
        request.completionBlock = {
            print("Request operation completed")
        }
        if obdQueue.operationCount > PIDParameter.allCases.count * 5 {
            print("OperationQueue too long, skipping")
        } else{
            obdQueue.addOperation(request)
//            print("adding to operationQueue")
        }
        
    }

}
