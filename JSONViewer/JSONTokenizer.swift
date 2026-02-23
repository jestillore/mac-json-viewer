import Foundation

enum JSONTokenType {
    case objectKey
    case string
    case number
    case bool
    case null
    case punctuation
}

struct JSONToken {
    let type: JSONTokenType
    let range: NSRange
}

func tokenizeJSON(_ text: String) -> [JSONToken] {
    let utf16 = text.utf16
    var tokens: [JSONToken] = []
    var i = utf16.startIndex

    func peek() -> UInt16? {
        guard i < utf16.endIndex else { return nil }
        return utf16[i]
    }

    func advance() {
        i = utf16.index(after: i)
    }

    func offset(of index: String.UTF16View.Index) -> Int {
        utf16.distance(from: utf16.startIndex, to: index)
    }

    func skipWhitespace() {
        while let ch = peek(), ch == 0x20 || ch == 0x09 || ch == 0x0A || ch == 0x0D {
            advance()
        }
    }

    while i < utf16.endIndex {
        skipWhitespace()
        guard let ch = peek() else { break }

        // String
        if ch == 0x22 { // "
            let start = offset(of: i)
            advance() // skip opening quote
            while let c = peek() {
                if c == 0x5C { // backslash
                    advance()
                    if peek() != nil { advance() } // skip escaped char
                } else if c == 0x22 { // closing quote
                    advance()
                    break
                } else {
                    advance()
                }
            }
            let end = offset(of: i)
            let range = NSRange(location: start, length: end - start)

            // Look ahead: if next non-whitespace is ':', this is an object key
            let savedIndex = i
            skipWhitespace()
            if let next = peek(), next == 0x3A { // :
                tokens.append(JSONToken(type: .objectKey, range: range))
            } else {
                tokens.append(JSONToken(type: .string, range: range))
            }
            i = savedIndex
            continue
        }

        // Numbers: starts with digit or minus
        if ch == 0x2D || (ch >= 0x30 && ch <= 0x39) { // - or 0-9
            let start = offset(of: i)
            if ch == 0x2D { advance() }
            while let c = peek(), c >= 0x30 && c <= 0x39 { advance() } // digits
            if let c = peek(), c == 0x2E { // .
                advance()
                while let c = peek(), c >= 0x30 && c <= 0x39 { advance() }
            }
            if let c = peek(), c == 0x65 || c == 0x45 { // e or E
                advance()
                if let c = peek(), c == 0x2B || c == 0x2D { advance() } // + or -
                while let c = peek(), c >= 0x30 && c <= 0x39 { advance() }
            }
            let end = offset(of: i)
            tokens.append(JSONToken(type: .number, range: NSRange(location: start, length: end - start)))
            continue
        }

        // true
        if ch == 0x74 { // t
            let start = offset(of: i)
            let word: [UInt16] = [0x74, 0x72, 0x75, 0x65] // true
            var matched = true
            for expected in word {
                guard let c = peek(), c == expected else { matched = false; break }
                advance()
            }
            if matched {
                tokens.append(JSONToken(type: .bool, range: NSRange(location: start, length: 4)))
            }
            continue
        }

        // false
        if ch == 0x66 { // f
            let start = offset(of: i)
            let word: [UInt16] = [0x66, 0x61, 0x6C, 0x73, 0x65] // false
            var matched = true
            for expected in word {
                guard let c = peek(), c == expected else { matched = false; break }
                advance()
            }
            if matched {
                tokens.append(JSONToken(type: .bool, range: NSRange(location: start, length: 5)))
            }
            continue
        }

        // null
        if ch == 0x6E { // n
            let start = offset(of: i)
            let word: [UInt16] = [0x6E, 0x75, 0x6C, 0x6C] // null
            var matched = true
            for expected in word {
                guard let c = peek(), c == expected else { matched = false; break }
                advance()
            }
            if matched {
                tokens.append(JSONToken(type: .null, range: NSRange(location: start, length: 4)))
            }
            continue
        }

        // Structural characters: { } [ ] : ,
        if ch == 0x7B || ch == 0x7D || ch == 0x5B || ch == 0x5D || ch == 0x3A || ch == 0x2C {
            let start = offset(of: i)
            tokens.append(JSONToken(type: .punctuation, range: NSRange(location: start, length: 1)))
            advance()
            continue
        }

        // Unrecognized character — skip
        advance()
    }

    return tokens
}
