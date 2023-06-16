//
//  ContentView.swift
//  Set
//
//  Created by Annie Ma on 4/24/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: SetGameViewModel
    @Namespace private var deckAnimation
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button("New Game") {
                        withAnimation(.easeInOut(duration: 1)) {
                            viewModel.newGame()
                        }
                    }
                    Button("Shuffle") {
                        withAnimation(.easeInOut(duration: 1)) {
                            viewModel.shuffle()
                        }
                    }
                }
                
                // Deck
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray)
                        .frame(width: 60, height: 90)
                    ForEach(viewModel.deck) { card in
                        CardView(card: card, geometry: nil, viewModel: viewModel, isSelected: .constant(false))
                            .matchedGeometryEffect(id: card.id, in: deckAnimation)
                    }
                    if viewModel.deck.count > 0 {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.orange)
                            .frame(width: 60, height: 90)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 1)) {
                        viewModel.dealThreeMoreCards()
                    }
                }
                .padding()
                // Discard Pile
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray)
                        .frame(width: 60, height: 90)
                    ForEach(viewModel.discardedCards) { card in
                        CardView(card: card, geometry: nil, viewModel: viewModel, isSelected: .constant(false))
                            .matchedGeometryEffect(id: card.id, in: deckAnimation)
                    }
                }
            }
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 40, maximum: 120)), count: viewModel.numberOfColumns)) {
                    ForEach(viewModel.cards) { card in
                        GeometryReader { geometry in
                            CardView(card: card, geometry: geometry, viewModel: viewModel, isSelected: Binding(get: { viewModel.cards.contains(where: { $0.id == card.id && $0.isSelected }) }, set: { _ in viewModel.choose(card: card) }))
                                .matchedGeometryEffect(id: card.id, in: deckAnimation)
                        }
                        .aspectRatio(2/3, contentMode: .fit)
                    }
                }
                .padding(5)
            }
        }
        .padding()
    }
}

extension Animation {
    static func spin(duration: TimeInterval) -> Animation {
        .linear(duration: duration).repeatCount(2, autoreverses: false)
    }
    static func scale(duration: TimeInterval) -> Animation {
            .easeInOut(duration: duration).repeatCount(1, autoreverses: true)
        }
}

struct CardView: View {
    let card: SetGameViewModel.Card
    let geometry: GeometryProxy?
    let viewModel: SetGameViewModel
    
    @Binding var isSelected: Bool
    
    
    
    var body: some View {
            VStack {
                ForEach(0..<card.content.number, id: \.self) { _ in
                    createShapeView(card.content.shape)
                }
            }
            .frame(width: geometry?.size.width ?? 60, height: geometry?.size.height ?? 90)
            .background(.white)
            .cornerRadius(10)
            .shadow(radius: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 5)
                    .opacity(isSelected ? 1 : 0)
                    .foregroundColor(backgroundColor)
            )
            .onTapGesture {
                withAnimation {
                    viewModel.choose(card: card)
                }
            }
            .rotationEffect(.degrees(card.isMatched ? 360 : 0))
            .scaleEffect(card.isWronglyMatched ? 0.8 : 1)
            .animation(.spin(duration: 0.5), value: card.isMatched)
            .animation(.scale(duration: 0.5), value: card.isWronglyMatched)
            
        }
    
    private func createShapeView(_ shape: ShapeType) -> some View {
        let shapeView =  getShapeView(shape)
        return shapeView
            .frame(width: (geometry?.size.width ?? 60) * 2/3, height: (geometry?.size.height ?? 90)! * 1/5)
    }
    
    @ViewBuilder
    private func getShapeView(_ shape: ShapeType) -> some View {
        switch shape {
        case .circle:
            RoundedRectangle(cornerRadius: 100)
                .fill(shadingColor.opacity(shadingOpacity))
                .foregroundColor(shadingColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(lineWidth: 2)
                        .foregroundColor(shadingColor)
                )
        case .rectangle:
            Rectangle()
                .fill(shadingColor.opacity(shadingOpacity))
                .foregroundColor(shadingColor)
                .overlay(
                    Rectangle()
                        .stroke(lineWidth: 2)
                        .foregroundColor(shadingColor)
                )
        case .diamond:
            Diamond()
                .fill(shadingColor.opacity(shadingOpacity))
                .foregroundColor(shadingColor)
                .overlay(
                    Diamond()
                        .stroke(lineWidth: 2)
                        .foregroundColor(shadingColor)
                )
        }
    }
    
    
    
    struct Diamond: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            let top = CGPoint(x: rect.midX, y: rect.minY)
            let bottom = CGPoint(x: rect.midX, y: rect.maxY)
            let left = CGPoint(x: rect.minX, y: rect.midY)
            let right = CGPoint(x: rect.maxX, y: rect.midY)
            
            path.move(to: top)
            path.addLine(to: right)
            path.addLine(to: bottom)
            path.addLine(to: left)
            path.closeSubpath()
            
            return path
        }
    }
    
    private var backgroundColor: Color {
        if card.isSelected {
            if card.isMatched {
                return Color.green
            } else if viewModel.selectedCards.count == 3 {
                return Color.red
            } else {
                return Color.blue
            }
        } else {
            return Color.orange
        }
    }
    
    private var shadingColor: Color {
        switch card.content.color {
        case .red:
            return Color.red
        case .green:
            return Color.green
        case .blue:
            return Color.blue
        }
    }
    
    private var shadingOpacity: Double {
        switch card.content.shading {
        case .opaque:
            return 1.0
        case .translucent:
            return 0.3
        case .transparent:
            return 0.0
        }
    }
}

struct SetGameView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: SetGameViewModel())
            .environmentObject(SetGameViewModel())
    }
}
