//
//  ImageService.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import Foundation
import UIKit

class ImageService {
    private let cache = NSCache<NSString, UIImage>()
    
    private static let sharedServiceInstance = ImageService()
    
    static var shared: ImageService { sharedServiceInstance }
    
    private init() { }
    
    private func downloadImage(from url: URL) async throws -> Data {
        print("Started downloading \(url)")
        
        let (imageData, _) = try await URLSession.shared.data(from: url)
        
        return imageData
    }
    
    func getImage(from urlString: String) async throws -> UIImage {
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            return cachedImage
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidUrl
        }
        
        let imageData = try await downloadImage(from: url)
        guard let image = UIImage(data: imageData) else {
            throw NetworkError.badResponse
        }
        
        cache.setObject(image, forKey: urlString as NSString)
        
        return image
    }
    
    func getImage(from url: URL) async throws -> UIImage {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            return cachedImage
        }
        
        let imageData = try await downloadImage(from: url)
        guard let image = UIImage(data: imageData) else {
            throw NetworkError.badResponse
        }
        
        cache.setObject(image, forKey: url.absoluteString as NSString)
        
        return image
    }
}
