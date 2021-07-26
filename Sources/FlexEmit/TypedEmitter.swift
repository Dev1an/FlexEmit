final public class Emitter {
	fileprivate var registry = [ObjectIdentifier: ContiguousArray<UnsafeListener>]()

	public init() {}

	public func emit<Message>(_ message: Message) {
		if let listeners = registry[ObjectIdentifier(Message.self)] {
			for listener in listeners {
				unsafeDowncast(listener, to: Listener<Message>.self).content(message)
			}
		}
	}

	@discardableResult
	public func when<Message>(_ listener: @escaping (Message)->Void) -> Listener<Message> {
		let id = ObjectIdentifier(Message.self)
		let handler = Listener(content: listener)
		if registry.keys.contains(id) {
			registry[id]!.append(handler)
		} else {
			registry[id] = [handler]
		}
		return handler
	}

	public func remove<Message>(listener: Listener<Message>) {
		let id = ObjectIdentifier(Message.self)
		registry[id]?.removeAll { listener === $0 }
	}

	@discardableResult
	public func removeAllListenersFor<Message>(message: Message.Type) -> Bool {
		registry.removeValue(forKey: ObjectIdentifier(message)) != nil
	}
}

public class UnsafeListener {}

public class Listener<Message>: UnsafeListener {
	public let content: (Message)->Void

	init(content: @escaping (Message)->Void) {self.content = content}
}
