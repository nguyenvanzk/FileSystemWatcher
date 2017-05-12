import Dispatch
import Foundation
import inotify

public typealias FileDescriptor = Int
public typealias WatchDescriptor = Int

public struct FileSystemEvent {
  public var watchDescriptor: WatchDescriptor
  public var name: String

  public var mask: UInt32
  public var cookie: UInt32
  public var length: UInt32
}

public enum FileSystemEventType: UInt32 {
  case inAccess             = 0x00000001
  case inModify             = 0x00000002
  case inAttrib             = 0x00000004

  case inCloseWrite         = 0x00000008
  case inCloseNoWrite       = 0x00000010
  case inClose              = 0x00000018

  case inOpen               = 0x00000020
  case inMovedFrom          = 0x00000040
  case inMovedTo            = 0x00000080
  case inMove               = 0x000000C0

  case inCreate             = 0x00000100
  case inDelete             = 0x00000200
  case inDeleteSelf         = 0x00000400
  case inMoveSelf           = 0x00000800

  case inUnmount            = 0x00002000
  case inQueueOverflow      = 0x00004000
  case inIgnored            = 0x00008000

  case inOnlyDir            = 0x01000000
  case inDontFollow         = 0x02000000
  case inExcludeUnlink      = 0x04000000

  case inMaskAdd            = 0x20000000

  case inIsDir              = 0x40000000
  case inOneShot            = 0x80000000

  case inAllEvents          = 0x00000FFF

  @available(*, unavailable)
  public static func getTypesFromMask(_ mask: UInt32) -> [FileSystemEventType] {
    return [FileSystemEventType]()
  }
}

public class FileSystemWatcher {
  private let fileDescriptor: FileDescriptor
  private unowned let dispatchQueue: DispatchQueue

  private var watchDescriptors: [WatchDescriptor]
  private var shouldStopWatching: Bool = false

  private let deferringDelay : Double

  public init(deferringDelay : Double = 2.0) {
    dispatchQueue = DispatchQueue(label: "inotify.queue", qos: .background,
      attributes: [.initiallyInactive, .concurrent])
    fileDescriptor = FileDescriptor(inotify_init())
    if fileDescriptor < 0 {
      fatalError("Failed to initialize inotify")
    }

    watchDescriptors = [WatchDescriptor]()
  
    self.deferringDelay = deferringDelay 
  }

  public func start() {
    shouldStopWatching = false
    dispatchQueue.activate()
  }

  public func stop() {
    shouldStopWatching = true
    dispatchQueue.suspend()

    for watchDescriptor in watchDescriptors {
      inotify_rm_watch(Int32(fileDescriptor), Int32(watchDescriptor))
    }
    close(Int32(fileDescriptor))
  }

  public func watch(paths: [String], for events: [FileSystemEventType],
      thenInvoke callback: @escaping (FileSystemEvent) -> Void) -> [WatchDescriptor] {
    var flags: UInt32 = events.count > 0 ? 0 : FileSystemEventType.inAllEvents.rawValue
    for event in events {
      flags |= event.rawValue
    }

    var wds = [WatchDescriptor]() // watch descriptors for the call only

    for path in paths {
      let watchDescriptor = inotify_add_watch(Int32(fileDescriptor), path, flags)
      watchDescriptors.append(WatchDescriptor(watchDescriptor))
      wds.append(WatchDescriptor(watchDescriptor))

      // For deferred execution
      var lastTimeStamp = Date()
 
      dispatchQueue.async {
        let bufferLength = Int(MemoryLayout<inotify_event>.size) + Int(NAME_MAX) + 1
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferLength)

        var fileSystemEvent : FileSystemEvent?

        while !self.shouldStopWatching {
          // IF it's been more than "delay" seconds since the last callback,
          // run the callback again.
          if(lastTimeStamp.timeIntervalSinceNow < -self.deferringDelay) {
            lastTimeStamp = Date()            
          
            // This checks if there exists an event
            // before sending it. It's very important,
            // because it makes the first run possible.
            if let lastEvent = fileSystemEvent {
              self.dispatchQueue.asyncAfter(deadline: .now() + self.deferringDelay) { 
                  callback(lastEvent)
              }
            }
          }
          // IF NOT, then we defer the events until enough time passes
          // for the callback window to open again
          else {
            var currentIndex: Int = 0
            let readLength = read(Int32(self.fileDescriptor), buffer, bufferLength)

            while currentIndex < readLength {
              let event = withUnsafePointer(to: &buffer[currentIndex]) {
                return $0.withMemoryRebound(to: inotify_event.self, capacity: 1) {
                  return $0.pointee
                }
              }


              if event.len > 0 {

                fileSystemEvent = FileSystemEvent(
                  watchDescriptor: WatchDescriptor(event.wd),
                  name: String(cString: buffer + currentIndex + MemoryLayout<inotify_event>.size),
                  mask: event.mask,
                  cookie: event.cookie,
                  length: event.len
                )
              }

              currentIndex += MemoryLayout<inotify_event>.stride + Int(event.len)
            }

          }

          
        }
      }
    }

    return wds
  }
}
