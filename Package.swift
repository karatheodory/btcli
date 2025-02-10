import PackageDescription

let name = "btctl"
let package = Package(
    name: name,
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(name: name, path: "")
    ]
)
