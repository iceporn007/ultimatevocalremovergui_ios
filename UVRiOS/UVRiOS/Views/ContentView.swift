import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var audioProcessor: AudioProcessor
    @State private var showingImporter = false
    @State private var isRecording = false
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .padding()

            HStack {
                Button(action: {
                    Task { await startRecording() }
                }) {
                    Image(systemName: isRecording ? "stop.circle" : "mic.circle")
                        .font(.largeTitle)
                }
                .padding()

                Button(action: { showingImporter = true }) {
                    Image(systemName: "folder")
                        .font(.largeTitle)
                }
                .padding()
            }

            HStack {
                Button("Play Vocals") { audioProcessor.play(type: .vocals) }
                Button("Play No Vocals") { audioProcessor.play(type: .noVocals) }
            }
        }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.audio]) { result in
            if let url = try? result.get() {
                Task {
                    progress = 0
                    await audioProcessor.process(url: url, progress: { value in
                        progress = value
                    })
                }
            }
        }
    }

    private func startRecording() async {
        if isRecording {
            isRecording = false
            await audioProcessor.stopRecording(progress: { value in
                progress = value
            })
        } else {
            progress = 0
            isRecording = true
            await audioProcessor.startRecording()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AudioProcessor())
}
