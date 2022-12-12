// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "FileSystemWatcher")

package.dependencies = [
      .package(url: "https://github.com/nguyenvanzk/inotify.git", .upToNextMajor(from: "1.0.2"))
]

