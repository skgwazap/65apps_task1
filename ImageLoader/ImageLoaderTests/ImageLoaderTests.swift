//
//  ImageLoaderTests.swift
//  ImageLoaderTests
//
//  Created by Taras Kreknin on 24.07.2020.
//  Copyright © 2020 SKGWAZAP. All rights reserved.
//

import XCTest
@testable import ImageLoader

class ImageLoaderTests: XCTestCase {

    private var network: Networking!
    private var memCache: ImageCacheMock!
    private var loader: ImageLoading!
    
    override func setUpWithError() throws {
        network = NetworkClientMock()
        memCache = ImageCacheMock()
        
        let config = ImageLoader.Config(networkClient: network,
                                        memoryCache: memCache,
                                        diskCache: nil,
                                        logger: nil)
        loader = ImageLoader(config: config)
    }

    override func tearDownWithError() throws {
    }

    func testDownload_checksMemoryCache() throws {
        let testUrl = URL(string: "http://nosorog-studio.com/")!
        memCache.put(data: Data(), forKey: testUrl.absoluteString)
        
        _ = loader.downloadImage(withURL: testUrl, forCell: UITableViewCell())
        
        XCTAssertTrue(memCache.verifyCallCount(forKey: testUrl.absoluteString, isEqualToCount: 1))
    }

    // тут было бы больше тестов, если бы не было лень
    
}
