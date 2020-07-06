//
//  StorageManager.swift
//  EasyChat
//
//  Created by Atulya Shetty on 7/6/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()

    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data,fileName: String, completion:@escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed to get Download Url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                
                print("Download url: \(urlString)")
                
                completion(.success(urlString))
            })
            
        })
        
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
}
