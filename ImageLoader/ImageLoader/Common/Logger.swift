//
//  Logger.swift
//  ImageLoader
//
//  Created by Taras Kreknin on 24.07.2020.
//  Copyright © 2020 SKGWAZAP. All rights reserved.
//

import Foundation
import UIKit

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSS"
    return formatter
}()

protocol Logging {
    func debug(message: String)
    func error(message: String, error: Error)
}

final class Logger: Logging {
    
    private let name: String
    
    init(name: String) {
        self.name = name
    }
    
    convenience init(type: AnyObject.Type) {
        self.init(name: String(describing: type))
    }
    
    func debug(message: String) {
        print("[\(formattedTime())] ℹ️ \(name): \(message)")
    }
    
    func error(message: String, error: Error) {
        print("[\(formattedTime())] ‼️ \(name): \(message). \(error.localizedDescription)")
    }
    
    private func formattedTime() -> String {
        return dateFormatter.string(from: Date())
    }

    
}
