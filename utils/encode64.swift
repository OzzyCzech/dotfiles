import Foundation

func base64Encode(_ data: Data) -> String {
    data.base64EncodedString()
}

func mimeType(path: String) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/file")
    process.arguments = ["-b", "--mime-type", path]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = FileHandle.nullDevice
    try? process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else { return nil }
    let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
        .trimmingCharacters(in: .whitespacesAndNewlines)
    return output?.isEmpty == false ? output : nil
}

let args = Array(CommandLine.arguments.dropFirst())
let manager = FileManager.default

if let first = args.first, manager.fileExists(atPath: first) {
    // File path: data URL with mime type
    var mime = mimeType(path: first) ?? "application/octet-stream"
    if mime.hasPrefix("text/") {
        mime += ";charset=utf-8"
    }
    let data = manager.contents(atPath: first) ?? Data()
    print("data:\(mime);base64,\(base64Encode(data))")
} else if args.isEmpty {
    // Stdin
    let data = FileHandle.standardInput.readDataToEndOfFile()
    print(base64Encode(data))
} else {
    // String (first argument only, like zsh "$1")
    let data = Data(args[0].utf8)
    print(base64Encode(data))
}
