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

class AudioPlayerManager: ObservableObject {
    @Published var songs: [Song] = []
    @Published var currentIndex: Int? = nil
    @Published var isPlaying = false
    @Published var progress: Double = 0.0
    
    private var player: AVAudioPlayer?
    private var timer: Timer?

    init() {
        loadSongsFromJSON()
    }
    
    func loadSongs(_ songs: [Song]) {
        self.songs = songs
    }

    func loadSongsFromJSON() {
        guard let data = jsonDataString.data(using: .utf8) else { return }

        do {
            let decoded = try JSONDecoder().decode(TrackListResponse.self, from: data)
            let songList = decoded.track.map {
                Song(
                    name: $0.strTrack,
                    artist: $0.strArtist,
                    album: $0.strAlbum,
                    image: Image("The_Weeknd_-_After_Hours") // assume this asset exists in Assets.xcassets
                )
            }
            self.songs = songList
        } catch {
            print("Decoding error: \(error)")
        }
    }

    func playSong(at index: Int) {
        guard songs.indices.contains(index) else { return }

        let fileName = "dancing-in-the-rain-214815"
        let fileExt = "mp3"

        let aSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: fileName, ofType: "mp3")!)

        do {
            player = try AVAudioPlayer(contentsOf:aSound as URL)
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            currentIndex = index
            startProgressTimer()
        } catch {
            print("Error loading audio file: \(error)")
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
        guard let index = currentIndex else { return }
        let nextIndex = (index + 1) % songs.count
        playSong(at: nextIndex)
    }

    func previous() {
        guard let index = currentIndex else { return }
        let prevIndex = (index - 1 + songs.count) % songs.count
        playSong(at: prevIndex)
    }

    func startProgressTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let player = self.player {
                self.progress = player.duration == 0 ? 0 : player.currentTime / player.duration
            }
        }
    }

    func seek(to value: Double) {
        guard let player = player else { return }
        player.currentTime = player.duration * value
    }
}
