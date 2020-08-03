//
//  ViewController.swift
//  ImageLoader
//
//  Created by Taras Kreknin on 24.07.2020.
//  Copyright © 2020 SKGWAZAP. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    private let logger = Logger(type: ViewController.self)
    private let urlProvider: ImageUrlProviding = PlaceholdItUrlProvider()

    private lazy var imageLoader: ImageLoading = {
        let config = ImageLoader.Config(networkClient: NetworkClient(),
                                        memoryCache: MemoryImageCache(),
                                        diskCache: nil,
                                        logger: Logger(type: ImageLoader.self))
        return ImageLoader(config: config)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.debug(message: "didLoad")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableCell.ReuseIdentifier) as! TableCell
        
        if let imageUrl = urlProvider.provideURL(forImageWithIndex: UInt(indexPath.row)) {
            cell.configure(imageUrl: imageUrl, loader: imageLoader)
            cell.textLabel?.text = "Index: \(indexPath.row)"
        } else {
            // fail fast
            fatalError("Couldn't get an URL for row at index \(indexPath)")
        }
        
        
        return cell
    }
    
}

