//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Annie Ma on 4/19/23.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    private static let themes = [
        EmojiMemoryGame.Theme(name: "Food", emojis: ["🍔", "🍕", "🍟", "🍣"], numberOfPairsOfCards: 4, color: Color.orange),
        EmojiMemoryGame.Theme(name: "Animals", emojis: ["🐶", "🐱", "🐭", "🦊", "🦁"], numberOfPairsOfCards: 5, color: Color.green),
        EmojiMemoryGame.Theme(name: "Travel", emojis: ["✈️", "🚆", "🚗", "🚢", "🚠", "🚀"], numberOfPairsOfCards: 6, color: Color.gray),
        EmojiMemoryGame.Theme(name: "Sports", emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉"], numberOfPairsOfCards: 7, color: Color.red),
        EmojiMemoryGame.Theme(name: "Weather", emojis: ["☀️", "⛅️", "🌧", "⛈", "❄️", "🌪", "🌤", "🌦"], numberOfPairsOfCards: 8, color: Color.blue),
        EmojiMemoryGame.Theme(name: "Faces", emojis: ["😀", "😂", "🥲", "😎", "🥺", "😡", "🤩", "😍", "😇"], numberOfPairsOfCards: 9, color: Color.yellow),
        ]

    
    private static func createMemoryGame() -> (MemoryGame<String>, Theme) {
        let theme = EmojiMemoryGame.themes.randomElement()!
        let memoryGame = MemoryGame<String>(numberOfPairsOfCards: theme.numberOfPairsOfCards) { pairIndex in
            if theme.emojis.indices.contains(pairIndex) {
                return theme.emojis[pairIndex]
            } else {
                return "error"
            }
        }
        return (memoryGame, theme)
    }
    
    @Published private var model: MemoryGame<String>
    private(set) var currentTheme: Theme
    
    init() {
        let memoryGameAndTheme = EmojiMemoryGame.createMemoryGame()
        model = memoryGameAndTheme.0
        currentTheme = memoryGameAndTheme.1
    }
    
    func newGame() {
        let memoryGameAndTheme = EmojiMemoryGame.createMemoryGame()
        model = memoryGameAndTheme.0
        currentTheme = memoryGameAndTheme.1
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
    
    struct Theme {
        let name: String
        let emojis: [String]
        let numberOfPairsOfCards: Int
        let color: Color
    }
}
