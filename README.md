# 💭 CloudStorageManager

CloudStorageManager is a utility framework for Firebase Cloud Storage

**Feature**
- [x] upload data/files
- [x] Download data/files

# Requirements

- iOS 12.0 or later
- Swift5.0 or later
- [Firebase Cloud Storage](https://firebase.google.com/docs/storage/ios/start)

# Installation

[Carthage](https://github.com/Carthage/Carthage)

```
# Use the latest version
github "ikawashima41/CloudStorageManager"
```

# Usage

- [Add Firebase to your iOS project](https://firebase.google.com/docs/ios/setup)

## Upload to remote storage

```
let manager = StorageManager()

manager.upload(from image: UIImage(string: "Cat"), remotePath: "/bucket/cat") { result in
    switch result {
    case .success(let url):
    // Get download url 
    print(url)
    
    case .failure(let err):
    // Error handling
    print(err)
    
    }
}
```

## Download from remote storage
```
let manager = StorageManager()

manager.download(remotePath: "/bucket/image") { result in
    switch result {
    case .success(let image):
    // Get image 
    print(image)
    
    case .failure(let err):
    //  Get some errors
    print(err)
    
    }
}
```

## Delete remote file
```
let manager = StorageManager()

manager.delete(filePath: "/bucket/image") { result in
    switch result {
    case .success(_):
    // Do something

    case .failure(let err):
    // Get some errors
    print(err)
    
    }
}
```
