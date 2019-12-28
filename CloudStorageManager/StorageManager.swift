//
//  StorageManager.swift
//  CloudStorageManager
//
//  Created by Iichiro Kawashima on 2019/12/28.
//  Copyright © 2019 Iichiro Kawashima. All rights reserved.
//
import FirebaseStorage
import UIKit

enum ResultType<T> {
    case success(T)
    case failure(Error)
}

protocol Uploader {
    func upload(from data: Data,
                remotePath: String,
                contentType: String?,
                completion: @escaping  (ResultType<URL>) -> Void) -> StorageUploadTask?

    func upload(from image: URL,
                remotePath: String,
                contentType: String?,
                completion: @escaping (ResultType<URL>) -> Void)  -> StorageUploadTask?
}

protocol Downloader {
    func download(from remotePath: String,
                  comapletion: @escaping (ResultType<UIImage>) -> Void) -> StorageDownloadTask?

    func download(from remotePath: String,
                  localPath: URL,
                  comapletion: @escaping (ResultType<URL>) -> Void) -> StorageDownloadTask?
}

public final class StorageManager {

    public let reference: StorageReference
    public let metadata: StorageMetadata

    public init(reference: StorageReference = Storage.storage().reference(),
                metadata: StorageMetadata = StorageMetadata()) {
        self.reference = reference
        self.metadata = metadata
    }

    func delete(filePath: String, completion: @escaping (ResultType<Void>) -> Void) {
        let deleteReference = reference.child(filePath)

        deleteReference.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

extension StorageManager: Uploader {

    func upload(from data: Data,
                remotePath: String,
                contentType: String? = nil,
                completion: @escaping (ResultType<URL>) -> Void) -> StorageUploadTask? {

        let uploadReference = reference.child(remotePath)
        metadata.contentType = contentType

        let uploadTask = uploadReference.putData(data, metadata: metadata) { (metadata, error) in
            uploadReference.downloadURL { (url, error) in

                if let error = error {
                    completion(.failure(error))
                }

                guard let downloadURL = url else { return }
                completion(.success(downloadURL))
            }
        }
        return uploadTask
    }

    func upload(from image: URL,
                remotePath: String,
                contentType: String?,
                completion: @escaping (ResultType<URL>) -> Void) -> StorageUploadTask? {

        let uploadReference = reference.child(remotePath)
        metadata.contentType = contentType

        let uploadTask = uploadReference.putFile(from: image, metadata: metadata) { (metadata, error) in

            uploadReference.downloadURL { (url, error) in

                if let error = error {
                    completion(.failure(error))
                }

                guard let downloadURL = url else { return }
                completion(.success(downloadURL))
            }
        }

        return uploadTask
    }
}

extension StorageManager: Downloader {

    func download(from remotePath: String,
                  comapletion: @escaping (ResultType<UIImage>) -> Void) -> StorageDownloadTask? {

        let downloadReference = reference.child(remotePath)

        let downloadTask = downloadReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                comapletion(.failure(error))
            }

            guard let imageData = data, let image = UIImage(data: imageData) else { return }
            comapletion(.success(image))

        }
        return downloadTask
    }

    func download(from remotePath: String,
                  localPath: URL,
                  comapletion: @escaping (ResultType<URL>) -> Void) -> StorageDownloadTask? {

        let downloadReference = reference.child(remotePath)

        let downloadTask = downloadReference.write(toFile: localPath) { url, error in
            if let error = error {
                comapletion(.failure(error))
            }

            guard let url = url else { return }
            comapletion(.success(url))
        }
        return downloadTask
    }
}
