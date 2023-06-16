//
//  Model.swift
//  Set
//
//  Created by Annie Ma on 4/24/23.
//

import Foundation

struct SetGameModel<CardContent> where CardContent: Equatable {
    private(set) var cards: [Card]=[]
    private(set) var deck: [Card] = []
    private(set) var selectedCards: [Int] = []
    private(set) var deckIsEmpty: Bool = false
    private(set) var discardedCards: [Card] = []
    
    init(numberOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        deck = Array<Card>()
        for cardIndex in 0..<numberOfCards {
            let content = cardContentFactory(cardIndex)
            deck.append(Card(content: content))
        }
        deck.shuffle()
        
        for _ in 0..<12 {
            if let lastCard = deck.last {
                cards.append(lastCard)
                deck.removeLast()
            }
        }
    }
    
    private var matchJustMade: Bool = false
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    mutating func choose(card: Card) {
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isMatched {
            
            if matchJustMade == true {
                selectedCards.forEach { index in
                    cards[index].isMatched = true
                    discardedCards.append(cards[index])
                }
                cards.removeAll { $0.isMatched }
                selectedCards = []
                matchJustMade = false
                return
            }
            if selectedCards.count == 3 {
                // Deselect all previously selected cards
                for index in selectedCards {
                    cards[index].isSelected = false
                    cards[index].isWronglyMatched = false
                }
                selectedCards = []
            }
            if selectedCards.count < 3{
                // If there are less than 3 cards selected, handle selection/deselection
                if !selectedCards.contains(chosenIndex) {
                    selectedCards.append(chosenIndex)
                    cards[chosenIndex].isSelected = true
                } else {
                    // Deselect the card if it's already selected
                    selectedCards.removeAll(where: { $0 == chosenIndex })
                    cards[chosenIndex].isSelected = false
                }
            }
            if selectedCards.count == 3 {
                let selectedCardsAreMatch = isMatchingSet(selectedCardIndices: selectedCards)
                if selectedCardsAreMatch {
                    matchJustMade = true
                    for index in selectedCards {
                        cards[index].isMatched = true
                    }
                } else {
                    for index in selectedCards {
                        cards[index].isWronglyMatched = true
                    }
                }
            }
        }
    }
    
    
    private func isMatchingSet(selectedCardIndices: [Int]) -> Bool {
        guard selectedCardIndices.count == 3,
              let card1 = cards[selectedCardIndices[0]].content as? SetCardContent,
              let card2 = cards[selectedCardIndices[1]].content as? SetCardContent,
              let card3 = cards[selectedCardIndices[2]].content as? SetCardContent else { return false }
        
        let allShapes = Set([card1.shape, card2.shape, card3.shape])
        let allColors = Set([card1.color, card2.color, card3.color])
        let allShadings = Set([card1.shading, card2.shading, card3.shading])
        let allNumbers = Set([card1.number, card2.number, card3.number])
        
        return allShapes.count != 2 && allColors.count != 2 && allShadings.count != 2 && allNumbers.count != 2
    }
    
    
    mutating func dealThreeMoreCards() {
        if deck.count >= 3 {
            if matchJustMade {
                for index in selectedCards {
                    discardedCards.append(cards[index])
                    let randomIndex = Int.random(in: 0..<deck.count)
                    let newCard = deck.remove(at: randomIndex)
                    cards[index] = newCard
                }
                matchJustMade = false
                selectedCards = []
            } else {
                for _ in 0..<3 {
                    if let lastCard = deck.last {
                        cards.append(lastCard)
                        deck.removeLast()
                    }
                }
            }
        }
        deckIsEmpty = deck.isEmpty
    }
    
    struct Card: Identifiable {
        var id = UUID()
        var content: CardContent
        var isSelected: Bool = false
        var isMatched: Bool = false
        var isWronglyMatched: Bool = false
    }
}
