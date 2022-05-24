//
//  NetworkOperation.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import Foundation

class NetworkOperation: AsynchronousOperation {
    var urlRequest: URLRequest
    var session: URLSession
    var completion: (Data?, Error?) -> Void
    var dataTask: URLSessionDataTask?
    var connectionManager: ConnectionManager
    
    init(session: URLSession, urlRequest: URLRequest, connectionManager: ConnectionManager, completion: @escaping (Data?, Error?) -> Void) {
        self.urlRequest = urlRequest
        self.session = session
        self.completion = completion
        self.connectionManager = connectionManager
        super.init()
    }
    
    override func main() {
        dataTask = session.dataTask(
            with: urlRequest,
            completionHandler: { [weak self] data, _, error in
                guard let self = self else {
                    return
                }
                if let error = error, error.isNoInternetError {
                    let newOperation = NetworkOperation(session: self.session,
                                                        urlRequest: self.urlRequest,
                                                        connectionManager: self.connectionManager,
                                                        completion: self.completion)
                    self.connectionManager.addPendingOperation(newOperation)
                }
                self.completion(data, error)
                self.completeOperation()
            })
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        completion(nil, APIError.cancelRequest)
        super.cancel()
        completeOperation()
    }
}

extension Error {
    var isNoInternetError: Bool {
        return [-1009, -1020].contains((self as NSError).code)
    }
}
