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
    func upload(from data: Data, filePath: String, contentType: String?, completion: @escaping  (ResultType<URL>) -> Void) -> StorageUploadTask?
    func upload(from image: URL, filePath: String, contentType: String?, completion: @escaping (URL) -> Void)
}

protocol Downloader {
    func download(from filePath: String, comapletion: @escaping (ResultType<UIImage>) -> Void) -> StorageDownloadTask?
    func download(filePath: URL, comapletion: @escaping (URL) -> Void)

}

public final class StorageManager {

    public var uploadTask: StorageUploadTask?
    public var downloadTask: StorageDownloadTask?

    public init() {}

    func delete(filePath: String, completion: @escaping (ResultType<Void>) -> Void) {
        let storage = Storage.storage()
        let reference = storage.reference()
        let deleteReference = reference.child(filePath)

        deleteReference.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func observe(uploadTask: StorageUploadTask?) {
        // Listen for state changes, errors, and completion of the upload.
        uploadTask?.observe(.resume) { snapshot in
            // Upload resumed, also fires when the upload starts
        }

        uploadTask?.observe(.pause) { snapshot in
            // Upload paused
        }

        uploadTask?.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
        }

        uploadTask?.observe(.success) { snapshot in
            // Upload completed successfully
        }

        uploadTask?.observe(.failure) { snapshot in
            if let error = snapshot.error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    break
                case .cancelled:
                    // User canceled the upload
                    break

                case .unknown:
                    // Unknown error occurred, inspect the server response
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    break
                }
            }
        }
    }
}

extension StorageManager: Uploader {

    func upload(from data: Data,
                filePath: String,
                contentType: String? = nil,
                completion: @escaping (ResultType<URL>) -> Void) -> StorageUploadTask? {

        let storage = Storage.storage()
        let reference = storage.reference()
        let uploadReference = reference.child(filePath)

        let metaData = StorageMetadata()
        metaData.contentType = contentType ?? ""

        uploadTask = uploadReference.putData(data, metadata: metaData) { (metadata, error) in
            uploadReference.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                completion(.success(downloadURL))
            }
        }
        return uploadTask
    }

    func upload(from image: URL,
                filePath: String,
                contentType: String?,
                completion: @escaping (URL) -> Void) {


        let storage = Storage.storage()
        let reference = storage.reference()
        let uploadReference = reference.child(filePath)

        let metaData = StorageMetadata()
        metaData.contentType = contentType ?? ""

        uploadTask = uploadReference.putFile(from: image, metadata: metaData) { (metadata, error) in

            guard let metadata = metadata else {
                return
            }

            uploadReference.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                completion(downloadURL)
            }
        }
    }
}

extension StorageManager: Downloader {

    func download(from filePath: String,
                  comapletion: @escaping (ResultType<UIImage>) -> Void) -> StorageDownloadTask? {

        let storage = Storage.storage()
        let reference = storage.reference()
        let downloadReference = reference.child(filePath)

        downloadTask = downloadReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("\(error)")
                comapletion(.failure(error))
            }

            guard let imageData = data, let image = UIImage(data: imageData) else { return }
            comapletion(.success(image))

        }
        return downloadTask
    }

    func download(filePath: URL,
                  comapletion: @escaping (URL) -> Void) {

        let storage = Storage.storage()
        let reference = storage.reference()
        let downloadReference = reference.child("")

        // Start the download (in this case writing to a file)
        downloadTask = downloadReference.write(toFile: filePath)
    }
}
