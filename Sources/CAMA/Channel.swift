import Foundation

/// Single-item FIFO channel.
/// - No buffering.
/// - Blocks writer if last written message has not been processed.
/// - Blocks reader if there's no waiting message.
public actor Channel<T> {
    private var waitingContent: T?
    private var waitingWrites = [CheckedContinuation<(),Never>]()
    private var waitingReads = [CheckedContinuation<T,Never>]()
    
    public init() {}
    public func read() async -> T {
        if let message = waitingContent {
            self.waitingContent = nil
            if !waitingWrites.isEmpty {
                waitingWrites.removeFirst().resume()
            }
            return message
        }
        else {
            return await withCheckedContinuation { continuation in
                waitingReads.append(continuation)
            }
        }
    }
    public func write(_ message:T) async {
        if waitingContent == nil {
            if waitingReads.isEmpty {
                waitingContent = message
            }
            else {
                waitingReads.removeFirst().resume(returning: message)
            }
        }
        else {
            await withCheckedContinuation { continuation in
                waitingWrites.append(continuation)
            }
            waitingContent = message
        }
    }
}
