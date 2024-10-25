# LRDeviceKit

* [Overview](#overview)
    * [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Usage](#usage)
    * [Setup](#setup)
    * [Discovery and Connection](#discovery-and-connection)
    * [Creating Features](#creating-features)
    * [Using Features](#using-features)

## Overview

LRDeviceKit was created as part of my final dissertation for my Digital and Technology Solutions degree. It was originally part of [SwiftLock](https://lukeroberts.co/work/swiftlock/), aiming to simplify smart device product setup. The libary utilises modern Swift Concurrency.

It makes device communication easy by enforcing a custom communication and messaging protocol that utilises only 1 BLE service and 2 BLE characteristics and a rigid message structure. The library sends commands to a peripheral’s request characteristic and the device replies back using its reply characteristic.

When sending and receiving data, all messages follow this structure:
| Message Length | Message Type | Command | Namespace | Encrypted | Payload |
|----------------|--------------|---------|-----------|-----------|---------|
| 1 byte         | 1 byte       | 1 byte  | 1 byte    | 1 byte    | N bytes |

| Index | Name      | Description                                                  |
|-------|-----------|--------------------------------------------------------------|
| 0     | Length    | This is the total length of the entire message including the payload |
| 1     | Type      | This is the type of message which can either be a request or reply |
| 2     | Command   | This is the actual command such as set name                  |
| 3     | Namespace | This acts as a group (like a service) to group similar commands together. It allows for command IDs to be reused across namespaces. |
| 4     | Encrypted | Boolean for whether the message is encrypted or not          |
| 5     | Payload   | The actual payload data for the message. For example, the device name in the set name command. |

### Prerequisites

* The BLE peripheral should contain one service and 2 characteristics
  * The main service
  * A request characteristic
  * A reply characteristic
* The BLE peripheral should advertise its service in the advert data
  * Below is the advert and services used in SwiftLock

```python
advertising_data = [ # Total size for this is 31 bytes
    # Flags
    0x02,  # Length (2 bytes)
    0x01,  # Type for "Flags"
    0x06,  # General discoverable mode
    
    # Services
    0x11,    # Length (17 bytes)
    0x06,    # Type for "Incomplete list of services"
    0x02, 0x00, 0x12, 0xac, 0x42, 0x02, 0x90, 0x8c, 0xee, 0x11, 0x34, 0x9f, 0x00, 0x00, 0x00, 0x00,

    # Manufacturer specific data
    0x09,  # Length (9 bytes)
    0xFF,  # Type for "Manufacturer Specific Data"
    0xFF, 0xFF,  # Company identifier: default for testing purposes
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06  # Custom Manufacturing Data - Used for serial number
]
scan_response = [
    0x0a,  # Length
    0x09,  # Full name
    0x53, 0x77, 0x69, 0x66, 0x74, 0x4c, 0x6f, 0x63, 0x6b,  # UTF-8 device name - 'SwiftLock'
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  # Reserved
]

service_uuid = '00000000-9f34-11ee-8c90-0242ac120002'
request_uuid = '00000001-9f34-11ee-8c90-0242ac120002'
reply_uuid = '00000002-9f34-11ee-8c90-0242ac120002'
```

## Installation

You can add LRDeviceKit to your project using Swift Package Manager. Either:

1. Add `https://github.com/lukerobertsapps/LRSwiftLock.git` as a Swift Package dependency to your project.
2. OR add the URL to your `Package.swift` file
```swift
dependencies: [
    .package(url: "https://github.com/lukerobertsapps/LRSwiftLock.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

### Setup

1. Import `LRDeviceKit`
2. Create and pass in a configuration
```swift
let configuration = LRDeviceKit.Configuration(
  serviceUUIDString: "00000000-9f34-11ee-8c90-0242ac120002",
  requestUUIDString: "00000001-9f34-11ee-8c90-0242ac120002",
  replyUUIDString: "00000002-9f34-11ee-8c90-0242ac120002",
  companyIdentifier: Data([0xFF, 0xFF]),
  features: [
    LEDToggleFeature.self,
    ...
  ]
)
LRDeviceKit.shared.setup(with: configuration)
```
3. Create commands and features. [See here.](#creating-features)
4. Create a single instance of device manager, this can be an environment object in SwiftUI
```swift
@State var deviceManager = DeviceManager()

ContentView()
  .environment(deviceManager)
```

### Discovery and Connection

Start device discovery
```swift
try deviceManager.startDiscovery()
```

Access all discoveries
```swift
ForEach(deviceManager.discoveries) { discovery in
  VStack {
    Text(discovery.name)
    Text(discovery.serial)
  }
}
```

Connect to a discovery
```swift
try await deviceManager.connect(to: discovery)
```

Connect to a saved serial number
```swift
try await deviceManager.connect(with: "010203040506")
```

### Creating Features

Create all your device features in the app layer and pass them to the library during configuration.

1. Extend MessageCommand to include your commands and namespaces. [Example here.](/Sources/LRDeviceKit/Message/MessageCommand.swift)
```swift
extension MessageCommand {
  // LED Namespace (0x05)
  static let toggleLED = MessageCommand(rawValue: 0x0105)
}
```

2. Create a `Feature`
```swift
final class LEDToggleFeature: Feature {
}
```

3. Use the Message and Handler structure to send data to your BLE peripheral 
```swift
func toggleLED(enabled: Bool) async throws {
  let payload: Data = enabled ? Data([0x01]) : Data([0x00])
  let message = Message(command: .toggleLED, payload: payload)
  try await handler.send(message)
}
```

4. Pass in all your features to the configuration
```swift
let configuration = LRDeviceKit.Configuration(
  ...,
  features: [
    LEDToggleFeature.self
  ]
)
```

### Using Features

To use your device features, you can access them through the device manager:
```swift
func buttonPressed() async throws {
  guard let feature: LEDToggleFeature = deviceManager.device?.feature() else { return }
  try await feature.toggleLED(enabled: true)
}
```
