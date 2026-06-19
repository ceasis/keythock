import Foundation

enum MorseCode {
    static func pattern(forKeyCode keyCode: Int) -> String? {
        guard let character = characterByKeyCode[keyCode] else { return nil }
        return patternByCharacter[character]
    }

    static func isWordGapKey(_ keyCode: Int) -> Bool {
        keyCode == 49
    }

    static func isMorsePack(_ pack: SoundPack) -> Bool {
        pack.source.manifest.category.lowercased() == "morse"
    }

    static func unitDuration(for pack: SoundPack) -> TimeInterval {
        switch pack.id {
        case "com.keythock.pack.morse2.synth":
            return 0.085
        case "com.keythock.pack.morse3.synth":
            return 0.065
        default:
            return 0.075
        }
    }

    private static let characterByKeyCode: [Int: Character] = [
        0: "A", 11: "B", 8: "C", 2: "D", 14: "E", 3: "F",
        5: "G", 4: "H", 34: "I", 38: "J", 40: "K", 37: "L",
        46: "M", 45: "N", 31: "O", 35: "P", 12: "Q", 15: "R",
        1: "S", 17: "T", 32: "U", 9: "V", 13: "W", 7: "X",
        16: "Y", 6: "Z",
        29: "0", 18: "1", 19: "2", 20: "3", 21: "4", 23: "5",
        22: "6", 26: "7", 28: "8", 25: "9"
    ]

    private static let patternByCharacter: [Character: String] = [
        "A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".",
        "F": "..-.", "G": "--.", "H": "....", "I": "..", "J": ".---",
        "K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---",
        "P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
        "U": "..-", "V": "...-", "W": ".--", "X": "-..-", "Y": "-.--",
        "Z": "--..",
        "0": "-----", "1": ".----", "2": "..---", "3": "...--", "4": "....-",
        "5": ".....", "6": "-....", "7": "--...", "8": "---..", "9": "----."
    ]
}
