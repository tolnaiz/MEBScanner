import Foundation
import ExternalAccessory

/// callback if the connection has changed
public protocol ConnectionChangedDelegate: AnyObject {
    func ConnectionChanged(connected: Bool)
}

protocol ReportDelegate {
    func reportReceived(report: [UInt8])
}

public class Connection : NSObject, StreamDelegate {
    
    var accessory: EAAccessory
    var session: EASession?
    
    let maxBufferSize = 20
    
    var isClosed = true
    
    var reportReceivedDelegates = [ReportDelegate]()
    
    var connectionChangedDelegates = [ConnectionChangedDelegate]()
    
    private var canWrite = false
    
    private let queue = DispatchQueue(label: "me.tolnaiz.connection.queue")
    
    private var writeBuffer = Array<NSData>()
    
    private var readBuffer = [UInt8]()
    
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
            
            session.outputStream?.delegate = self
            session.outputStream?.schedule(in: RunLoop.main, forMode: RunLoop.Mode.common)
            session.outputStream?.open()
            
            session.inputStream?.delegate = self
            session.inputStream?.schedule(in: RunLoop.main, forMode: RunLoop.Mode.common)
            session.inputStream?.open()
            
            isClosed = false
            
            for del in self.connectionChangedDelegates {
                del.ConnectionChanged(connected: true)
            }
        }
    }
    
    func addReportDelegate(_ delegate: ReportDelegate) {
        reportReceivedDelegates.append(delegate)
    }
    
    public func addConnectionChangedDelegate(delegate: ConnectionChangedDelegate){
        connectionChangedDelegates.append(delegate)
    }
    
    public func close(){
        if isClosed {
            print("connection already closed")
            return
        }
        
        for del in self.connectionChangedDelegates{
            del.ConnectionChanged(connected: false)
        }
        
        session?.outputStream?.close()
        session?.outputStream?.remove(from: RunLoop.main, forMode: RunLoop.Mode.default)
        session?.outputStream?.delegate = nil
        
        session?.inputStream?.close()
        session?.inputStream?.remove(from: RunLoop.main, forMode: RunLoop.Mode.default)
        session?.inputStream?.delegate = nil
        
        isClosed = true
    }
    
    private func write(){
        if writeBuffer.count < 1 {
            return
        }

        canWrite = false
        
        if session?.outputStream?.hasSpaceAvailable == false {
            print("error: stream has no space available")
            return
        }
        
        let mNSData = writeBuffer.remove(at: 0)
        
        print("Writing NSData: \(String(bytes: mNSData, encoding: .isoLatin1)!)")
        
        var bytes = mNSData.bytes.bindMemory(to: UInt8.self, capacity: mNSData.length)

        var bytesLeftToWrite: NSInteger = mNSData.length
        
        let bytesWritten = session?.outputStream?.write(bytes, maxLength: bytesLeftToWrite) ?? -1
        if bytesWritten == -1 {
            print("error while writing NSData to bt output stream")
            canWrite = true
            return
        }
        
        bytesLeftToWrite -= bytesWritten
        bytes = bytes.advanced(by: bytesWritten)
        
        if bytesLeftToWrite > 0 {
            print("error: not enough space in stream")
            writeBuffer.insert(NSData(bytes: &bytes, length: bytesLeftToWrite), at: 0)
        }
    }
    
    func write(str: String) {
        let data = str.data(using: .isoLatin1)! as NSData
        
        DispatchQueue(label: "me.tolnaiz.connection.queue").async {
            self.dismissCommandsIfNeeded()
            self.writeBuffer.append(data)
            if self.canWrite {
                self.write()
            }
        }
    }
    
    private func dismissCommandsIfNeeded(){
        if( writeBuffer.count > maxBufferSize){
            for _ in 1...maxBufferSize {
                writeBuffer.remove(at: 1)
            }
            print("cleared write buffer")
        }
    }
    
    private func readInBackground(){
        let BUF_LEN = 128
        var buf = [UInt8].init(repeating: 0x00, count: BUF_LEN)
        while (self.session?.inputStream?.hasBytesAvailable) ?? false {
           let bytesRead = session?.inputStream?.read(&buf, maxLength: BUF_LEN)
           readBuffer.append(contentsOf: buf.prefix(bytesRead!))
        }
        if (readBuffer.last == 0x3E){
            reportReceived(report: readBuffer)
            print("read NSData: \(String(bytes: readBuffer, encoding: .isoLatin1)!)")
            readBuffer = []
        }
    }
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event){
        switch eventCode {
       
        case Stream.Event.hasBytesAvailable:
            queue.async {
                self.readInBackground()
            }
            break
            
        case Stream.Event.hasSpaceAvailable:
            queue.async {
                self.canWrite = true
                self.write()
            }
            break
            
        case Stream.Event.openCompleted:
            print("stream opened")
            break
            
        case Stream.Event.errorOccurred:
             print("error on stream")
            break
            
        default:
            print("connection event: \(eventCode.rawValue)")
            break
        }
    
    }
    
    private func reportReceived(report: [UInt8]){
        DispatchQueue.main.async {
            for delegate in self.reportReceivedDelegates {
                delegate.reportReceived(report: report)
            }
        }
    }
}
