//
//  ImageService.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import Foundation
import UIKit

class ImageService {
    private static let sharedServiceInstance = ImageService()
    
    static var shared: ImageService { sharedServiceInstance }
    
    private init() { }
    
    private func downloadImage(from url: URL) async throws -> Data {
        print("Started downloading \(url)")
        
        let (imageData, response) = try await URLSession.shared.data(from: url)
        
        return imageData
    }
    
    func getImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidUrl
        }
        
        let imageData = try await downloadImage(from: url)
        guard let image = UIImage(data: imageData) else {
            throw NetworkError.badResponse
        }
        
        return image
    }
    
    func saveImage(_ imageData: Data) -> Bool {
    #warning("save image not implemented")
        
        return true
    }
}
