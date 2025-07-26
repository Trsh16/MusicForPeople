//
//  loadSongs.swift
//  MusicForPeople
//
//  Created by Trisha Alexis Likorawung on 26/07/25.
//
import Foundation
import AVFoundation
import Combine
import SwiftUI


class SongViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var currentIndex: Int? = nil
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var progress: Double = 0.0

    private var player: AVAudioPlayer?
    private var timer: Timer?

    init() {
        loadSongsFromAPI()
    }

    func loadSongsFromAPI() {
        if songs.isEmpty{
            isLoading = true
        }
        APIManager.shared.fetchTracks { result in
            switch result {
            case .success(let songs):
                DispatchQueue.main.async {
                    self.songs = songs
                    self.isLoading = false
                }
            case .failure(let error):
                print("❌ Error fetching songs: \(error)")
            }
        }
    }

    func playSong(at index: Int) {
        guard songs.indices.contains(index) else { return }

        let song = songs[index]

        // Assuming `song.url` contains the full URL to the audio file
        guard let url = URL(string: song.url) else {
            print("❌ Invalid song URL: \(song.url)")
            return
        }

        // AVAudioPlayer only supports local files, so we download it first
        isLoading = true
        let task = URLSession.shared.downloadTask(with: url) { [weak self] localURL, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let error = error {
                print("❌ Failed to download audio: \(error)")
                return
            }

            guard let localURL = localURL else {
                print("❌ Audio file could not be downloaded.")
                return
            }

            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: localURL)
                DispatchQueue.main.async {
                    self?.player = audioPlayer
                    self?.player?.prepareToPlay()
                    self?.player?.play()
                    self?.isPlaying = true
                    self?.currentIndex = index
                    self?.startProgressTimer()
                }
            } catch {
                print("❌ AVAudioPlayer failed to play: \(error)")
            }
        }

        task.resume()
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
        guard let index = currentIndex else { return }
        let nextIndex = (index + 1) % songs.count
        playSong(at: nextIndex)
    }

    func previous() {
        guard let index = currentIndex else { return }
        let prevIndex = (index - 1 + songs.count) % songs.count
        playSong(at: prevIndex)
    }

    func seek(to value: Double) {
        guard let player = player else { return }
        player.currentTime = player.duration * value
    }

    private func startProgressTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard let player = self.player else { return }
            self.progress = player.duration == 0 ? 0 : player.currentTime / player.duration
        }
    }
}
