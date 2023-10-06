import SwiftyBeaver

public let log: SwiftyBeaver.Type = {
    let log = SwiftyBeaver.self
    let console = ConsoleDestination()  // log to Xcode Console
    log.addDestination(console)
    return log
}()
