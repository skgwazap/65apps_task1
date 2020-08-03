//
//  NetworkClientMock.swift
//  ImageLoaderTests
//
//  Created by Taras Kreknin on 03.08.2020.
//  Copyright © 2020 SKGWAZAP. All rights reserved.
//

import Foundation
@testable import ImageLoader

final class NetworkClientMock: Networking {
    
    var results: [URL: Result<Data, NetworkingError>] = [:]
    
    func getDataFrom(url: URL,
                     callbackQueue: DispatchQueue,
                     onComplete: @escaping (Result<Data, NetworkingError>) -> Void) -> Cancellable {
        if let result = results[url] {
            callbackQueue.async {
                onComplete(result)
            }
        } else {
            callbackQueue.async {
                onComplete(.failure(NetworkingError.noDataReceived))
            }
        }
        
        return Cancellables.empty()
    }
    
}
