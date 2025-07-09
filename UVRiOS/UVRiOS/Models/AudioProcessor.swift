import Foundation
import AVFoundation
import CoreML

@MainActor
final class AudioProcessor: ObservableObject {
    enum OutputType { case vocals, noVocals }

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayerNode?
    private var engine: AVAudioEngine?

    private lazy var model: MLModel? = {
        guard let url = Bundle.main.url(forResource: "UVR_MDXNet", withExtension: "mlpackage") else { return nil }
        return try? MLModel(contentsOf: url)
    }()

    func startRecording() async {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("input.wav")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 16
        ]
        recorder = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
    }

    func stopRecording(progress: @escaping (Double) -> Void) async {
        recorder?.stop()
        if let url = recorder?.url {
            await process(url: url, progress: progress)
        }
    }

    func process(url: URL, progress: @escaping (Double) -> Void) async {
        guard let model else { return }
        progress(0.1)
        // Load audio as MLMultiArray or other required format
        // This is a simplified placeholder for actual preprocessing
        let audioFile = try? AVAudioFile(forReading: url)
        progress(0.3)

        // Run model - placeholder logic
        let input = MLDictionaryFeatureProvider(dictionary: [:])
        _ = try? model.prediction(from: input)
        progress(0.7)

        // Write outputs - placeholder logic for two WAV files
        let outputDir = FileManager.default.temporaryDirectory
        let vocalsURL = outputDir.appendingPathComponent("vocals.wav")
        let noVocalsURL = outputDir.appendingPathComponent("no_vocals.wav")
        try? Data().write(to: vocalsURL)
        try? Data().write(to: noVocalsURL)
        progress(1.0)
    }

    func play(type: OutputType) {
        let outputDir = FileManager.default.temporaryDirectory
        let url = outputDir.appendingPathComponent(type == .vocals ? "vocals.wav" : "no_vocals.wav")
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        guard let engine, let player, let file = try? AVAudioFile(forReading: url) else { return }
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: file.processingFormat)
        try? engine.start()
        player.scheduleFile(file, at: nil)
        player.play()
    }
}
