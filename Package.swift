// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "filesystemwatcher",
    products: [
        .library(name: "filesystemwatcher", targets: ["FileSystemWatcher"])
    ],
    dependencies: [
      .package(url: "https://github.com/nguyenvanzk/inotify.git", .upToNextMajor(from: "1.0.4"))
    ],
    targets: [
        .target(
            name: "FileSystemWatcher",
            dependencies: [
                .product(name: "inotify", package: "inotify"),
            ],
            path: "Sources")
    ]
)


