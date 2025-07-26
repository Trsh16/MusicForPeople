//
//  Untitled.swift
//  MusicForPeople
//
//  Created by Trisha Alexis Likorawung on 26/07/25.
//
import SwiftUI

struct Song: Identifiable {
    let id = UUID()
    let name: String
    let artist: String
    let album: String
    let image: String
    let url: String
}

struct SongListResponse: Codable {
    let songs: [Album]
}

struct Album: Codable {
    let albumid: String
    let song: String
    let album: String
    let singers: String
    let image: String
    let vlink: String
}
