//
//  MemorizeGame.swift
//  Memorize
//
//  Created by Annie Ma on 4/19/23.
//

import Foundation

struct MemoryGame<CardContent: Equatable> {
    private(set) var cards: Array<Card>
    private(set) var score: Int
    private var seenCardsIndexes: Array<Int>
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = []
        for pairIndex in 0..<max(2, numberOfPairsOfCards) {
            let content: CardContent = cardContentFactory(pairIndex)
            cards.append(Card(id: pairIndex * 2, content: content))
            cards.append(Card(id: pairIndex * 2 + 1, content: content))
        }
        cards.shuffle()
        score = 0
        seenCardsIndexes = []
    }
    
    mutating func choose(card: Card) {
        var faceUpCardIndices = cards.indices.filter { cards[$0].isFaceUp }
        //if two cards are already face up, turn them face down and add them to seenCardsIndexes
        if faceUpCardIndices.count == 2 {
                faceUpCardIndices.forEach { index in
                    cards[index].isFaceUp = false
                    if !seenCardsIndexes.contains(index) {
                        seenCardsIndexes.append(index)
                    }
                }
        }
        //handle turning of the card that is being chosen
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isFaceUp = true
        }
        //get the most recent face up cards and handle scoring
        faceUpCardIndices = cards.indices.filter { cards[$0].isFaceUp }
        if faceUpCardIndices.count == 2 {
            if cards[faceUpCardIndices[0]].content == cards[faceUpCardIndices[1]].content {
                score += 2
                cards[faceUpCardIndices[0]].isMatched = true
                cards[faceUpCardIndices[1]].isMatched = true
            }
            else {
                faceUpCardIndices.forEach { index in
                    if seenCardsIndexes.contains(index) {
                        score -= 1
                    }
                }
            }
        }
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    struct Card {
        var id: Int
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        let content: CardContent
    }
}
