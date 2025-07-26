//
//  HomeView.swift
//  MusicForPeople
//
//  Created by Trisha Alexis Likorawung on 26/07/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var searchText = ""
    @State private var allSongs: [Song] = []

    var filteredSongs: [Song] {
        searchText.isEmpty ? allSongs : allSongs.filter {
            $0.artist.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search artist", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding([.horizontal, .top])

            List(filteredSongs) { song in
                let isCurrent = allSongs.firstIndex(where: { $0.id == song.id }) == audioManager.currentIndex
                HStack {
                    song.image
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(4)
                        .padding(.top)

                    VStack(alignment: .leading) {
                        Text(song.name).font(.headline)
                        Text(song.artist).font(.subheadline)
                        Text(song.album).font(.caption).foregroundColor(.gray)
                    }

                    Spacer()

                    if isCurrent && audioManager.isPlaying {
                        Image(systemName: "waveform")
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                }
                .onTapGesture {
                    if let index = allSongs.firstIndex(where: { $0.id == song.id }) {
                        audioManager.playSong(at: index)
                    }
                }
            }
            .listStyle(PlainListStyle())

            VStack {
                HStack {
                    Button(action: { audioManager.previous() }) {
                        Image(systemName: "backward.fill").font(.title2)
                    }
                    .padding(.trailing, 50)

                    Button(action: { audioManager.playPause() }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                    }

                    Button(action: { audioManager.next() }) {
                        Image(systemName: "forward.fill").font(.title2)
                    }
                    .padding(.leading, 50)
                }

                Slider(value: $audioManager.progress, in: 0...1, onEditingChanged: { editing in
                    if !editing {
                        audioManager.seek(to: audioManager.progress)
                    }
                })
                .padding(.horizontal)
            }
            .padding()
            .background(Color(.systemGray6))
            .shadow(radius: 5)
        }
        .onAppear {
            let loadedSongs = parseJSONString()
            allSongs = loadedSongs
            audioManager.loadSongs(loadedSongs)
        }
    }
}


#Preview {
    HomeView()
}
