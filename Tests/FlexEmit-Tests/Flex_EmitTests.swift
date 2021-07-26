import XCTest
import FlexEmit

final class Flex_EmitTests: XCTestCase {
	func testMixedEvents() {
		let myEmitter = Emitter()
		let firstMessage = MessageA(x: 8, y: "Hello")
		let secondMessage = MessageB(z: 5)

		var receivedA: MessageA?
		var receivedB: MessageB?
		myEmitter.when { (message: MessageA) in
			receivedA = message
		}
		myEmitter.when { (message: MessageB) in
			receivedB = message
		}

		XCTAssertEqual(receivedA, nil)
		XCTAssertEqual(receivedB, nil)

		myEmitter.emit(firstMessage)

		XCTAssert(receivedA == firstMessage)
		XCTAssertEqual(receivedB, nil)

		myEmitter.emit(secondMessage)

		XCTAssert(receivedA == firstMessage)
		XCTAssert(receivedB == secondMessage)
	}

	func testSpeed() {
		let worker = Worker()
		let myEmitter = Emitter()
		let firstMessage = MessageA(x: 8, y: "Hello")
		let secondMessage = MessageB(z: 5)

		myEmitter.when { (message: MessageA) in
			worker.work()
		}
		myEmitter.when { (message: MessageB) in
			worker.work()
		}

		let emitRepeat = 10000000
		var timer = ProcessInfo.processInfo.systemUptime
			for _ in 0..<emitRepeat {
				myEmitter.emit(firstMessage)
				myEmitter.emit(secondMessage)
			}
		let emitterTime = ProcessInfo.processInfo.systemUptime - timer

		let isolatedWorker = Worker()
		timer = ProcessInfo.processInfo.systemUptime
			for _ in 0..<emitRepeat {
				isolatedWorker.work()
				isolatedWorker.work()
			}
		let workTime = ProcessInfo.processInfo.systemUptime - timer

		print("Emitter time:", emitterTime)
		print("Estimated pure work time:", workTime)
		print("Work/emit ratio:", workTime / emitterTime)

		XCTAssert(worker.worked == 2 * emitRepeat)
	}

	func testSingleHandlerRemoval() {
		let emitter = Emitter()
		let eventB = MessageB(z: 1)
		var receivedB1 = false
		var receivedB2 = false
		emitter.emit(eventB)

		XCTAssert(!receivedB1)
		XCTAssert(!receivedB2)

		let listenerB1: Handler<MessageB> = emitter.when { _ in receivedB1 = true }
		emitter.when { (message: MessageB) in receivedB2 = true }

		XCTAssert(!receivedB1)
		XCTAssert(!receivedB2)

		emitter.emit(eventB)
		XCTAssert(receivedB1)
		XCTAssert(receivedB2)

		// Reset
		receivedB1 = false
		receivedB2 = false

		emitter.remove(listener: listenerB1)
		emitter.emit(eventB)
		XCTAssert(!receivedB1)
		XCTAssert( receivedB2)

		// Reset
		receivedB1 = false
		receivedB2 = false

		emitter.when { (message: MessageB) in receivedB1 = true }
		emitter.emit(eventB)
		XCTAssert(receivedB1)
		XCTAssert(receivedB2)

		receivedB1 = false
		receivedB2 = false

		XCTAssert( emitter.removeAllListenersFor(message: MessageB.self) )
		emitter.emit(eventB)
		XCTAssert(!receivedB1)
		XCTAssert(!receivedB2)
	}
}

class Worker {
	var worked = 0
	func work() {
		var x: Double = 2
		for _ in 0 ..< 37 {
			x += sqrt(1 + x)
		}
		if x < 1 {
			print(x)
		}
		worked += 1
	}
}

struct MessageA: Equatable {
	let x: Int
	let y: String
}

struct MessageB: Equatable {
	let z: Int
}
