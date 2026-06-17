import AVFoundation
import Foundation

@MainActor
final class SoundPackManager: ObservableObject {
    @Published private(set) var customPacks: [SoundPack] = []
    @Published private(set) var favorites: Set<String> = []
    @Published var importMessage: String?

    private let favoritesKey = "soundpack.favorites.v1"
    private let importedDirectory: URL

    let builtInPacks: [SoundPack] = BuiltInPacks.all

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Thock Studio", isDirectory: true)
        importedDirectory = appSupport.appendingPathComponent("ImportedPacks", isDirectory: true)
        try? FileManager.default.createDirectory(at: importedDirectory, withIntermediateDirectories: true)
        favorites = Set(UserDefaults.standard.stringArray(forKey: favoritesKey) ?? [])
        loadImportedPacks()
    }

    var allPacks: [SoundPack] {
        builtInPacks + customPacks
    }

    func pack(with id: String) -> SoundPack {
        allPacks.first { $0.id == id } ?? builtInPacks[0]
    }

    func toggleFavorite(_ pack: SoundPack) {
        if favorites.contains(pack.id) {
            favorites.remove(pack.id)
        } else {
            favorites.insert(pack.id)
        }
        UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
    }

    func importPack(from sourceURL: URL) throws -> SoundPack {
        let accessed = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessed { sourceURL.stopAccessingSecurityScopedResource() }
        }

        let preparedURL = try prepareImportSource(sourceURL)
        let manifestURL = preparedURL.appendingPathComponent("manifest.json")
        let manifestData = try Data(contentsOf: manifestURL)
        let manifest = try JSONDecoder().decode(SoundPackManifest.self, from: manifestData)
        try validate(manifest: manifest, baseURL: preparedURL)

        let safeName = manifest.packId.replacingOccurrences(of: "[^A-Za-z0-9._-]", with: "-", options: .regularExpression)
        var destination = importedDirectory.appendingPathComponent(safeName, isDirectory: true)
        var suffix = 2
        while FileManager.default.fileExists(atPath: destination.path) {
            destination = importedDirectory.appendingPathComponent("\(safeName)-\(suffix)", isDirectory: true)
            suffix += 1
        }
        try FileManager.default.copyItem(at: preparedURL, to: destination)

        let pack = SoundPack(
            id: manifest.packId,
            name: manifest.name,
            category: manifest.category.capitalized,
            loudness: manifest.loudness.capitalized,
            tone: manifest.tone.capitalized,
            bestFor: "Custom",
            description: manifest.description,
            isPremium: manifest.isPremium ?? false,
            recommendedVolume: manifest.recommendedVolume ?? 0.55,
            pitchVariationDefault: manifest.pitchVariationDefault ?? 0.02,
            sampleVariationDefault: manifest.sampleVariationDefault ?? true,
            supportsPress: manifest.supportsPress ?? true,
            supportsRelease: manifest.supportsRelease ?? true,
            source: .imported(baseURL: destination, manifest: manifest)
        )
        customPacks.append(pack)
        importMessage = "Imported \(pack.name)"
        return pack
    }

    func deleteImportedPack(_ pack: SoundPack) {
        guard case let .imported(baseURL, _) = pack.source else { return }
        try? FileManager.default.removeItem(at: baseURL)
        customPacks.removeAll { $0.id == pack.id }
    }

    private func loadImportedPacks() {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: importedDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return
        }

        customPacks = contents.compactMap { url in
            guard let data = try? Data(contentsOf: url.appendingPathComponent("manifest.json")),
                  let manifest = try? JSONDecoder().decode(SoundPackManifest.self, from: data),
                  (try? validate(manifest: manifest, baseURL: url)) != nil else {
                return nil
            }
            return SoundPack(
                id: manifest.packId,
                name: manifest.name,
                category: manifest.category.capitalized,
                loudness: manifest.loudness.capitalized,
                tone: manifest.tone.capitalized,
                bestFor: "Custom",
                description: manifest.description,
                isPremium: manifest.isPremium ?? false,
                recommendedVolume: manifest.recommendedVolume ?? 0.55,
                pitchVariationDefault: manifest.pitchVariationDefault ?? 0.02,
                sampleVariationDefault: manifest.sampleVariationDefault ?? true,
                supportsPress: manifest.supportsPress ?? true,
                supportsRelease: manifest.supportsRelease ?? true,
                source: .imported(baseURL: url, manifest: manifest)
            )
        }
    }

    private func prepareImportSource(_ sourceURL: URL) throws -> URL {
        let resourceValues = try sourceURL.resourceValues(forKeys: [.isDirectoryKey])
        if resourceValues.isDirectory == true {
            return sourceURL
        }

        let ext = sourceURL.pathExtension.lowercased()
        guard ext == "zip" || ext == "thockpack" else {
            throw ImportError.unsupportedFormat
        }

        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent("ThockImport-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = ["-x", "-k", sourceURL.path, destination.path]
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw ImportError.unzipFailed
        }

        let directManifest = destination.appendingPathComponent("manifest.json")
        if FileManager.default.fileExists(atPath: directManifest.path) {
            return destination
        }

        let children = try FileManager.default.contentsOfDirectory(at: destination, includingPropertiesForKeys: [.isDirectoryKey])
        if let nested = children.first(where: { FileManager.default.fileExists(atPath: $0.appendingPathComponent("manifest.json").path) }) {
            return nested
        }
        return destination
    }

    private func validate(manifest: SoundPackManifest, baseURL: URL) throws {
        guard manifest.schemaVersion == 1 else { throw ImportError.invalidManifest("Unsupported schema version.") }
        guard !manifest.packId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ImportError.invalidManifest("Missing packId.")
        }
        guard !manifest.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ImportError.invalidManifest("Missing name.")
        }
        guard manifest.version.range(of: #"^\d+\.\d+\.\d+$"#, options: .regularExpression) != nil else {
            throw ImportError.invalidManifest("Version must use semantic version format.")
        }
        guard let alpha = manifest.samples[KeyCategory.alpha.rawValue],
              let press = alpha.press,
              !press.isEmpty else {
            throw ImportError.invalidManifest("At least one alpha press sample is required.")
        }

        for sampleSet in manifest.samples.values {
            for relativePath in (sampleSet.press ?? []) + (sampleSet.release ?? []) {
                let fileURL = baseURL.appendingPathComponent(relativePath)
                let standardized = fileURL.standardizedFileURL.path
                guard standardized.hasPrefix(baseURL.standardizedFileURL.path) else {
                    throw ImportError.invalidManifest("Sample path escapes the pack folder.")
                }
                guard FileManager.default.fileExists(atPath: fileURL.path) else {
                    throw ImportError.invalidManifest("Missing sample: \(relativePath)")
                }
                _ = try AVAudioFile(forReading: fileURL)
            }
        }
    }

    enum ImportError: LocalizedError {
        case unsupportedFormat
        case unzipFailed
        case invalidManifest(String)

        var errorDescription: String? {
            switch self {
            case .unsupportedFormat:
                return "Choose a .thockpack, .zip, or folder."
            case .unzipFailed:
                return "The archive could not be expanded."
            case let .invalidManifest(reason):
                return reason
            }
        }
    }
}

