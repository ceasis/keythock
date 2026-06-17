@preconcurrency import AVFoundation
import Foundation

@MainActor
final class AudioEngineService: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var activePackId: String?
    @Published var lastError: String?

    private let engine = AVAudioEngine()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 2)!
    private let voiceMixer = AVAudioMixerNode()
    private let toneEQ = AVAudioUnitEQ(numberOfBands: 2)
    private let roomReverb = AVAudioUnitReverb()
    private var voices: [AudioVoice] = []
    private var activeBuffers: [SampleBufferKey: [AVAudioPCMBuffer]] = [:]
    private var lastSampleIndex: [SampleBufferKey: Int] = [:]
    private var nextVoiceIndex = 0
    private let voiceCount = 32

    init() {
        configureEngine()
        NotificationCenter.default.addObserver(
            forName: .AVAudioEngineConfigurationChange,
            object: engine,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.restart()
            }
        }
    }

    func start() {
        do {
            if !engine.isRunning {
                try engine.start()
            }
            isRunning = engine.isRunning
            lastError = nil
            warmUp()
        } catch {
            isRunning = false
            lastError = error.localizedDescription
        }
    }

    func restart() {
        engine.stop()
        start()
    }

    func preload(pack: SoundPack, settings: SettingsSnapshot) {
        do {
            let buffers: [SampleBufferKey: [AVAudioPCMBuffer]]
            switch pack.source {
            case let .bundled(resourcePath, manifest):
                buffers = try loadImportedBuffers(baseURL: try bundledPackURL(resourcePath: resourcePath), manifest: manifest)
            case let .imported(baseURL, manifest):
                buffers = try loadImportedBuffers(baseURL: baseURL, manifest: manifest)
            }
            activeBuffers = buffers
            activePackId = pack.id
            lastSampleIndex.removeAll()
            lastError = nil
            applyMixer(settings: settings)
            start()
        } catch {
            lastError = "Could not load \(pack.name): \(error.localizedDescription)"
        }
    }

    func applyMixer(settings: SettingsSnapshot) {
        let bass = toneEQ.bands[0]
        bass.filterType = .lowShelf
        bass.frequency = 180
        bass.bandwidth = 0.8
        bass.gain = settings.bassBoost * 12
        bass.bypass = abs(settings.bassBoost) < 0.01

        let brightness = toneEQ.bands[1]
        brightness.filterType = .highShelf
        brightness.frequency = 4_200
        brightness.bandwidth = 0.8
        brightness.gain = settings.brightness * 10
        brightness.bypass = abs(settings.brightness) < 0.01

        roomReverb.wetDryMix = min(35, max(0, settings.roomAmount * 100))
    }

    @discardableResult
    func play(_ request: SoundPlaybackRequest) -> Bool {
        guard activePackId == request.packId else { return false }
        if !isRunning {
            start()
            guard isRunning else { return false }
        }

        let samplePhase = request.phase.samplePhase
        var key = SampleBufferKey(category: request.keyCategory, phase: samplePhase)
        var buffers = activeBuffers[key]

        if buffers?.isEmpty != false {
            key = SampleBufferKey(category: .alpha, phase: samplePhase)
            buffers = activeBuffers[key]
        }
        if buffers?.isEmpty != false, samplePhase == .release {
            key = SampleBufferKey(category: request.keyCategory, phase: .press)
            buffers = activeBuffers[key]
        }
        guard let buffers, !buffers.isEmpty else { return false }

        let sampleIndex: Int
        if let sampleIndexOverride = request.sampleIndexOverride {
            sampleIndex = min(max(sampleIndexOverride, 0), buffers.count - 1)
        } else if request.sampleVariation, buffers.count > 1 {
            var candidate = Int.random(in: 0..<buffers.count)
            if let last = lastSampleIndex[key], candidate == last {
                candidate = (candidate + 1) % buffers.count
            }
            sampleIndex = candidate
        } else {
            sampleIndex = 0
        }
        lastSampleIndex[key] = sampleIndex

        let voice = voices[nextVoiceIndex]
        nextVoiceIndex = (nextVoiceIndex + 1) % voices.count

        let pitchCents = request.pitchShiftSemitones * 100 + Float.random(in: -request.pitchVariation...request.pitchVariation) * 100
        voice.pitch.pitch = pitchCents
        voice.player.volume = min(1.5, max(0, request.volume))
        voice.player.stop()
        voice.player.scheduleBuffer(buffers[sampleIndex], at: nil, options: [])
        voice.player.play()
        return true
    }

    func previewTypingDemo(pack: SoundPack, settings: SettingsSnapshot) {
        let previousPackId = activePackId
        if previousPackId != pack.id {
            preload(pack: pack, settings: settings)
        }

        let previewTempoMultiplier = 1.5625
        let sequence: [(KeyCategory, Double)] = [
            (.alpha, 0), (.alpha, 0.055), (.alpha, 0.11), (.space, 0.18),
            (.alpha, 0.25), (.alpha, 0.31), (.backspace, 0.38), (.enter, 0.49)
        ]

        for item in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + item.1 * previewTempoMultiplier) { [weak self] in
                guard let self else { return }
                self.play(SoundPlaybackRequest(
                    packId: pack.id,
                    keyCategory: item.0,
                    phase: .down,
                    volume: settings.masterVolume,
                    pitchShiftSemitones: settings.pitchShiftSemitones ?? 0,
                    pitchVariation: settings.pitchVariation,
                    sampleVariation: settings.sampleVariation,
                    sampleIndexOverride: nil,
                    timestamp: Date().timeIntervalSince1970,
                    appProfileId: nil
                ))
            }
        }
    }

    private func configureEngine() {
        engine.attach(voiceMixer)
        engine.attach(toneEQ)
        engine.attach(roomReverb)
        roomReverb.loadFactoryPreset(.smallRoom)

        for _ in 0..<voiceCount {
            let player = AVAudioPlayerNode()
            let pitch = AVAudioUnitTimePitch()
            engine.attach(player)
            engine.attach(pitch)
            engine.connect(player, to: pitch, format: format)
            engine.connect(pitch, to: voiceMixer, format: format)
            voices.append(AudioVoice(player: player, pitch: pitch))
        }
        engine.connect(voiceMixer, to: toneEQ, format: format)
        engine.connect(toneEQ, to: roomReverb, format: format)
        engine.connect(roomReverb, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 1
        start()
    }

    private func warmUp() {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 64) else { return }
        buffer.frameLength = 64
        let voice = voices[0]
        voice.player.volume = 0
        voice.player.scheduleBuffer(buffer, at: nil, options: [])
        voice.player.play()
    }

    private func loadImportedBuffers(baseURL: URL, manifest: SoundPackManifest) throws -> [SampleBufferKey: [AVAudioPCMBuffer]] {
        var result: [SampleBufferKey: [AVAudioPCMBuffer]] = [:]
        for (rawCategory, sampleManifest) in manifest.samples {
            guard let category = KeyCategory(rawValue: rawCategory) else { continue }
            if let press = sampleManifest.press {
                result[SampleBufferKey(category: category, phase: .press)] = try press.map {
                    try loadAudioBuffer(url: baseURL.appendingPathComponent($0))
                }
            }
            if let release = sampleManifest.release {
                result[SampleBufferKey(category: category, phase: .release)] = try release.map {
                    try loadAudioBuffer(url: baseURL.appendingPathComponent($0))
                }
            }
        }
        return result
    }

    private func bundledPackURL(resourcePath: String) throws -> URL {
        if let resourceURL = Bundle.main.resourceURL?.appendingPathComponent(resourcePath, isDirectory: true),
           FileManager.default.fileExists(atPath: resourceURL.appendingPathComponent("manifest.json").path) {
            return resourceURL
        }

        if Bundle.main.bundleURL.pathExtension != "app" {
            let moduleCandidates = [
                Bundle.module.resourceURL?.appendingPathComponent("Resources", isDirectory: true).appendingPathComponent(resourcePath, isDirectory: true),
                Bundle.module.resourceURL?.appendingPathComponent(resourcePath, isDirectory: true)
            ].compactMap { $0 }

            if let url = moduleCandidates.first(where: { FileManager.default.fileExists(atPath: $0.appendingPathComponent("manifest.json").path) }) {
                return url
            }
        }

        let sourceURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("Sources/ThockStudio/Resources", isDirectory: true)
            .appendingPathComponent(resourcePath, isDirectory: true)
        if FileManager.default.fileExists(atPath: sourceURL.appendingPathComponent("manifest.json").path) {
            return sourceURL
        }
        throw AudioImportError.missingBundledPack(resourcePath)
    }

    private func loadAudioBuffer(url: URL) throws -> AVAudioPCMBuffer {
        let file = try AVAudioFile(forReading: url)
        guard let sourceBuffer = AVAudioPCMBuffer(
            pcmFormat: file.processingFormat,
            frameCapacity: AVAudioFrameCount(file.length)
        ) else {
            throw AudioImportError.couldNotCreateBuffer
        }
        try file.read(into: sourceBuffer)

        if sourceBuffer.format.sampleRate == format.sampleRate,
           sourceBuffer.format.channelCount == format.channelCount,
           sourceBuffer.format.commonFormat == format.commonFormat {
            return sourceBuffer
        }
        return try convert(buffer: sourceBuffer, to: format)
    }

    private func convert(buffer: AVAudioPCMBuffer, to outputFormat: AVAudioFormat) throws -> AVAudioPCMBuffer {
        guard let converter = AVAudioConverter(from: buffer.format, to: outputFormat) else {
            throw AudioImportError.couldNotConvert
        }
        let ratio = outputFormat.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio) + 256
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: capacity) else {
            throw AudioImportError.couldNotCreateBuffer
        }

        var didProvideInput = false
        var conversionError: NSError?
        converter.convert(to: outputBuffer, error: &conversionError) { _, status in
            if didProvideInput {
                status.pointee = .noDataNow
                return nil
            }
            didProvideInput = true
            status.pointee = .haveData
            return buffer
        }

        if let conversionError {
            throw conversionError
        }
        return outputBuffer
    }

    enum AudioImportError: LocalizedError {
        case couldNotCreateBuffer
        case couldNotConvert
        case missingBundledPack(String)

        var errorDescription: String? {
            switch self {
            case .couldNotCreateBuffer: return "Could not create an audio buffer."
            case .couldNotConvert: return "Could not convert the sample to the app playback format."
            case let .missingBundledPack(path): return "Bundled sound pack is missing: \(path)."
            }
        }
    }
}

private final class AudioVoice {
    let player: AVAudioPlayerNode
    let pitch: AVAudioUnitTimePitch

    init(player: AVAudioPlayerNode, pitch: AVAudioUnitTimePitch) {
        self.player = player
        self.pitch = pitch
    }
}
