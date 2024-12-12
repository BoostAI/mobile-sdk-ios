//
//  ImageLoader.swift
//  BoostAIUI
//
//  Copyright © 2021 boost.ai
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
//  Please contact us at contact@boost.ai if you have any questions.
//

import UIKit

public class ImageLoader {
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    enum ImageLoaderError: Error {
        case noDataError
        case unknownError
    }
    
    static let shared = ImageLoader()
    
    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        
        // Return image directly if it exists in cache
        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }
        
        // Create UUID for referring to the current request
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Defer removal of the current request after completion
            defer {
                DispatchQueue.main.async {
                    self.runningRequests.removeValue(forKey: uuid)
                }
            }
            
            // If we got any data and can create an image from it, save to cache and return it
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(ImageLoaderError.noDataError))
                }
                return
            }
            
            var image: UIImage? = UIImage(data: data)
            
            if let source = CGImageSourceCreateWithData(data as CFData, nil) {
                let frameCount = CGImageSourceGetCount(source)
                if frameCount > 1 {
                    image = UIImage.gifImageWithData(data)
                }
            }
                
            if let image = image {
                DispatchQueue.main.async {
                    self.loadedImages[url] = image
                    completion(.success(image))
                }
                return
            }
            
            guard let error = error else {
                DispatchQueue.main.async {
                    completion(.failure(ImageLoaderError.unknownError))
                }
                return
            }
            
            guard (error as NSError).code == NSURLErrorCancelled else {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
        }
        
        // Save UUID for possible later cancellation
        runningRequests[uuid] = task
        
        // Run the task
        task.resume()
        
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}
