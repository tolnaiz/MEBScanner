//
//  CommandSender.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 03/05/2024.
//

import Foundation

enum CommandInterval : Double{
    case slow = 1
    case fast = 0.1
}

struct Subscription : Identifiable, Hashable {
    let id = UUID()
    var pid: PID
    var interval: CommandInterval
    var action: (PIDValue) -> Void
    
    init(pidparam: PIDParameter, interval: CommandInterval, action: @escaping (PIDValue) -> Void) {
        self.pid = PID.parameters[pidparam]!
        self.interval = interval
        self.action = action
    }
    
    static func == (lhs: Subscription, rhs: Subscription) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class CommandSender: ObservableObject{
    var subscriptions: Set<Subscription> = []
    var timer100ms: Timer?
    var timer1s: Timer?
    var manager: OBDManager
    
    var started: Bool {
        timer1s != nil && timer1s!.isValid;
    }
    
    static var sharedSender: CommandSender = {
        let sender = CommandSender()
        return sender
    }()
    
    class func shared() -> CommandSender {
        return sharedSender
    }
    
    init(){
        manager = OBDManager.shared()
    }
    
    func start(){
        if !started {
            print("starting commandsender")
            self.timer1s = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                let slowSubs = self.subscriptions.filter {$0.interval == .slow }
                
                self.sendCommands(subs:slowSubs)
            })
            self.timer100ms = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                let fastSubs = self.subscriptions.filter {$0.interval == .fast }
                self.sendCommands(subs:fastSubs)
            })
        }
    }
    
    func sendCommands(subs: Set<Subscription>){
        let subsByHeader = Dictionary(grouping: subs) { $0.pid.header }
        for header in subsByHeader.keys {
            self.manager.request(message: "ATSH\(header)")
            let subsByCommand = Dictionary(grouping: subsByHeader[header]!) { $0.pid.command }
            for command in subsByCommand.keys {
                print("sending \(command)")
                self.manager.request(message: command) { response in
                    do{
                        let pidvalue = try PID.parse(response: response, command: command)
                        for sub in subsByCommand[command]! {
                            sub.action(pidvalue)
                        }
                    } catch PIDError.InvalidResponse(response: let r, command: let c, pid: _) {
                        print("RESPONSE ERROR: \(c): \(r)")
                    } catch { }
                }
            }
        }
    }
    
    func stop(){
        self.timer1s?.invalidate()
        self.timer100ms?.invalidate()
        manager.cancellAllOperations()
    }
    
    func subscribePID(subscription: Subscription){
        subscriptions.insert(subscription)
        print(subscription.pid.command)
    }
    
    func unSubscribePID(subscription: Subscription) {
        subscriptions.remove(subscription)
    }
}
