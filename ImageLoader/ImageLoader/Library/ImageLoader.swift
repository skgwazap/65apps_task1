//
//  ImageLoader.swift
//  ImageLoader
//
//  Created by Taras Kreknin on 24.07.2020.
//  Copyright © 2020 SKGWAZAP. All rights reserved.
//

import Foundation
import UIKit

protocol ImageLoading {
    func downloadImage(withURL url: URL, forCell cell: UITableViewCell) -> Cancellable
}

final class ImageLoader: ImageLoading {
    
    struct Config {
        let networkClient: Networking
        let memoryCache: ImageDataCache?
        let diskCache: ImageDataCache?
        let logger: Logging?
    }
    
    private class ResponseHandler {
        
        let id: String
        let networkTaskCancellation: Cancellable
    
        init(id: String, networkTaskCancellation: Cancellable) {
            self.id = id
            self.networkTaskCancellation = networkTaskCancellation
        }
        
    }
    
    private let logger: Logging?
    private let networkClient: Networking
    
    private let memoryCache: ImageDataCache?
    // TODO когда нибудь потом. См. комментарии в классе [DiskImageCache]
    private let diskCache: ImageDataCache?
    
    private var responseHandlers: [String: ResponseHandler] = [:]
    
    private let syncQueue = DispatchQueue(label: "ImageLoaderSyncQueue")
    private let responseQueue = DispatchQueue(label: "ImageLoaderResponseQueue")
    
    init(config: Config) {
        logger = config.logger
        networkClient = config.networkClient
        memoryCache = config.memoryCache
        diskCache = config.diskCache
    }
    
    func downloadImage(withURL url: URL, forCell cell: UITableViewCell) -> Cancellable {
        syncQueue.sync {
            self.logger?.debug(message: "Getting image for \(url)")
            let urlId = url.absoluteString
            if let cached = memoryCache?.findDataForKey(urlId) {
                logger?.debug(message: "Mem cache hit for \(url)")
                ImageLoader.setImage(UIImage(data: cached), toCell: cell)
                return Cancellables.empty()
            }
            
            if let existingHandler = responseHandlers[urlId] {
                existingHandler.networkTaskCancellation.cancel()
            }
            
            self.logger?.debug(message: "Starting image download \(url)")
            let networkCancellable = networkClient.getDataFrom(url: url, callbackQueue: responseQueue) { result in
                guard let _ = self.findResponseHandler(urlId: urlId) else { return }
                self.removeResponseHandler(urlId: urlId)
                
                switch result {
                case .success(let data):
                    self.logger?.debug(message: "Download finished for \(url)")
                    self.memoryCache?.put(data: data, forKey: urlId)
                    ImageLoader.setImage(UIImage(data: data), toCell: cell)
                    break
                case .failure(let error):
                    self.logger?.error(message: "Failed to download image with url \(url)", error: error)
                    ImageLoader.setImage(nil, toCell: cell)
                    break
                }
            }
            
            responseHandlers[urlId] = ResponseHandler(id: urlId, networkTaskCancellation: networkCancellable)
            
            return ActionCancellable.create {
                self.cancelDownloading(forUrl: url)
            }
        }
    }
    
    private func cancelDownloading(forUrl url: URL) {
        logger?.debug(message: "Cancelling download \(url)")
        syncQueue.sync {
            let id = url.absoluteString
            guard let handler = responseHandlers[id] else { return }
            
            logger?.debug(message: "Real Cancelling download \(url)")
            handler.networkTaskCancellation.cancel()
            responseHandlers.removeValue(forKey: id)
        }
    }
    
    private static func setImage(_ image: UIImage?, toCell cell: UITableViewCell) {
        let updateImage = {
            cell.imageView?.image = image
            cell.setNeedsLayout()
        }
        
        let isOnMainThread = Thread.current.isMainThread
        if isOnMainThread {
            updateImage()
        } else {
            DispatchQueue.main.async { updateImage() }
        }
    }
    
    private func findResponseHandler(urlId: String) -> ResponseHandler? {
        syncQueue.sync {
            self.responseHandlers[urlId]
        }
    }
    
    private func removeResponseHandler(urlId: String) {
        _ = syncQueue.sync {
            self.responseHandlers.removeValue(forKey: urlId)
        }
    }
    
}
