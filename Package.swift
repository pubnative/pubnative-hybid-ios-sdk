// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HyBid",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "HyBid",
            targets: ["HyBid", "OMSDK_Pubnativenet"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "HyBid",
            url: "https://github.com/pubnative/pubnative-hybid-ios-sdk/releases/download/3.7.1/HyBid.xcframework.zip",
            checksum: "eb3b53b3176973e0f3b6973d68ae89e094e07fdcda681b918921ccde27c2c0ae"
        ),
        .binaryTarget(
            name: "OMSDK_Pubnativenet",
            url: "https://github.com/pubnative/pubnative-hybid-ios-sdk/releases/download/3.7.1/HyBid.xcframework.zip",
            checksum: "eb3b53b3176973e0f3b6973d68ae89e094e07fdcda681b918921ccde27c2c0ae" 
        )
    ]
)
