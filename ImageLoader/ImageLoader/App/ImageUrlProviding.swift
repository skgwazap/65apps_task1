//
//  ImageUrlProviding.swift
//  ImageLoader
//
//  Created by Taras Kreknin on 24.07.2020.
//  Copyright © 2020 SKGWAZAP. All rights reserved.
//

import Foundation

protocol ImageUrlProviding {
    func provideURL(forImageWithIndex index: UInt) -> URL?
}

final class PlaceholdItUrlProvider: ImageUrlProviding {
    
    private let scheme = "https"
    private let host = "placehold.it"
    private let sizePath = "/375x150"
    private let textQueryName = "text"
    
    func provideURL(forImageWithIndex index: UInt) -> URL? {
        var components = URLComponents()
        components.host = host
        components.scheme = "https"
        components.path = sizePath
        components.queryItems = [
            URLQueryItem.init(name: textQueryName, value: String(index))
        ]
        
        return components.url
    }
    
}
