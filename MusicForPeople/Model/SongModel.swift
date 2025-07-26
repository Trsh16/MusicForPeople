//
//  Untitled.swift
//  MusicForPeople
//
//  Created by Trisha Alexis Likorawung on 26/07/25.
//
import Foundation
import SwiftUI

// Song model for UI
struct Song: Identifiable {
    let id = UUID()
    let name: String
    let artist: String
    let album: String
    let image: Image
    var audio_url: String = "song.mp4"
}

// Codable model for JSON parsing
struct TrackListResponse: Codable {
    let track: [Track]
}

struct Track: Codable {
    let idTrack: String
    let strTrack: String
    let strAlbum: String
    let strArtist: String
    let intDuration: String
    let intTrackNumber: String
    let strGenre: String
}

// JSON string
let jsonDataString = """
{
  "track": [
    {
      "idTrack": "32793500",
      "idAlbum": "2115888",
      "idArtist": "112024",
      "idLyric": "0",
      "idIMVDB": null,
      "strTrack": "D.D.",
      "strAlbum": "Echoes of Silence",
      "strArtist": "The Weeknd",
      "strArtistAlternate": null,
      "intCD": null,
      "intDuration": "274000",
      "strGenre": "R&B",
      "intTrackNumber": "1"
    }
  ]
}
"""

// Convert JSON -> [Song]
func parseJSONString() -> [Song] {
    guard let data = jsonDataString.data(using: .utf8) else { return [] }
    
    do {
        let decoded = try JSONDecoder().decode(TrackListResponse.self, from: data)
        return decoded.track.map {
            Song(
                name: $0.strTrack,
                artist: $0.strArtist,
                album: $0.strAlbum,
                image: Image(systemName: "music.note")
            )
        }
    } catch {
        print("Decoding error: \(error)")
        return []
    }
}
