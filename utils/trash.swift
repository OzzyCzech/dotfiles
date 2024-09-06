import Foundation

let manager = FileManager.default

var success = true

if CommandLine.arguments.count < 2 {
    print("Usage: trash <item> [item1] [item2] ...")
    exit(1)
}

let args = Array(CommandLine.arguments.dropFirst())

for item in args {
    do {
        let url = URL(fileURLWithPath: item)
        try manager.trashItem(at: url, resultingItemURL: nil)
    } catch {
        print("Failed to trash \(item): \(error.localizedDescription)")
        success = false
    }
}

guard success else {
    exit(1)
}