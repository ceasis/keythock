import Foundation

enum KeyClassifier {
    static func classify(keyCode: Int) -> KeyCategory {
        switch keyCode {
        case 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 31, 32, 34, 35, 37, 38, 40, 45, 46:
            return .alpha
        case 18, 19, 20, 21, 22, 23, 25, 26, 28, 29:
            return .number
        case 65, 67, 69, 71, 75, 78, 81, 82, 83, 84, 85, 86, 87, 88, 89, 91, 92:
            return .numpad
        case 24, 27, 30, 33, 39, 41, 42, 43, 44, 47, 50:
            return .punctuation
        case 49:
            return .space
        case 36, 76:
            return .enter
        case 51, 117:
            return .backspace
        case 48:
            return .tab
        case 53:
            return .escape
        case 123, 124, 125, 126:
            return .arrow
        case 54, 55, 56, 57, 58, 59, 60, 61, 62, 63:
            return .modifier
        case 96, 97, 98, 99, 100, 101, 103, 105, 106, 107, 109, 111, 113, 114, 115, 116, 118, 119, 120, 121, 122:
            return .function
        default:
            return .unknown
        }
    }

    static func keyCode(for character: Character) -> Int? {
        let normalized = String(character).uppercased()
        guard normalized.count == 1, let key = normalized.first else { return nil }
        return keyCodeByCharacter[key]
    }

    private static let keyCodeByCharacter: [Character: Int] = [
        "A": 0, "S": 1, "D": 2, "F": 3, "H": 4, "G": 5,
        "Z": 6, "X": 7, "C": 8, "V": 9, "B": 11, "Q": 12,
        "W": 13, "E": 14, "R": 15, "Y": 16, "T": 17,
        "1": 18, "2": 19, "3": 20, "4": 21, "6": 22, "5": 23,
        "=": 24, "9": 25, "7": 26, "-": 27, "8": 28, "0": 29,
        "]": 30, "O": 31, "U": 32, "[": 33, "I": 34, "P": 35,
        "\n": 36, "L": 37, "J": 38, "'": 39, "K": 40, ";": 41,
        "\\": 42, ",": 43, "/": 44, "N": 45, "M": 46, ".": 47,
        "\t": 48, " ": 49, "`": 50
    ]
}
