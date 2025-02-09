// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LightNovelPub",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LightNovelPub",
            targets: ["LightNovelPub"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.6.0")
    ],
    targets: [
        .target(
            name: "LightNovelPub",
            dependencies: [
                "Alamofire",
                "Kingfisher", 
                "SwiftyJSON",
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "LightNovelPubTests",
            dependencies: ["LightNovelPub"],
            path: "Tests"
        )
    ]
)