enum BuiltInPacks {
    static let all: [SoundPack] = [
        bundledCreamyKeyboard,
        bundledRecordingPack(
            id: "com.thockstudio.pack.creamy2.recording",
            name: "Creamy-2",
            resourcePath: "SoundPacks/Creamy2",
            category: "linear",
            tone: "balanced",
            loudness: "medium",
            bestFor: "Recorded Feel",
            description: "Creamy keypress samples extracted from the first section of Creamy VS Clacky VS Thocky.",
            recommendedVolume: 0.46,
            pitchVariationDefault: 0.010
        ),
        bundledRecordingPack(
            id: "com.thockstudio.pack.creamy3.recording",
            name: "Creamy-3",
            resourcePath: "SoundPacks/Creamy3",
            category: "linear",
            tone: "balanced",
            loudness: "medium",
            bestFor: "Recorded Feel",
            description: "Creamy keypress samples extracted from creamy.mov.",
            recommendedVolume: 0.46,
            pitchVariationDefault: 0.010,
            sampleCount: 13
        ),
        bundledRecordingPack(
            id: "com.thockstudio.pack.clacky1.recording",
            name: "Clacky-1",
            resourcePath: "SoundPacks/Clacky1",
            category: "clicky",
            tone: "bright",
            loudness: "loud",
            bestFor: "Crisp Typing",
            description: "Clacky keypress samples extracted from the middle section of Creamy VS Clacky VS Thocky.",
            recommendedVolume: 0.42,
            pitchVariationDefault: 0.008
        ),
        bundledRecordingPack(
            id: "com.thockstudio.pack.clacky2.recording",
            name: "Clacky-2",
            resourcePath: "SoundPacks/Clacky2",
            category: "clicky",
            tone: "bright",
            loudness: "loud",
            bestFor: "Crisp Typing",
            description: "Clacky keypress samples extracted from clacky.mov.",
            recommendedVolume: 0.42,
            pitchVariationDefault: 0.008,
            sampleCount: 15
        ),
        bundledRecordingPack(
            id: "com.thockstudio.pack.clicky1.recording",
            name: "Clicky-1",
            resourcePath: "SoundPacks/Clicky1",
            category: "clicky",
            tone: "sharp",
            loudness: "loud",
            bestFor: "Clicky Typing",
            description: "Clicky keypress samples extracted from clicky.mov.",
            recommendedVolume: 0.40,
            pitchVariationDefault: 0.008
        ),
        bundledRecordingPack(
            id: "com.thockstudio.pack.thocky1.recording",
            name: "Thocky-1",
            resourcePath: "SoundPacks/Thocky1",
            category: "linear",
            tone: "deep",
            loudness: "medium",
            bestFor: "Deep Typing",
            description: "Thocky keypress samples extracted from the final section of Creamy VS Clacky VS Thocky.",
            recommendedVolume: 0.52,
            pitchVariationDefault: 0.012
        ),
        bundledRecordingPack(
            id: "com.thockstudio.pack.thocky2.recording",
            name: "Thocky-2",
            resourcePath: "SoundPacks/Thocky2",
            category: "linear",
            tone: "deep",
            loudness: "medium",
            bestFor: "Deep Typing",
            description: "Thocky keypress samples extracted from thocky.mov.",
            recommendedVolume: 0.52,
            pitchVariationDefault: 0.012,
            sampleCount: 15
        ),
        bundledRecordingPack(
            id: "com.thockstudio.pack.bubble1.recording",
            name: "Bubble-1",
            resourcePath: "SoundPacks/Bubble1",
            category: "asmr",
            tone: "bright",
            loudness: "medium",
            bestFor: "Playful Typing",
            description: "Bubble keyboard samples extracted from bubble_keyboard.mov.",
            recommendedVolume: 0.44,
            pitchVariationDefault: 0.010,
            sampleCount: 11
        ),
        bundledRecordingPack(
            id: "com.thockstudio.pack.normal1.recording",
            name: "Normal-1",
            resourcePath: "SoundPacks/Normal1",
            category: "office",
            tone: "balanced",
            loudness: "medium",
            bestFor: "Everyday Typing",
            description: "Normal keyboard samples extracted from normal_keyboard.mov.",
            recommendedVolume: 0.43,
            pitchVariationDefault: 0.008,
            sampleCount: 8
        ),
        bundledRecordingPack(
            id: "com.thockstudio.pack.plastic1.recording",
            name: "Plastic-1",
            resourcePath: "SoundPacks/Plastic1",
            category: "clicky",
            tone: "bright",
            loudness: "medium",
            bestFor: "Light Typing",
            description: "Plastic keypress samples extracted from Plastic.mov.",
            recommendedVolume: 0.42,
            pitchVariationDefault: 0.008,
            sampleCount: 12
        ),
        bundledRecordingPack(
            id: "com.thockstudio.pack.marbly1.recording",
            name: "Marbly-1",
            resourcePath: "SoundPacks/Marbly1",
            category: "tactile",
            tone: "rounded",
            loudness: "medium",
            bestFor: "Smooth Typing",
            description: "Marbly keypress samples extracted from marbly.mov.",
            recommendedVolume: 0.45,
            pitchVariationDefault: 0.010,
            sampleCount: 18
        ),
        bundledRecordingPack(
            id: "com.thockstudio.pack.poppy1.recording",
            name: "Poppy-1",
            resourcePath: "SoundPacks/Poppy1",
            category: "tactile",
            tone: "bright",
            loudness: "medium",
            bestFor: "Snappy Typing",
            description: "Poppy keypress samples extracted from poppy.mov.",
            recommendedVolume: 0.42,
            pitchVariationDefault: 0.009,
            sampleCount: 11
        )
    ]

