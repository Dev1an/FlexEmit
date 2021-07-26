//
//  Convenience methods.swift
//  File
//
//  Created by Damiaan on 26/07/2021.
//

fileprivate enum SelfRemover {
	case notInitialised
	case initialised(remover: ()->Void)
	case calledBeforeInitialised
}

extension Emitter {
	public func listenOnce<Message>(_ listener: @escaping (Message)->Void) {
		var selfRemover = SelfRemover.notInitialised
		let modifiedListener = when { (message: Message) in
			if case .initialised(remover: let removeListener) = selfRemover { removeListener() }
			else { selfRemover = .calledBeforeInitialised }
			listener(message)
		}
		switch selfRemover {
			case .calledBeforeInitialised: remove(listener: modifiedListener)
			default: selfRemover = .initialised(remover: {self.remove(listener: modifiedListener)})
		}
	}
}
