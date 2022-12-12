// swift-tools-version: 5.7.1

import PackageDescription

let package = Package(
    name: "FileSystemWatcher",
    dependencies: [
      .Package(url: "https://github.com/felix91gr/inotify.git", majorVersion: 1)
    ]
)
