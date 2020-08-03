//
//  TableCell.swift
//  ImageLoader
//
//  Created by Taras Kreknin on 24.07.2020.
//  Copyright © 2020 SKGWAZAP. All rights reserved.
//

import Foundation
import UIKit

final class TableCell: UITableViewCell {
    
    static let ReuseIdentifier = "TableCell"
    
    private let logger = Logger.init(type: TableCell.self)
    
    private var cancellation: Cancellable?
    
    func configure(imageUrl: URL, loader: ImageLoading) {
        cancellation = loader.downloadImage(withURL: imageUrl, forCell: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
        setNeedsLayout()
        cancellation?.cancel()
        cancellation = nil
    }
    
}
