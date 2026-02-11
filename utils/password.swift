import Foundation
import Security

let length: Int
if let arg = CommandLine.arguments.dropFirst().first, let n = Int(arg), n > 0 {
    length = n
} else {
    length = 24
}

var bytes = [UInt8](repeating: 0, count: length)
guard SecRandomCopyBytes(kSecRandomDefault, length, &bytes) == errSecSuccess else {
    fputs("password: failed to generate random bytes\n", stderr)
    exit(1)
}

let base64 = Data(bytes).base64EncodedString()
let alphanumeric = base64.filter { $0.isLetter || $0.isNumber }
print(alphanumeric)
