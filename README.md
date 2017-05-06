# FileSystemWatcher

A bridge between Linux's C API [`inotify`](https://linux.die.net/man/7/inotify) and Swift.

## Use cases

For any async file system event monitoring, we gotcha.

## Usage

I made a [demonstration app](https://github.com/felix91gr/fswatcher-usage) of usage of this library.

The most basic form of usage is as follows:

```swift

import FileSystemWatcher

var eventCount : Int

eventCount = 0

func printEvent(event: FileSystemEvent) {
    print("Hey! Something happened!!")

    eventCount += 1
}


print("Starting!")

let delayBetweenEvents = 5.0

let myWatcher = FileSystemWatcher(deferringDelay: delayBetweenEvents)

myWatcher.watch(
    paths: ["/tmp"], 
    for: [FileSystemEventType.inAllEvents],
    thenInvoke: printEvent)


myWatcher.start()

readLine()

myWatcher.stop()

print("Total number of events: " + String(eventCount))

print("Finished!")

```

## Limitations

### Only deferred mechanism

For now, I'm only interested in supporting a deferred kind of FS event queue. Maybe in a future release, special flags for customizing the watcher's behavior could be implemented.

### Events don't have name

As you can see in [this line](https://github.com/felix91gr/FileSystemWatcher/blob/1.1.0/Sources/fswatcher.swift#L148), the `struct inotify_event` "has no member `name`". This is not quite true, though: the member `name` is **optional**. I don't know yet how to obtain that `CString` from the struct. It would be useful, if we wanted to know more about the characteristics of the captured FS events.

For our use case (at [SourceKittenDaemon](https://github.com/terhechte/SourceKittenDaemon)) that is not necessary: we only need to know when a file has changed. But it would be nice to have that feature. If you know how to do it, please open an Issue or a Pull Request: I'll be happy to recieve your help.