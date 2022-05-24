//
//  ConnectionManager.swift
//  TawkUserManager
//
//  Created by tungphan on 15/05/2022.
//

import Foundation
import Reachability

class ConnectionManager {
    private var networkPendingArray: [NetworkOperation] = []
    private var reachability: Reachability?
    private var whenReachable: ([NetworkOperation]) -> Void
    
    init(whenReachable: @escaping ([NetworkOperation]) -> Void) {
        self.whenReachable = whenReachable
        reachability = try? Reachability()
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to get static data")
        }
        
    }
    
    func addPendingOperation(_ operation: NetworkOperation) {
        networkPendingArray.append(operation)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .unavailable:
            break
        default:
            whenReachable(self.networkPendingArray)
            self.networkPendingArray.removeAll()
        }
    }
}
