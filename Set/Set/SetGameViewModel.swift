//
//  ViewModel.swift
//  Set
//
//  Created by Annie Ma on 4/24/23.
//

import SwiftUI

class SetGameViewModel: ObservableObject {
    typealias Card = SetGameModel<SetCardContent>.Card
    
    private static func createSetGame() -> SetGameModel<SetCardContent> {
        SetGameModel(numberOfCards: 81) { index in
            let shape = ShapeType.allCases[index % 3]
            let color = CardColor.allCases[(index / 3) % 3]
            let shading = Shading.allCases[(index / 9) % 3]
            let number = index / 27 + 1
            return SetCardContent(shape: shape, color: color, shading: shading, number: number)
        }
    }
    
    @Published private var model: SetGameModel<SetCardContent> = createSetGame()
    
    var deck: [Card] {
        return model.deck
    }
    
    var cards: [Card] {
        return model.cards
    }
    
    var numberOfColumns: Int {
        if cards.count >= 12 && cards.count <= 16 {
                return 4
            } else if cards.count > 16 {
                return 5
            } else {
                return 3
            }
    }
    
    var selectedCards: [Int] {
        return model.selectedCards
    }
    
    var deckIsEmpty: Bool {
        return model.deckIsEmpty
    }
    
    func choose(card: Card) {
        model.choose(card: card)
    }
    
    func dealThreeMoreCards() {
        model.dealThreeMoreCards()
    }
    
    func newGame() {
        model = SetGameViewModel.createSetGame()
    }

    var discardedCards: [Card] {
        return model.discardedCards
    }
    
    var deckCount: Int {
        return model.deck.count
    }
    
    func shuffle() {
        model.shuffle()
    }
    
}

enum ShapeType: CaseIterable {
    case circle
    case rectangle
    case diamond
}

enum CardColor: CaseIterable {
    case red
    case green
    case blue
}

enum Shading: CaseIterable {
    case opaque
    case translucent
    case transparent
}

struct SetCardContent: Equatable {
    let shape: ShapeType
    let color: CardColor
    let shading: Shading
    let number: Int
}

