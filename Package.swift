// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "FileSystemWatcher",
    products: [
        .library(name: "FileSystemWatcher", targets: ["FileSystemWatcher"])
    ],
    dependencies: [
      .package(url: "https://github.com/nguyenvanzk/inotify.git", .upToNextMajor(from: "1.0.2"))
    ],
    targets: [
        .target(name: "FileSystemWatcher", dependencies: [
            .product(name: "inotify", package: "inotify"),
        ])
    ]
)

