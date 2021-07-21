import XCTest
import FlexEmit

final class Flex_EmitTests: XCTestCase {
	func testExample() {
		let myEmitter = Emitter()
		let firstMessage = MessageA(x: 8, y: "Hello")
		let secondMessage = MessageB(z: 5)

		var receivedA = MessageA(x: 0, y: "")
		var receivedB = MessageB(z: .zero)
		myEmitter.when { (message: MessageA) in
			receivedA = message
		}
		myEmitter.when { (message: MessageB) in
			receivedB = message
		}

		measure {
			for _ in 0..<200_000 {
				myEmitter.emit(firstMessage)
				myEmitter.emit(secondMessage)
			}
		}

		assert(receivedA == firstMessage)
		assert(receivedB == secondMessage)
	}
}

struct MessageA: Equatable {
	let x: Int
	let y: String
}

struct MessageB: Equatable {
	let z: UInt8
}

func a() {

}

func b() {

}
