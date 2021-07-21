public class Emitter {
	fileprivate var registry = [ObjectIdentifier: [UnsafeHandler]]()

	public init() {}

	public func emit<Message>(_ message: Message) {
		if let listeners = registry[ObjectIdentifier(Message.self)] {
			for listener in listeners {
				listener.send(unsafeMessage: message)
			}
		}
	}

	@discardableResult
	public func when<Message>(_ listener: @escaping (Message)->Void) -> Handler<Message> {
		let id = ObjectIdentifier(Message.self)
		let handler = Handler(content: listener)
		if registry.keys.contains(id) {
			registry[id]!.append(handler)
		} else {
			registry[id] = [handler]
		}
		return handler
	}
}

fileprivate protocol UnsafeHandler {
	func send<Message>(unsafeMessage: Message)
}

public class Handler<Message>: UnsafeHandler {
	public let content: (Message)->Void

	init(content: @escaping (Message)->Void) {self.content = content}

	fileprivate func send<UnsafeMessage>(unsafeMessage: UnsafeMessage) {
		content(unsafeBitCast(unsafeMessage, to: Message.self))
	}
}
