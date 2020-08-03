//
//  ImageCacheMock.swift
//  ImageLoaderTests
//
//  Created by Taras Kreknin on 03.08.2020.
//  Copyright © 2020 SKGWAZAP. All rights reserved.
//

import Foundation
@testable import ImageLoader

final class ImageCacheMock: ImageDataCache {
    
    private class CallRecord {
        let key: String
        var count: Int
        
        init(key: String, count: Int) {
            self.key = key
            self.count = count
        }
    }
    
    private var callRecords: [String: CallRecord] = [:]
    
    override func put(data: Data, forKey key: String) {
        super.put(data: data, forKey: key)
    }
    
    override func findDataForKey(_ key: String) -> Data? {
        let result = super.findDataForKey(key)
        if let record = callRecords[key] {
            record.count += 1
        } else {
            callRecords[key] = CallRecord(key: key, count: 1)
        }
        
        return result
    }
    
    func verifyCallCount(forKey key: String, isEqualToCount count: Int) -> Bool {
        return callRecords[key]?.count == count
    }
    
}
