//
//  ContentView.swift
//  MusicForPeople
//
//  Created by Trisha Alexis Likorawung on 26/07/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            VStack{
                SongView()
            }
            .navigationBarTitle("Music For People")
        }
    }
}

#Preview {
    ContentView()
}
