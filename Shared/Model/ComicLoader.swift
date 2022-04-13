//
//  ComicLoader.swift
//  XKCDZ
//
//  Created by Adin on 4/12/22.
//

import Foundation
import SwiftUI

// TODO(Adin): Fix forced unwrapping

class ComicLoader: ObservableObject {
    private enum ImageType {
        case JPEG
        case PNG
    }
    
    @Published public private(set) var image: Image? = nil
    private var imageType: ImageType = .JPEG
    
    func load(_ comicNum: Int) {
        // TODO(Adin): Check and load from cache before fetching
        
        let urlSession = URLSession(configuration: .ephemeral)
        let url = URL(string: XKCD_BASE_URL + "\(comicNum)/info.0.json")!
        // TODO(Adin): Check for url == nil
        let task = urlSession.dataTask(with: url, completionHandler: onMetadataComplete)
        task.resume()
    }
    
    private func handlerBoilerplate(data: Data?, response: URLResponse?, error: Error?) -> Bool {
        if error != nil {
            print(error!.localizedDescription)
            return false
        }
        
        guard let httpResponse = response as? HTTPURLResponse
        else {
            return false
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            print("Server returned status code \(httpResponse.statusCode)")
            return false
        }
        
        if data == nil {
            print("No data was recieved!")
            return false
        }
        
        return true
    }
    
    private func onMetadataComplete(data: Data?, response: URLResponse?, error: Error?) {
        if handlerBoilerplate(data: data, response: response, error: error) {
            do {
                let jsonData = try JSONDecoder().decode(ComicMetadata.self, from: data!)
                
                let imageFileExtension = jsonData.img[jsonData.img.lastIndex(of: ".")!...]
                if imageFileExtension == ".jpg" {
                    self.imageType = .JPEG
                }
                else {
                    self.imageType = .PNG
                }
                
                let comicUrl = URL(string: jsonData.img)!
                // TODO(Adin): Check for comicUrl == nil
                let task = URLSession(configuration: .ephemeral).dataTask(with: comicUrl, completionHandler: onImageComplete)
                task.resume()
            }
            catch {
                print("Error decoding json response:\n\(error)")
            }
        }
    }
    
    private func onImageComplete(data: Data?, response: URLResponse?, error: Error?) {
        if handlerBoilerplate(data: data, response: response, error: error) {
            guard let uiImage: UIImage = UIImage(data: data!)
            else {
                print("uiImage failed to parse image data!")
                return
            }
            
            DispatchQueue.main.async { self.image = Image(uiImage: uiImage) }
        }
    }
}
