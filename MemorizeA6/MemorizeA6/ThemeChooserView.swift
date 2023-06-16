//
//  ThemeChooserView.swift
//  MemorizeA6
//
//  Created by Annie Ma on 5/22/23.
//

import Foundation

import SwiftUI

struct ThemeChooserView: View {
    @ObservedObject var viewModel: ThemeChooserViewModel
    @State private var isShowingThemeEditor = false
    @State private var editIndex: Int?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.themes.indices, id: \.self) { index in
                    HStack {
                        NavigationLink(destination: EmojiMemoryGameView(viewModel: EmojiMemoryGame(theme: viewModel.themes[index]))) {
                            VStack(alignment: .leading) {
                                Text(viewModel.themes[index].name)
                                    .foregroundColor(Color(rgba: viewModel.themes[index].color))
                                Text("Cards: \(viewModel.themes[index].numberOfPairsOfCards * 2)")
                                HStack {
                                    ForEach(viewModel.themes[index].emojis, id: \.self) { emoji in
                                        Text(emoji)
                                    }
                                }
                            }
                        }
                        Button(action: {
                            editIndex = index
                            isShowingThemeEditor = true
                        }) {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .onDelete(perform: viewModel.deleteTheme)
            }
            .navigationBarTitle("Memorize")
            .navigationBarItems(leading: Button(action: {
                let newTheme = EmojiMemoryGame.Theme(name: "New theme", emojis: ["👻", "🌙"], numberOfPairsOfCards: 2, color: RGBA(color: Color.purple))
                viewModel.addTheme(newTheme)
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $isShowingThemeEditor) {
                if let editIndex = editIndex {
                    ThemeEditor(theme: $viewModel.themes[editIndex])
                }
            }
        }
    }
}



struct ThemeEditor: View {
    @Binding var theme: EmojiMemoryGame.Theme
    
    var body: some View {
        Form {
            Section {
                TextField("Theme Name", text: $theme.name)
            }
            Section(header: Text("Emojis")) {
                TextField("Add Emoji", text: Binding<String>(
                    get: { "" },
                    set: {
                        if let scalar = UnicodeScalar($0) {
                            theme.emojis.append(String(scalar))
                        }
                    }
                ))
                ForEach(theme.emojis, id: \.self) { emoji in
                    Text(emoji)
                }
                .onDelete { indexSet in
                    if theme.emojis.count > 2 {
                        theme.emojis.remove(atOffsets: indexSet)
                    }
                }
            }
            Section(header: Text("Card Count")) {
                Stepper(value: $theme.numberOfPairsOfCards, in: 2...theme.emojis.count, step: 1) {
                    Text("Pairs of Cards: \(theme.numberOfPairsOfCards)")
                }
            }
            Section(header: Text("Color")) {
                ColorPicker("Color", selection: Binding<Color>(
                    get: { theme.uiColor },
                    set: {
                        theme.color = RGBA(color: $0)
                    }
                ))
            }
        }
    }
}
