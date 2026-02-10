import Foundation

enum JSONValue {
    case string(String)
    case number(NSNumber)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([(key: String, value: JSONValue)])

    static func from(_ any: Any) -> JSONValue {
        if let dict = any as? [String: Any] {
            let pairs = dict.sorted { $0.key < $1.key }.map { (key: $0.key, value: JSONValue.from($0.value)) }
            return .object(pairs)
        } else if let arr = any as? [Any] {
            return .array(arr.map { JSONValue.from($0) })
        } else if let str = any as? String {
            return .string(str)
        } else if let bool = any as? Bool {
            return .bool(bool)
        } else if let num = any as? NSNumber {
            return .number(num)
        } else if any is NSNull {
            return .null
        }
        return .null
    }

    var isContainer: Bool {
        switch self {
        case .array, .object:
            return true
        default:
            return false
        }
    }

    var typeName: String {
        switch self {
        case .string: return "String"
        case .number: return "Number"
        case .bool: return "Boolean"
        case .null: return "Null"
        case .array(let items): return "Array [\(items.count)]"
        case .object(let pairs): return "Object {\(pairs.count)}"
        }
    }

    var displayValue: String {
        switch self {
        case .string(let s): return "\"\(s)\""
        case .number(let n): return "\(n)"
        case .bool(let b): return b ? "true" : "false"
        case .null: return "null"
        case .array(let items): return "[\(items.count) items]"
        case .object(let pairs): return "{\(pairs.count) keys}"
        }
    }
}

struct JSONNodeItem: Identifiable {
    let id = UUID()
    let key: String?
    let index: Int?
    let value: JSONValue

    var children: [JSONNodeItem]? {
        switch value {
        case .object(let pairs):
            return pairs.map { JSONNodeItem(key: $0.key, index: nil, value: $0.value) }
        case .array(let items):
            return items.enumerated().map { JSONNodeItem(key: nil, index: $0.offset, value: $0.element) }
        default:
            return nil
        }
    }

    var label: String {
        if let key = key {
            return key
        } else if let index = index {
            return "[\(index)]"
        }
        return "root"
    }
}
