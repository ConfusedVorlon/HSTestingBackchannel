// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "HSTestingBackchannel",
    platforms: [
        .iOS(.v10), .tvOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HSTestingBackchannel",
            targets: ["HSTestingBackchannel"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HSTestingBackchannel",
            path: "Classes",
            publicHeadersPath: "Classes/**/*",
            cSettings: [
                .headerSearchPath("Classes")
            ]
        ),
    ]
)
