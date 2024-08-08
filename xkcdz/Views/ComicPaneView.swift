//
//  ComicPaneController.swift
//  xkcdz
//
//  Created by Adin W-T on 7/20/24.
//

import Foundation
import UIKit
import CoreImage.CIFilterBuiltins
import CoreGraphics

class ComicPaneView: UIImageView {
    var comicImage: UIImage? {
        set(newImage) {
            guard let newImage = newImage else {
                image = newImage
                return
            }

            let filter = CIFilter.colorInvert()
            let inputImage = CIImage(cgImage: newImage.cgImage!)
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            let outputImage = filter.outputImage!
            let cgImage = g_xkcdzCoreImageContext.createCGImage(outputImage, from: outputImage.extent)!

            image = UIImage(cgImage: cgImage)
        }

        get {
            return image
        }
    }
}
