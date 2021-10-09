import Foundation

infix operator <-
extension Chan {
    static func <- (_ x:Chan, _ m:Message) async {
        await x.queue(m)
    }
}
actor Chan<Message>: AsyncSequence {
    typealias AsyncIterator = AsyncQueueIterator<Message>
    typealias Element = Message
    private var msgs = [Message]()
    private var waits = [CheckedContinuation<(), Never>]()
    func queue(_ m:Message) {
        msgs.append(m)
        /// Resume all stored continuations.
        while let w = waits.first {
            waits.removeFirst()
            w.resume()
        }
    }
    nonisolated func makeAsyncIterator() -> AsyncQueueIterator<Message> {
        AsyncQueueIterator(queue: self)
    }
}
private extension Chan {
    func pop() async -> Message? {
        while msgs.isEmpty {
            /// Pause task and store continuation.
            await withCheckedContinuation { cont in
                waits.append(cont)
            }
        }
        return msgs.removeFirst()
    }
}
struct AsyncQueueIterator<Message>: AsyncIteratorProtocol {
    private weak var queue: Chan<Message>?
    init(queue q: Chan<Message>) {
        queue = q
    }
    func next() async -> Message? {
        guard let q = queue else { return nil }
        return await q.pop()
    }
}
