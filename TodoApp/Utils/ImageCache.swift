//
//  ImageCache.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation
import UIKit

// Lightweight in-memory image cache to avoid repeated decoding of avatar data.
final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private init() {
        cache.countLimit = 200 // up to 200 images
        cache.totalCostLimit = 50 * 1024 * 1024 // ~50MB
    }

    func image(for key: String, data: Data) -> UIImage? {
        let nsKey = key as NSString
        if let cached = cache.object(forKey: nsKey) {
            return cached
        }
        guard let image = UIImage(data: data) else { return nil }
        let cost = data.count
        cache.setObject(image, forKey: nsKey, cost: cost)
        return image
    }

    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString, cost: image.pngData()?.count ?? 0)
    }

    func clear() {
        cache.removeAllObjects()
    }
}
