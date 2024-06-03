import Foundation

class CommandOperation: Operation, StreamDelegate {
    
    private var input:InputStream
    private var output:OutputStream
    
    private var writeBuffer = Array<NSData>()
    
    private var readBuffer = [UInt8]()
    
    private var command:NSData
    
    private var completed = false {
        didSet {
            self.input.remove(from: .current, forMode: RunLoop.Mode.default)
            self.output.remove(from: .current, forMode: RunLoop.Mode.default)
        }
    }

    var onResponse:((_ response:String) -> ())?
    
    override func main() {
        super.main()

        if isCancelled {
            return
        }
        
        self.input.delegate = self
        self.output.delegate = self

        input.schedule(in: .current, forMode: RunLoop.Mode.default)
        output.schedule(in: .current, forMode: RunLoop.Mode.default)
        execute()
        RunLoop.current.run()
    }
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event){
        switch eventCode {
       
        case Stream.Event.hasBytesAvailable:
            self.readInBackground()
            break
            
        case Stream.Event.hasSpaceAvailable:
            self.write()
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
    
    private func readInBackground(){
        let BUF_LEN = 128
        var buf = [UInt8].init(repeating: 0x00, count: BUF_LEN)
        while (input.hasBytesAvailable){
           let bytesRead = input.read(&buf, maxLength: BUF_LEN)
           readBuffer.append(contentsOf: buf.prefix(bytesRead))
        }
        if (readBuffer.last == 0x3E){
            sendResponse(report: readBuffer)
            print("read NSData: \(String(bytes: readBuffer, encoding: .isoLatin1)!)")
            readBuffer = []
        }
    }
    
    private func write(){
        if writeBuffer.count < 1 {
            return
        }
        
        if output.hasSpaceAvailable == false {
            print("error: stream has no space available")
            return
        }
        
        let mNSData = writeBuffer.remove(at: 0)
        
        print("Writing NSData: \(String(bytes: mNSData, encoding: .isoLatin1)!)")
        
        var bytes = mNSData.bytes.bindMemory(to: UInt8.self, capacity: mNSData.length)

        var bytesLeftToWrite: NSInteger = mNSData.length
        
        let bytesWritten = output.write(bytes, maxLength: bytesLeftToWrite)
        if bytesWritten == -1 {
            print("error while writing NSData to bt output stream")
            return
        }
        
        bytesLeftToWrite -= bytesWritten
        bytes = bytes.advanced(by: bytesWritten)
        
        if bytesLeftToWrite > 0 {
            print("error: not enough space in stream")
            writeBuffer.insert(NSData(bytes: &bytes, length: bytesLeftToWrite), at: 0)
        }
    }
    
    init(inputStream: InputStream, outputStream: OutputStream, command: NSData) {
        self.command = command
        self.input = inputStream
        self.output = outputStream
        super.init()
    }

    func execute() {
        writeBuffer.append(command)
        write()
    }
    
    private func sendResponse(report: [UInt8]){
        var response = String(bytes: report, encoding: .isoLatin1)
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
        onResponse?(response!)
        completed = true
    }
}
