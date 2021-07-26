# FlexEmit

A flexible but type safe event emitting system written in Swift.

It is inspired by NodeJS' famous EventEmitter but it uses the Swift Type system instead of Strings to differentiate event types. That means:

- No more fiddling with (possible incorrect) strings
- No more guessing of data arguments for specific event types
- Enjoying the type safe swift event emitter 🎉

## Basic usage

### Create an emitter 📡
```swift
let eventEmitter = Emitter()
```

### Create an event type 🧾

```swift
struct MovedTo {
    let x, y: Int
}
```

### Register an event listener 🛰

To act upon new emitted messages of a certain type (in our case `MovedTo`), just write

```swift
eventEmitter.when { (newLocation: MovedTo) in
    print("Moved to coordinates \(newLocation.x):\(newLocation.y)")
}
```

Note that the `newLocation` argument is type safe and will always be a struct of type `MovedTo`

### Emit events ✈️

```swift
let firstPlace = MovedTo(x: 0, y: 1)
let secondPlace = MovedTo(x: 2, y: 3)
eventEmitter.emit(firstPlace) // prints "Moved to coordinates 0:1"
eventEmitter.emit(secondPlace)// prints "Moved to coordinates 2:3"
```

🥳 Thats all you need to emit and receive type safe events in Swift!

## More info

### Multiple event types

You can send and receive as many messages of any Swift Type as you want. For example let's create another event type

```swift
eventEmitter.emit(EnergyLevelChanged(to: 70))
struct EnergyLevelChanged {
    let newEnergyLevel: Int
    init(to newValue: Int) { newEnergyLevel = newValue }
}
```

#### Sending into the void

Note that in the example above, no listeners were attached for the `EnergyLevelChanged` event. So the *change to energy level 70* will be lost and cannot be retreived anymore.

to receive potential future EnergyLevelChanged events just add another listener:
```swift
eventEmitter.when { (event: EnergyLevelChanged) in
    print("Changed energy level to", event.newEnergyLevel)
}
```

It's as simple as that. Whenever you sent a new message the appropriate event listener will be called.

```swift
eventEmitter.emit(EnergyLevelChanged(to: 60)) // prints "Changed energy level to 60"
eventEmitter.emit(MovedTo(x: 0, y: 0)) // prints "Moved to coordinates 0:0"
```

### Listen once

When you only want to execute your listener once and remove it after the listener is called, use the `listenOnce` method:

```swift
eventEmitter.listenOnce { (event: EnergyLevelChanged) in
    print("Only saying this once like this. EnergyLevelChanged event has been emitted")
}
```

### Removing listeners

#### Remove a specific listener

It is possible to save a listener so you can remove or cancel it later. To do this just assign the result of `when(...)` to a variable that you can reference later:

```swift
let energyListener = emitter.when { (event: EnergyLevelChanged) in
    print("Processed an EnergyLevelChanged event")
}
```

Then remove this listener using `remove(listener:)`

```swift
emitter.remove(listener: energyListener)
```

#### Removing all listeners for a specific event type

When you want to cancel all listeners for a specific event type, use the `removeAllListeners(for:)` method:

```swift
emitter.removeAllListeners(for: EnergyLevelChanged.self)
```

