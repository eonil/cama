import Foundation
import UIKit
import SwiftUI

@MainActor
public final class Root {
    public init() {
        /// Make up components.
        let core = Core()
        let shell = Shell()
        /// Prepare message receiving channels.
        let actions = Chan<Action>()
        let renditions = Chan<Rendition>()
        
        /// Spawn coroutines for each component.
        /// Wait for incoming messages.
        /// Process the incoming messages by sending to each other.
        Task {
            for await x in await core.run(actions) {
                await renditions <- x
            }
        }
        Task {
            await renditions <- .snapshot(State())
            for await x in shell.run(renditions) {
                await actions <- x
            }
        }
    }
}

actor Core {
    private var state = State()
    func run(_ recv:Chan<Action>) -> Chan<Rendition> {
        let send = Chan<Rendition>()
        Task {
            for await x in recv {
                switch x {
                case let .addNewItemAtLast(text):
                    state.items.append(text)
                case .removeAll:
                    state.items.removeAll()
                }
                await send <- .snapshot(state)
            }
        }
        return send
    }
}

/// App's abstracted state.
struct State {
    var items = [String]()
}





@MainActor
final class Shell {
    private let window = UIWindow(frame: UIScreen.main.bounds)
    private let host = UIHostingController(rootView: AnyView(EmptyView()))
    func run(_ recv:Chan<Rendition>) -> Chan<Action> {
        window.makeKeyAndVisible()
        window.rootViewController = host
        let send = Chan<Action>()
        Task {
            /// Prints computation output.
            for await x in recv {
                switch x {
                case let .snapshot(x):
                    func ui() -> some View {
                        VStack(alignment: .center, spacing: 20) {
                            List {
                                ForEach(x.items.indices, id: \.self) { i in
                                    Text(x.items[i])
                                }
                            }
                            HStack(alignment: .center, spacing: 40) {
                                Button("Add New") {
                                    Task {
                                        await send <- .addNewItemAtLast("new item")
                                    }
                                }
                                Button("Remove All") {
                                    Task {
                                        await send <- .removeAll
                                    }
                                }
                            }
                            Spacer(minLength: 40)
                        }
                    }
                    host.rootView = AnyView(ui())
                }
            }
        }
        return send
    }
}

enum Action {
    case addNewItemAtLast(String)
    case removeAll
}

enum Rendition {
    case snapshot(State)
}



