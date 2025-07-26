//
//  loadSongs.swift
//  MusicForPeople
//
//  Created by Trisha Alexis Likorawung on 26/07/25.
//
import AVFoundation
import Combine

class AudioPlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0.0
    @Published var currentIndex = 0

    private var player: AVAudioPlayer?
    private var timer: Timer?

    var songs: [Song] = []

    func loadSongs(_ newSongs: [Song]) {
        songs = newSongs
        currentIndex = 0
        playSong(at: currentIndex)
    }

    func playSong(at index: Int) {
        guard songs.indices.contains(index),
              let url = Bundle.main.url(forResource: songs[index].audio_url, withExtension: nil) else {
            print("Song file not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            startProgressTimer()
        } catch {
            print("Error loading audio: \(error)")
        }
    }

    func playPause() {
        guard let player = player else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func next() {
        currentIndex = (currentIndex + 1) % songs.count
        playSong(at: currentIndex)
    }

    func previous() {
        currentIndex = (currentIndex - 1 + songs.count) % songs.count
        playSong(at: currentIndex)
    }

    func seek(to value: Double) {
        player?.currentTime = value * (player?.duration ?? 1)
        progress = value
    }

    private func startProgressTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard let player = self.player else { return }
            self.progress = player.duration == 0 ? 0 : player.currentTime / player.duration
        }
    }

    deinit {
        timer?.invalidate()
    }
}
