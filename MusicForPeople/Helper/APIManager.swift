//
//  APIManager.swift
//  MusicForPeople
//
//  Created by Trisha Alexis Likorawung on 26/07/25.
//

import SwiftUI

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    private let baseURL = "https://saavnapi-nine.vercel.app/playlist/?query=https://www.jiosaavn.com/featured/romantic-hits-2020---hindi/ABiMGqjovSFuOxiEGmm6lQ"

    func fetchTracks(completion: @escaping (Result<[Song], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(SongListResponse.self, from: data)
                    let songs = decoded.songs.map { song in
                        Song(
                            name: song.song,
                            artist: song.singers,
                            album: song.album,
                            image: song.image,
                            url: song.vlink
                        )
                    }
                    completion(.success(songs))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}
