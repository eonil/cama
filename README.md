CAMA
====
Eonil, 2021.

CAMA is short for "Clean Actor Model Architecture".
As like it says, its CA(Clean Architecture) + AM(Actor model).
AM here means AM introduced in Swift 5.5 that comes with async/await support.

Core idea of CA is "isolation via minimally abstracted interface surface".
Core idea of AM is "message passing between isolated & concurrently working actors".

Both focuses on "isolation", because this is one of the important thing to 
build programs at arbitrary complexity.

There are also differences. CA focuses more on "abstraction", 
and AM focuses more on "concurrency". Good news is, we can take both of two greatness.

By combining two, we get very simple, extensive and recursive way to organize 
human-facing interactive applications at arbitrary complexity in manageable way.

Getting Started
---------------
Let's start with our first CAMA-based app, "ToDo".
It starts with `Root` which is the top-most unique owner of the application.
And the `Root` is an actor.

    actor Root {
    }

An app is divided into two parts; (1) Core and (2) Shell.
Core is "business logic" in CA terms, and Shell is UI.

Why do we divide it into two parts? By diviging them into two parts, 
we can test them individually. Also we are going to show how to "divide" an app
into smaller parts in same way here.

    actor Core {
    }
    actor Shell {
    }

Those two components (Core and Shell) need to communicate.
In CAMA, everything communicates only with "messages".
Therefore, we need to define messages to exchange.

    enum Action {
        case addNewItemAtLast(String)
        case removeAll
    }

    enum Rendition {
        case snapshot(State)
    }

And connect them so they can exchange messages.

    actor Root {
        init() {
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
        func run(_:Chan<Action>) -> Chan<Rendition> {
            /// ...
        }
    }

    actor Shell {
        func run(_:Chan<Rendition>) -> Chan<Action> {
            /// ...
        }
    }

Implement message processors.

And convert some actors into MainActor as they require to run 
in main thread to work properly.

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
                    dump(x)
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
        func run(_ recv:Chan<Rendition>) -> Chan<Action> {
            let send = Chan<Action>()
            Task {
                /// Prints computation output.
                for await x in recv {
                    dump(x)
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

Now you get an idea how this works.




Next Steps
----------
- Check `ToDo` example source code for full implementations.
- Check another example source code ["CoinBook"](https://github.com/eonil/coinbook).



License
-------
Use of this content is licensed under "CC-BY-4.0 License".
You can do whatever you want. Just please don't forget to linking this repo
so people can find out the original text.

Copyright(C) Eonil, Hoon H., 2021.
All rights reserved.
 
