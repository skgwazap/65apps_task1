//
//  Networking.swift
//  ImageLoader
//
//  Created by Taras Kreknin on 24.07.2020.
//  Copyright © 2020 SKGWAZAP. All rights reserved.
//

import Foundation

enum NetworkingError: Error {
    case failedToConnectToRemoteServer(cause: Error)
    case unexpectedHttpCode(code: Int)
    case noResponseFromServer
    case noDataReceived
    case requestWasCancelled
}

protocol Networking {
    func getDataFrom(url: URL,
                     callbackQueue: DispatchQueue,
                     onComplete: @escaping (Result<Data, NetworkingError>) -> Void) -> Cancellable
}

final class NetworkClient: Networking {
    
    struct Config {
        let logger: Logging?
        let session: URLSession
        
        static let `default`: Config = Config(logger: Logger(name: "Network"),
                                              session: URLSession.shared)
        
    }
    
    private let logger: Logging?
    private let session: URLSession
    
    init(config: Config = .default) {
        self.logger = config.logger
        self.session = config.session
    }
    
    func getDataFrom(url: URL,
                     callbackQueue: DispatchQueue,
                     onComplete: @escaping (Result<Data, NetworkingError>) -> Void) -> Cancellable {
        let task = session.dataTask(with: url) { [logger, callbackQueue] data, response, error in
            if let nsError = error as NSError?, nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCancelled {
                logger?.debug(message: "The task for \(url) was cancelled")
                callbackQueue.async { onComplete(.failure(NetworkingError.requestWasCancelled)) }
                return
            }
            
            if let error = error {
                let wrappedError = NetworkingError.failedToConnectToRemoteServer(cause: error)
                logger?.error(message: "Failed to send a request to \(url)", error: wrappedError)
                callbackQueue.async { onComplete(.failure(wrappedError)) }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                let wrappedError = NetworkingError.noResponseFromServer
                logger?.error(message: "No response form server", error: wrappedError)
                callbackQueue.async { onComplete(.failure(wrappedError)) }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let wrappedError = NetworkingError.unexpectedHttpCode(code: httpResponse.statusCode)
                logger?.error(message: "Server responded unexpectedly", error: wrappedError)
                callbackQueue.async { onComplete(.failure(wrappedError)) }
                return
            }
            
            guard let data = data else {
                let wrappedError = NetworkingError.noDataReceived
                logger?.error(message: "Failed to send a request to \(url)", error: wrappedError)
                callbackQueue.async { onComplete(.failure(wrappedError)) }
                return
            }
            
            logger?.debug(message: "Did finish task for \(url)")
            callbackQueue.async { onComplete(.success(data)) }
        }
        
        task.resume()
        
        return ActionCancellable.create {
            self.logger?.debug(message: "Cancelling task for \(url) state \(task.state.rawValue)")
            task.cancel()
        }
    }
    
}
