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
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {[weak self] metadata, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
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
    
    
    public func downloadURL(for path: String, completion:  @escaping (Result<URL, Error>) -> Void) {
        
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        })
    }
    
    /// Upload images sent as a conversation
    public func uploadPhotoMessage(with data: Data, fileName: String, completion:@escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: {[weak self] metadata, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: {url, error in
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
    
    public func uploadVideoMessage(with fileUrl: URL, fileName: String, completion:@escaping UploadPictureCompletion) {
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metadata, error in
               guard error == nil else {
                   completion(.failure(StorageErrors.failedToUpload))
                   return
               }
               
               self?.storage.child("message_videos/\(fileName)").downloadURL(completion: {url, error in
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
}
