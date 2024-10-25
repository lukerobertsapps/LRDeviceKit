// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LRDeviceKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "LRDeviceKit",
            targets: ["LRDeviceKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock.git",
            .upToNextMinor(from: "0.17.0")
        ),
        .package(
            url: "https://github.com/kishikawakatsumi/KeychainAccess.git",
            .upToNextMinor(from: "4.2.2")
        )
    ],
    targets: [
        .target(
            name: "LRDeviceKit",
            dependencies: [
                .product(name: "CoreBluetoothMock", package: "ios-corebluetooth-mock"),
                .product(name: "KeychainAccess", package: "KeychainAccess")
            ]
        ),
        .testTarget(
            name: "LRDeviceKitTests",
            dependencies: ["LRDeviceKit"]
        )
    ]
)
