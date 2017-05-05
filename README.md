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
  // I'd love to use event.name, but I can't figure out yet how to read that from C's API
	// That'd be useful for debugging purposes.
  // But it's allright as long as you don't need to know the exact description of the ocurring events.
  eventCount += 1
}


print("Starting!")

let myWatcher = FileSystemWatcher()

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
