import PackageDescription

let package = Package(
    name: "FileSystemWatcher",
    dependencies: [
      .Package(url: "https://github.com/Ponyboy47/inotify.git", majorVersion: 1)
    ]
)
