import Foundation
import Security

// MARK: - Usage

func printUsage() -> Never {
    fputs("""
    Usage: password [options]

    Options:
      -w, --words <count>   Generate a passphrase with N words (default: 4)
      -r, --random <length> Generate a random alphanumeric password (default: 24)
      -x, --special         Include special characters (@&$!#?) in random password
      -s, --separator <sep> Word separator for passphrase (default: -)
      -h, --help            Show this help

    Examples:
      password              → bridge-copper-flame-robot
      password -w 6         → apple-storm-quiet-brave-clock-shelf
      password -r 32        → k8Tz4mWqX2vBnR7jL9pY3cA6dF1hG5s
      password -r 32 -x     → k8T#4mW&X2v!nR7$L9pY3?A6dF1hG5s
      password -s .         → bridge.copper.flame.robot

    """, stderr)
    exit(0)
}

// MARK: - Random bytes helper

func secureRandomBytes(_ count: Int) -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: count)
    guard SecRandomCopyBytes(kSecRandomDefault, count, &bytes) == errSecSuccess else {
        fputs("password: failed to generate random bytes\n", stderr)
        exit(1)
    }
    return bytes
}

// MARK: - Random alphanumeric password

func generateRandom(length: Int, special: Bool) -> String {
    var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    if special { chars += "@&$!#?" }
    let charset = Array(chars)
    let bytes = secureRandomBytes(length)
    return String(bytes.map { charset[Int($0) % charset.count] })
}

// MARK: - Passphrase generator

func loadWords() -> [String] {
    let path = "/usr/share/dict/words"
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        fputs("password: cannot read \(path)\n", stderr)
        exit(1)
    }
    return content
        .components(separatedBy: .newlines)
        .filter { word in
            let len = word.count
            return len >= 4 && len <= 8 && word == word.lowercased() && word.allSatisfy(\.isLetter)
        }
}

func generatePassphrase(wordCount: Int, separator: String) -> String {
    let words = loadWords()
    guard !words.isEmpty else {
        fputs("password: no suitable words found\n", stderr)
        exit(1)
    }

    let bytes = secureRandomBytes(wordCount * 4) // 4 bytes per word for uniform random
    var selected: [String] = []
    for i in 0..<wordCount {
        let offset = i * 4
        let value = bytes[offset..<offset+4].enumerated().reduce(0) { acc, pair in
            acc | (UInt32(pair.element) << (pair.offset * 8))
        }
        selected.append(words[Int(value % UInt32(words.count))])
    }
    return selected.joined(separator: separator)
}

// MARK: - Argument parsing

var mode: String = "passphrase"
var wordCount = 4
var randomLength = 24
var separator = "-"
var special = false

var args = Array(CommandLine.arguments.dropFirst())
while !args.isEmpty {
    let arg = args.removeFirst()
    switch arg {
    case "-w", "--words":
        mode = "passphrase"
        if let next = args.first, let n = Int(next), n > 0 { wordCount = n; args.removeFirst() }
    case "-r", "--random":
        mode = "random"
        if let next = args.first, let n = Int(next), n > 0 { randomLength = n; args.removeFirst() }
    case "-x", "--special":
        special = true
    case "-s", "--separator":
        guard let next = args.first else { printUsage() }
        separator = next; args.removeFirst()
    case "-h", "--help":
        printUsage()
    default:
        if let n = Int(arg), n > 0 {
            wordCount = n // bare number = word count (backwards compat with old usage)
        } else {
            fputs("password: unknown option '\(arg)'\n", stderr)
            printUsage()
        }
    }
}

// MARK: - Output

switch mode {
case "random":
    print(generateRandom(length: randomLength, special: special))
default:
    print(generatePassphrase(wordCount: wordCount, separator: separator))
}
