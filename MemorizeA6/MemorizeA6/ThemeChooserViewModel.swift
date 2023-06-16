//
//  ThemeChooserViewModel.swift
//  MemorizeA6
//
//  Created by Annie Ma on 5/22/23.
//

import Foundation
import SwiftUI

class ThemeChooserViewModel: ObservableObject {
    @Published var themes = [
        EmojiMemoryGame.Theme(name: "Food", emojis: ["🍔", "🍕", "🍟", "🍣"], numberOfPairsOfCards: 4, color: RGBA(color: Color.orange)),
        EmojiMemoryGame.Theme(name: "Animals", emojis: ["🐶", "🐱", "🐭", "🦊", "🦁"], numberOfPairsOfCards: 5, color: RGBA(color: Color.green)),
        EmojiMemoryGame.Theme(name: "Travel", emojis: ["✈️", "🚆", "🚗", "🚢", "🚠", "🚀"], numberOfPairsOfCards: 6, color: RGBA(color: Color.gray)),
        EmojiMemoryGame.Theme(name: "Sports", emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉"], numberOfPairsOfCards: 7, color: RGBA(color: Color.red)),
        EmojiMemoryGame.Theme(name: "Weather", emojis: ["☀️", "⛅️", "🌧", "⛈", "❄️", "🌪", "🌤", "🌦"], numberOfPairsOfCards: 8, color: RGBA(color: Color.blue)),
        EmojiMemoryGame.Theme(name: "Faces", emojis: ["😀", "😂", "🥲", "😎", "🥺", "😡", "🤩", "😍", "😇"], numberOfPairsOfCards: 9, color: RGBA(color: Color.yellow)),
    ] {
        didSet {
            saveThemes()
        }
    }
    
    private let themesKey = "EmojiMemoryGame.themes"
    
    init() {
        if let themesData = UserDefaults.standard.data(forKey: themesKey),
           let decodedThemes = try? JSONDecoder().decode([EmojiMemoryGame.Theme].self, from: themesData) {
            self.themes = decodedThemes
        }
        
    }
    
    func addTheme(_ theme: EmojiMemoryGame.Theme) {
        themes.append(theme)
    }
    
    func deleteTheme(at offsets: IndexSet) {
        themes.remove(atOffsets: offsets)
    }
    
    private func saveThemes() {
        if let themesData = try? JSONEncoder().encode(themes) {
            UserDefaults.standard.set(themesData, forKey: themesKey)
        }
    }
}
