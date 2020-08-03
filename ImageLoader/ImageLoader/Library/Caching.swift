//
//  Caching.swift
//  ImageLoader
//
//  Created by Taras Kreknin on 24.07.2020.
//  Copyright © 2020 SKGWAZAP. All rights reserved.
//

import Foundation
import UIKit

protocol Caching {
    
    associatedtype Item
    associatedtype Key
    
    func put(data: Item, forKey key: Key)
    func findDataForKey(_ key: Key) -> Item?

}

class ImageDataCache: Caching {
        
    typealias Item = Data
    typealias Key = String
    
    func put(data: Data, forKey key: String) {}
    func findDataForKey(_ key: String) -> Data? { return nil }
}

final class MemoryImageCache: ImageDataCache {
    
    private static let defaultMaxSize = 3 * 1024 * 1024
    
    private let logger = Logger(type: MemoryImageCache.self)
    private let cache = NSCache<NSString, NSData>()
    
    init(maxSizeInBytes: Int = defaultMaxSize) {
        cache.totalCostLimit = maxSizeInBytes
    }
    
    override func put(data: Data, forKey key: String) {
        cache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
    }
    
    override func findDataForKey(_ key: String) -> Data? {
        return cache.object(forKey: key as NSString) as Data?
    }
}

final class DiskImageCache: ImageDataCache {
    override func put(data: Data, forKey key: String) {
        // когда нибудь потом
    }
    
    override func findDataForKey(_ key: String) -> Data? {
        return nil
    }
}
