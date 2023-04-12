//
//  ContentView.swift
//  Memorize
//
//  Created by Annie Ma on 4/11/23.
//

import SwiftUI

struct ContentView: View {
    
    let themes: [String: (symbol: String, emoji: [String])] = [
        "Animals": (symbol: "tortoise.fill", emoji: ["🐶", "🐶", "🐱", "🐱", "🐼", "🐼"]),
        "Food": (symbol: "fork.knife", emoji: ["🍔", "🍔", "🍕", "🍕", "🍟", "🍟", "🍣", "🍣", "🍦", "🍦", "🍩", "🍩"]),
        "Plants": (symbol: "leaf.fill", emoji: ["🌵", "🌵", "🌴", "🌴", "🌲", "🌲", "🌳", "🌳", "🍁", "🍁", "🍂", "🍂", "🍃", "🍃", "🌻", "🌻", "🌺", "🌺"])
    ]

    
    @State private var emojis: [String] = []
    
    var body: some View {
        VStack {
            Text("Memorize!")
                .font(.largeTitle)
                .padding()
            
            ScrollView {
                cards
            }
            
            HStack {
                ForEach(themes.keys.sorted(), id: \.self) { theme in
                    Button(action: {
                        emojis = themes[theme]!.emoji.shuffled()
                    }) {
                        VStack {
                            Image(systemName: themes[theme]!.symbol)
                                .font(.title)
                            Text(theme)
                        }
                        .padding()
                    }
                }
            }
            
        }
        .padding()
        .onAppear {
            if let animalEmojis = themes["Animals"]?.emoji {
                emojis = animalEmojis.shuffled()
            }
        }
    }
    
    var cards: some View {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                ForEach(emojis.indices, id: \.self) { index in
                    CardView(content: emojis[index], id: index)
                        .aspectRatio(2/3, contentMode: .fit)
                }
            }
            .foregroundColor(.orange)
        }
    }

struct CardView: View {
    let content: String
        let id: Int
    @State var isFaceUp = false
    
    var body: some View {
        ZStack {
            let base = RoundedRectangle(cornerRadius: 12)
            Group {
                base.fill(.white)
                base.strokeBorder(lineWidth: 2)
                Text(content).font(.largeTitle)
            }
            .opacity(isFaceUp ? 1 : 0)
            base.fill().opacity(isFaceUp ? 0 : 1)
        }
        .onTapGesture {
            isFaceUp.toggle()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