    private static func samplePaths(count: Int) -> [String] {
        (1...count).map {
            "samples/alpha/press_" + String(format: "%02d", $0) + ".wav"
        }
    }

    private static var bundledCreamyKeyboard: SoundPack {
        bundledRecordingPack(
            id: "com.thockstudio.pack.creamykeyboard.recording",
            name: "Creamy-1",
            resourcePath: "SoundPacks/CreamyKeyboard",
            category: "linear",
            tone: "balanced",
            loudness: "medium",
            bestFor: "Recorded Feel",
            description: "Extracted from creamy_keyboard.mp3 using detected key press transients.",
            recommendedVolume: 0.48,
            pitchVariationDefault: 0.012
        )
    }

    private static func bundledRecordingPack(
        id: String,
        name: String,
        resourcePath: String,
        category: String,
        tone: String,
        loudness: String,
        bestFor: String,
        description: String,
        recommendedVolume: Float,
        pitchVariationDefault: Float,
        sampleCount: Int = 16
    ) -> SoundPack {
        let manifest = SoundPackManifest(
            schemaVersion: 1,
            packId: id,
            name: name,
            version: "1.0.0",
            author: "User Recording",
            category: category,
            tone: tone,
            loudness: loudness,
            description: description,
            isPremium: false,
            supportsPress: true,
            supportsRelease: false,
            recommendedVolume: recommendedVolume,
            pitchVariationDefault: pitchVariationDefault,
            sampleVariationDefault: true,
            artwork: nil,
            preview: nil,
            samples: [
                KeyCategory.alpha.rawValue: PackSampleManifest(
                    press: samplePaths(count: sampleCount),
                    release: nil
                )
            ]
        )

        return SoundPack(
            id: manifest.packId,
            name: manifest.name,
            category: manifest.category.capitalized,
            loudness: manifest.loudness.capitalized,
            tone: manifest.tone.capitalized,
            bestFor: bestFor,
            description: manifest.description,
            isPremium: false,
            recommendedVolume: manifest.recommendedVolume ?? recommendedVolume,
            pitchVariationDefault: manifest.pitchVariationDefault ?? pitchVariationDefault,
            sampleVariationDefault: manifest.sampleVariationDefault ?? true,
            supportsPress: manifest.supportsPress ?? true,
            supportsRelease: manifest.supportsRelease ?? false,
            source: .bundled(
                resourcePath: resourcePath,
                manifest: manifest
            )
        )
    }

}
