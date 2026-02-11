#!/usr/bin/env swift
//
// backup — backs up files and directories to the output directory while preserving structure.
//
// Usage:
//   backup -c <config.json> <output_directory>
//   backup <path1> <path2> ... <output_directory>
//
// Configuration (JSON): array of objects { "name": "Name", "paths": ["~/path", ...] }
// Supports: ["path"], { "sources": [...] }, { "key": [paths] }
//

import Foundation

// MARK: - Paths

enum Paths {
    static let home = (NSString(string: "~").expandingTildeInPath as NSString).standardizingPath

    static func expand(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }

    /// For display: under home → ~/..., otherwise absolute
    static func short(_ absolute: String) -> String {
        let abs = (absolute as NSString).standardizingPath
        if abs.hasPrefix(home) {
            let suffix = String(abs.dropFirst(home.count))
            return "~" + (suffix.hasPrefix("/") ? suffix : "/" + suffix)
        }
        return abs
    }

    /// Relative path under backup root (under home → relative to home)
    static func relativeToBackupRoot(absolute: String) -> String {
        let abs = (absolute as NSString).standardizingPath
        if abs.hasPrefix(home) {
            let suffix = String(abs.dropFirst(home.count))
            return suffix.hasPrefix("/") ? String(suffix.dropFirst(1)) : suffix
        }
        return abs.hasPrefix("/") ? String(abs.dropFirst(1)) : abs
    }
}

// MARK: - Configuration

struct BackupGroup {
    var name: String?
    var paths: [String]
}

struct BackupConfig {
    var groups: [BackupGroup]
}

extension BackupConfig {
    /// Load configuration from JSON file
    static func load(from path: String) -> BackupConfig? {
        let fullPath = Paths.expand(path)
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)),
              let json = try? JSONSerialization.jsonObject(with: data) else { return nil }
        return parse(json)
    }

    /// Parse JSON into a uniform format [ { name, paths } ]
    static func parse(_ json: Any) -> BackupConfig? {
        if let arr = json as? [String] {
            return BackupConfig(groups: [BackupGroup(name: nil, paths: arr)])
        }
        if let arr = json as? [[String: Any]] {
            let groups = arr.compactMap { entry -> BackupGroup? in
                guard let paths = entry["paths"] as? [String], !paths.isEmpty else { return nil }
                let name = entry["name"] as? String
                return BackupGroup(name: name, paths: paths)
            }
            return groups.isEmpty ? nil : BackupConfig(groups: groups)
        }
        guard let obj = json as? [String: Any] else { return nil }
        if let arr = obj["sources"] as? [String] {
            return BackupConfig(groups: [BackupGroup(name: nil, paths: arr)])
        }
        var groups: [BackupGroup] = []
        for (name, value) in obj {
            guard let paths = value as? [String], !paths.isEmpty else { continue }
            groups.append(BackupGroup(name: name, paths: paths))
        }
        return groups.isEmpty ? nil : BackupConfig(groups: groups)
    }

    /// All items (group + path) in order for backup
    func items() -> [(group: String?, path: String)] {
        groups.flatMap { g in
            g.paths.map { (g.name, Paths.expand($0)) }
        }
    }
}

// MARK: - Backup

enum CopyOutcome {
    case copied
    case skipped(reason: String)
    case failed(Error)
}

final class BackupRunner {
    private let fileManager = FileManager.default
    private let outputDir: URL
    private let dryRun: Bool

    init(outputDir: URL, dryRun: Bool = false) {
        self.outputDir = outputDir
        self.dryRun = dryRun
    }

    func run(config: BackupConfig) -> (copied: Int, skipped: Int, failed: Int) {
        try? fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true)
        var copied = 0, skipped = 0, failed = 0
        var lastGroup: String? = nil
        let items = config.items()

        for (group, path) in items {
            if group != lastGroup {
                if lastGroup != nil { print() }
                lastGroup = group
                if let name = group, !name.isEmpty { print(name) }
            }

            let displayPath = Paths.short(path)
            let outcome = copyItem(absolutePath: path)

            switch outcome {
            case .copied:
                print("  ✓ \(displayPath)")
                copied += 1
            case .skipped(let reason):
                print("  − \(displayPath)  (\(reason))")
                skipped += 1
            case .failed(let error):
                fputs("  ✗ \(displayPath)  \(error.localizedDescription)\n", stderr)
                failed += 1
            }
        }

        if copied + skipped + failed > 0 {
            print()
            var parts: [String] = []
            if copied > 0 { parts.append("Copied: \(copied)") }
            if skipped > 0 { parts.append("Skipped: \(skipped)") }
            if failed > 0 { parts.append("Failed: \(failed)") }
            print(parts.joined(separator: "  "))
        }

        return (copied, skipped, failed)
    }

    private func copyItem(absolutePath: String) -> CopyOutcome {
        let src = URL(fileURLWithPath: (absolutePath as NSString).standardizingPath)
        guard fileManager.fileExists(atPath: src.path) else {
            return .skipped(reason: "not found")
        }
        let relative = Paths.relativeToBackupRoot(absolute: src.path)
        let dest = outputDir.appendingPathComponent(relative)

        if dryRun {
            return .copied
        }
        do {
            try fileManager.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
            if fileManager.fileExists(atPath: dest.path) {
                try fileManager.removeItem(at: dest)
            }
            try fileManager.copyItem(at: src, to: dest)
            return .copied
        } catch {
            return .failed(error)
        }
    }
}

// MARK: - Command Line Interface

struct CommandLineInterface {
    static let usage = """
        Usage: backup -c <config.json> <output_dir>
               backup <path1> <path2> ... <output_dir>

        Options:
          -c, --config <file>   load sources from JSON
          --dry-run             only print, do not copy
        """

    static func run() {
        var args = Array(CommandLine.arguments.dropFirst())
        if args.first?.hasSuffix(".swift") == true { args.removeFirst() }

        guard !args.isEmpty else {
            fputs(usage + "\n", stderr)
            exit(1)
        }

        let dryRun = args.contains("--dry-run")
        args.removeAll { $0 == "--dry-run" }

        let config: BackupConfig
        let outputDirArg: String

        if args.first == "-c" || args.first == "--config" {
            args.removeFirst()
            guard args.count >= 2 else {
                fputs("When using -c, the config path and output directory are required.\n" + usage + "\n", stderr)
                exit(1)
            }
            let configPath = args.removeFirst()
            outputDirArg = args.removeLast()
            guard args.isEmpty else {
                fputs("When using -c, only the config and output directory are required.\n" + usage + "\n", stderr)
                exit(1)
            }
            guard let loaded = BackupConfig.load(from: configPath) else {
                fputs("Cannot load config: \(configPath). Expected JSON: [ { \"name\", \"paths\" } ] or equivalent.\n", stderr)
                exit(1)
            }
            config = loaded
        } else {
            guard args.count >= 2 else {
                fputs("At least one source path and output directory are required.\n" + usage + "\n", stderr)
                exit(1)
            }
            outputDirArg = args.removeLast()
            config = BackupConfig(groups: [BackupGroup(name: nil, paths: args)])
        }

        if config.groups.isEmpty || config.items().isEmpty {
            fputs("No sources to backup.\n", stderr)
            exit(1)
        }

        let outputDir = URL(fileURLWithPath: Paths.expand(outputDirArg))
        let runner = BackupRunner(outputDir: outputDir, dryRun: dryRun)
        let (_, _, failed) = runner.run(config: config)

        if failed > 0 { exit(2) }
    }
}

CommandLineInterface.run()
