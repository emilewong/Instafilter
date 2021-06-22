//
//  ImageSaver.swift
//  Instafilter
//
//  Created by Emile Wong on 15/6/2021.
//

import UIKit

class ImageSaver: NSObject {
    // MARK: - PROPERTIES
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    // MARK: - FUNCTIONS
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}
