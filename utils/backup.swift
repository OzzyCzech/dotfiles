#!/usr/bin/env swift
//
// Backup utility: copies files and directories to an output directory.
//
// Usage:
//   backup -c <config.json> <out>        — sources from JSON config
//   backup <source1> <source2> ... <out> — copy listed paths into out/
//
// Config (JSON): ["path1", "path2"] | { "sources": [...] } | { "zed": [...], "vscode": [...] }
//                | [ { "name": "Zed", "paths": ["~/.config/zed/settings.json", ...] }, ... ]
//
// Only existing files/directories are copied. Paths with ~ are expanded.
//

import Foundation

let manager = FileManager.default

func expandPath(_ path: String) -> String {
    (path as NSString).expandingTildeInPath
}

let homePath = expandPath("~")

/// Display path: under home → "~/" + relative; else absolute.
func shortPath(absolutePath: String) -> String {
    let abs = (absolutePath as NSString).standardizingPath
    if abs.hasPrefix(homePath) {
        let suffix = String(abs.dropFirst(homePath.count))
        return "~" + (suffix.hasPrefix("/") ? suffix : "/" + suffix)
    }
    return abs
}

/// Returns path to preserve under backup root: under home → relative to home; else → relative to /.
func relativeBackupPath(absolutePath: String) -> String {
    let abs = (absolutePath as NSString).standardizingPath
    if abs.hasPrefix(homePath) {
        let suffix = String(abs.dropFirst(homePath.count))
        return suffix.hasPrefix("/") ? String(suffix.dropFirst(1)) : suffix
    }
    return abs.hasPrefix("/") ? String(abs.dropFirst(1)) : abs
}

func copyItem(at src: URL, to dest: URL) throws {
    try manager.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
    if manager.fileExists(atPath: dest.path) {
        try manager.removeItem(at: dest)
    }
    try manager.copyItem(at: src, to: dest)
}

/// One source entry: optional group name (folder under out), and absolute path.
struct BackupItem {
    let group: String?
    let path: String
}

/// Parse JSON object/array into backup items.
/// Supports: array of paths, { "sources": [...] }, { "key": [paths] }, or [ { "name", "paths" } ].
func parseBackupJSON(_ json: Any) -> [BackupItem]? {
    if let arr = json as? [String] {
        return arr.map { BackupItem(group: nil, path: expandPath($0)) }
    }
    // New format: [ { "name": "Zed", "paths": ["...", ...] }, ... ]
    if let arr = json as? [[String: Any]] {
        var items: [BackupItem] = []
        for entry in arr {
            guard let paths = entry["paths"] as? [String] else { continue }
            let name = entry["name"] as? String
            for p in paths {
                items.append(BackupItem(group: name, path: expandPath(p)))
            }
        }
        return items.isEmpty ? nil : items
    }
    guard let obj = json as? [String: Any] else { return nil }
    if let arr = obj["sources"] as? [String] {
        return arr.map { BackupItem(group: nil, path: expandPath($0)) }
    }
    var items: [BackupItem] = []
    for (name, value) in obj {
        guard let paths = value as? [String] else { continue }
        for p in paths {
            items.append(BackupItem(group: name, path: expandPath(p)))
        }
    }
    return items.isEmpty ? nil : items
}

/// Load backup items from a JSON config file.
func loadBackupItems(fromConfigPath path: String) -> [BackupItem]? {
    let expanded = expandPath(path)
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: expanded)),
          let json = try? JSONSerialization.jsonObject(with: data) else { return nil }
    return parseBackupJSON(json)
}

func run() {
    var args = Array(CommandLine.arguments.dropFirst())
    if args.first?.hasSuffix(".swift") == true {
        args.removeFirst()
    }

    let usage = "Usage: backup -c <config.json> <out>  or  backup <source1> <source2> ... <out>\n"
    guard !args.isEmpty else {
        fputs(usage, stderr)
        exit(1)
    }

    var outDirArg: String
    var items: [BackupItem]

    if args.first == "-c" || args.first == "--config" {
        args.removeFirst()
        guard args.count >= 2 else {
            fputs("With -c: provide config path and output dir.\n" + usage, stderr)
            exit(1)
        }
        let configPath = args.removeFirst()
        outDirArg = args.removeLast()
        guard args.isEmpty else {
            fputs("With -c: only config path and output dir allowed.\n" + usage, stderr)
            exit(1)
        }
        guard let loaded = loadBackupItems(fromConfigPath: configPath) else {
            fputs("Failed to load config from \(configPath). Use JSON: array of paths, { \"sources\": [...] }, { \"key\": [paths] }, or [ { \"name\", \"paths\" } ].\n", stderr)
            exit(1)
        }
        items = loaded
    } else {
        guard args.count >= 2 else {
            fputs("Provide at least one source and output dir.\n" + usage, stderr)
            exit(1)
        }
        outDirArg = args.removeLast()
        items = args.map { BackupItem(group: nil, path: expandPath($0)) }
    }

    let outDirPath = expandPath(outDirArg)
    let outDir = URL(fileURLWithPath: outDirPath)

    if items.isEmpty {
        fputs("No sources to backup.\n", stderr)
        exit(1)
    }

    do {
        try manager.createDirectory(at: outDir, withIntermediateDirectories: true)
    } catch {
        fputs("Cannot create output directory \(outDirPath): \(error)\n", stderr)
        exit(1)
    }

    var copied = 0
    var skipped = 0
    var lastGroup: String? = nil

    for item in items {
        if item.group != lastGroup {
            if lastGroup != nil { print() }
            lastGroup = item.group
            if let name = item.group, !name.isEmpty {
                print("\(name)")
            }
        }

        let url = URL(fileURLWithPath: item.path)
        let displaySrc = shortPath(absolutePath: item.path)

        guard manager.fileExists(atPath: url.path) else {
            print("  − \(displaySrc)  (not found)")
            skipped += 1
            continue
        }

        let relative = relativeBackupPath(absolutePath: url.path)
        // Keep original directory structure only; no subfolders per config name
        let destPath = (outDir.path as NSString).appendingPathComponent(relative)
        let dest = URL(fileURLWithPath: destPath)
        do {
            try copyItem(at: url, to: dest)
            print("  ✓ \(displaySrc)")
            copied += 1
        } catch {
            fputs("  ✗ \(displaySrc)  \(error)\n", stderr)
        }
    }

    if copied > 0 || skipped > 0 {
        print()
        var parts: [String] = []
        if copied > 0 { parts.append("Copied: \(copied)") }
        if skipped > 0 { parts.append("Skipped: \(skipped)") }
        print(parts.joined(separator: "  "))
    }
}

run()
