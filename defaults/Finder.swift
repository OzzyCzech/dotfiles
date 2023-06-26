#!/usr/bin/swift

import Foundation

let domain = "com.apple.Finder"

// Set the new value
CFPreferencesSetAppValue("AppleShowAllFiles" as CFString, true as CFPropertyList, domain as CFString)

// Synchronize the changes
let synchronizeResult = CFPreferencesAppSynchronize(domain as CFString)

if synchronizeResult {
    print("Changes synchronized successfully.")
} else {
    print("Failed to synchronize changes.")
}

// Tell finder to quit
let killResult = NSAppleScript(source: "tell application \"Finder\" to quit")?.executeAndReturnError(nil);