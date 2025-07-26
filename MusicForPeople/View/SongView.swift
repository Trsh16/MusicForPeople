//
//  HomeView.swift
//  MusicForPeople
//
//  Created by Trisha Alexis Likorawung on 26/07/25.
//

import SwiftUI

struct SongView: View {
    @StateObject private var viewModel = SongViewModel()
    @State private var searchText = ""

    var filteredSongs: [Song] {
        if searchText.isEmpty { return viewModel.songs }
        return viewModel.songs.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.artist.localizedCaseInsensitiveContains(searchText) ||
            $0.album.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TextField("Search artist", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding([.horizontal, .top])

                if filteredSongs.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "music.note")
                            .font(.system(size: 85))
                            .foregroundColor(.gray)
                        Text("No Songs Found")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List(filteredSongs) { song in
                        let currentIndex = viewModel.currentIndex
                        let tappedIndex = viewModel.songs.firstIndex(where: { $0.id == song.id })
                        let isCurrent = tappedIndex == currentIndex

                        HStack {
                            if let imageUrl = URL(string: song.image) {
                                AsyncImage(url: imageUrl) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView() // Show a loading indicator while fetching the image
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(4)
                                            .padding(.top)
                                    case .failure:
                                        Image(systemName: "exclamationmark.triangle.fill") // Fallback image on failure
                                            .foregroundColor(.red)
                                            .frame(width: 60, height: 60)
                                            .padding(.top)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                // Handle case where the URL is invalid
                                Text("Invalid image URL")
                                    .foregroundColor(.red)
                            }

                            VStack(alignment: .leading) {
                                Text(song.name).font(.headline)
                                Text(song.artist).font(.subheadline)
                                Text(song.album).font(.caption).foregroundColor(.gray)
                            }

                            Spacer()

                            if isCurrent && viewModel.isPlaying {
                                Image(systemName: "waveform")
                                    .foregroundColor(.blue)
                                    .font(.title)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let index = tappedIndex {
                                viewModel.playSong(at: index)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }

            if viewModel.isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
            
        }
        if let _ = viewModel.currentIndex {
            VStack {
                HStack {
                    Button(action: viewModel.previous) {
                        Image(systemName: "backward.fill").font(.title2)
                    }
                    .padding(.trailing, 50)

                    Button(action: viewModel.playPause) {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                    }

                    Button(action: viewModel.next) {
                        Image(systemName: "forward.fill").font(.title2)
                    }
                    .padding(.leading, 50)
                }

                Slider(value: $viewModel.progress, in: 0...1, onEditingChanged: { editing in
                    if !editing {
                        viewModel.seek(to: viewModel.progress)
                    }
                })
                .padding(.horizontal)
            }
            .padding()
            .background(Color(.systemGray6))
            .shadow(radius: 5)
        }
    }
}

#Preview {
    SongView()
}
