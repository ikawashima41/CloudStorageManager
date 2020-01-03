# 💭 CloudStorageManager

CloudStorageManager is a utility framework for Firebase Cloud Storage

**Feature**
- [x] upload data/files
- [x] Download data/files

# Requirements

- iOS 12 later
- Swift5.0 or later
- [Firebase Cloud Storage](https://firebase.google.com/docs/storage/ios/start)

# Installation

[Carthage](https://github.com/Carthage/Carthage)

```
# Use the latest version
github "https://github.com/ikawashima41/CloudStorageManager.git"

# Use the branch
github "https://github.com/ikawashima41/CloudStorageManager.git" "master"
```

# Usage

You need to add ` GoogleService-Info.plist ` to your project file.
[Add Firebase to your iOS project](https://firebase.google.com/docs/ios/setup)

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
