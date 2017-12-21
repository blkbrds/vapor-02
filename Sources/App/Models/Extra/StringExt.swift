//
//  StringExt.swift
//  App
//
//  Created by hai phung on 12/6/17.
//

import Foundation

extension String {

    struct Regex {
        static let email = "[a-z]+(\\.[a-z]+([1-9][0-9]*)*)*@asiantech\\.vn"
    }

    func validate(_ regex: String) -> Bool {
        return matches(regex).isNotEmpty
    }

    func isValidPassword() -> Bool {
        return characters.count > 5 && characters.count < 30
    }

    private func matches(_ regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let string = NSString(string: self)
            let result = regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length))
            return result.map { string.substring(with: $0.range) }
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func snake_case() -> String {
        let characters = Array(self.characters)
        guard var expanded = characters.first.flatMap({ String($0) }) else { return self }
        characters.suffix(from: 1).forEach { char in
            if char.isUppercase {
                expanded.append("_")
            }
            expanded.append(char)
        }
        return expanded.lowercased()
    }
}

extension Character {
    var isUppercase: Bool {
        switch self {
        case "A"..."Z":
            return true
        default:
            return false
        }
    }
}

extension Collection {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}
