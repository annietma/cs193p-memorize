//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by Annie Ma on 4/11/23.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var viewModel: EmojiMemoryGame
    
    @State private var emojis: [String] = []
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.currentTheme.name)
                    .font(.largeTitle)
                    .padding(.leading)
                Spacer()
                Text("Score: \(String(viewModel.score))")
                    .font(.largeTitle)
                    .padding(.trailing)
            }
            ScrollView {
                cards
            }
            Button("New Game") {
                viewModel.newGame()
            }
            
        }
        .padding()
    }
    
    var cards: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))]) {
            ForEach(viewModel.cards.indices, id: \.self) { index in
                CardView(viewModel.cards[index], onCardTapped: viewModel.choose)
                    .aspectRatio(2/3, contentMode: .fit)
                    .padding(2)
            }
        }
        .foregroundColor(Color(rgba: viewModel.currentTheme.color))
        
    }
}

struct CardView: View {
    let card: MemoryGame<String>.Card
    let onCardTapped: (MemoryGame<String>.Card) -> Void
    
    init(_ card: MemoryGame<String>.Card, onCardTapped: @escaping (MemoryGame<String>.Card) -> Void) {
        self.card = card
        self.onCardTapped = onCardTapped
    }
    
    var body: some View {
        ZStack {
            let base = RoundedRectangle(cornerRadius: 12)
            Group {
                base.fill(.white)
                base.strokeBorder(lineWidth: 2)
                Text(card.content)
                    .font(.system(size: 200))
                    .minimumScaleFactor(0.01)
                    .aspectRatio(1, contentMode: .fit)
            }
            .opacity(card.isFaceUp && !card.isMatched ? 1 : 0)
            .animation(.easeInOut(duration: 0.1))
            base.fill()
                .opacity((card.isFaceUp && !card.isMatched) || card.isMatched ? 0 : 1)
                .animation(.easeInOut(duration: 0.1))
        }
        .onTapGesture {
            onCardTapped(card)
        }
    }
}

struct EmojiMemoryGameView_Previews: PreviewProvider {
    static let dummyTheme = EmojiMemoryGame.Theme(name: "Food", emojis: ["🍔", "🍕", "🍟", "🍣"], numberOfPairsOfCards: 4, color: RGBA(color: Color.orange))
    static var previews: some View {
        EmojiMemoryGameView(viewModel: EmojiMemoryGame(theme: dummyTheme))
    }
}
