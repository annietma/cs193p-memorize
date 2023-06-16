//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Annie Ma on 4/19/23.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    @Published private var model: MemoryGame<String>
    private(set) var currentTheme: Theme
    
    @Published var themes = [
        Theme(name: "Food", emojis: ["🍔", "🍕", "🍟", "🍣"], numberOfPairsOfCards: 4, color: RGBA(color: Color.orange)),
        Theme(name: "Animals", emojis: ["🐶", "🐱", "🐭", "🦊", "🦁"], numberOfPairsOfCards: 5, color: RGBA(color: Color.green)),
        Theme(name: "Travel", emojis: ["✈️", "🚆", "🚗", "🚢", "🚠", "🚀"], numberOfPairsOfCards: 6, color: RGBA(color: Color.gray)),
        Theme(name: "Sports", emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉"], numberOfPairsOfCards: 7, color: RGBA(color: Color.red)),
        Theme(name: "Weather", emojis: ["☀️", "⛅️", "🌧", "⛈", "❄️", "🌪", "🌤", "🌦"], numberOfPairsOfCards: 8, color: RGBA(color: Color.blue)),
        Theme(name: "Faces", emojis: ["😀", "😂", "🥲", "😎", "🥺", "😡", "🤩", "😍", "😇"], numberOfPairsOfCards: 9, color: RGBA(color: Color.yellow)),
    ]
    
    private let themesKey = "EmojiMemoryGame.themes"
    
    init(theme: Theme) {
        if let themesData = UserDefaults.standard.data(forKey: themesKey),
           let decodedThemes = try? JSONDecoder().decode([Theme].self, from: themesData) {
            self.themes = decodedThemes
        }
        self.currentTheme = theme
        model = MemoryGame<String>(numberOfPairsOfCards: theme.numberOfPairsOfCards) { pairIndex in
            if theme.emojis.indices.contains(pairIndex) {
                return theme.emojis[pairIndex]
            } else {
                return "error"
            }
        }
    }
    
    func saveThemes() {
        if let themesData = try? JSONEncoder().encode(themes) {
            UserDefaults.standard.set(themesData, forKey: themesKey)
        }
    }
    
    struct Theme: Codable, Equatable, Hashable {
        var name: String
        var emojis: [String] {
            didSet {
                self.numberOfPairsOfCards = min(self.numberOfPairsOfCards, self.emojis.count)
            }
        }
        var numberOfPairsOfCards: Int
        var color: RGBA
        var uiColor: Color {
            Color(rgba: color)
        }
    }
    
    
    func newGame() {
        model = MemoryGame<String>(numberOfPairsOfCards: currentTheme.numberOfPairsOfCards) { pairIndex in
            if currentTheme.emojis.indices.contains(pairIndex) {
                return currentTheme.emojis[pairIndex]
            } else {
                return "error"
            }
        }
    }
    
    var cards: Array<MemoryGame<String>.Card> {
        return model.cards
    }
    
    var score: Int {
        return model.score
    }
    
    func shuffle() {
        model.shuffle()
        objectWillChange.send()
    }
    
    func choose(_ card: MemoryGame<String>.Card) {
        model.choose(card: card)
    }
}
