// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "LightNovelPub",
    platforms: [
        .iOS(.v16_0)
    ],
    products: [
        .executable(
            name: "LightNovelPub",
            targets: ["LightNovelPub"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "LightNovelPub",
            dependencies: [],
            path: "src",
            swiftSettings: [
                .unsafeFlags([
                    "-framework", "UIKit",
                    "-framework", "WebKit",
                    "-framework", "SafariServices",
                    "-framework", "UserNotifications",
                    "-framework", "SwiftUI"
                ])
            ]
        )
    ]
)
