//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by CS193p Instructor on 5/8/23.
//  Copyright (c) 2023 Stanford University
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    
    @State private var selectedEmojiIds = Set<EmojiArt.Emoji.ID>()
    @State private var dragging: Bool = false
    
    @ObservedObject var document: EmojiArtDocument
    
    private let paletteEmojiSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            if !selectedEmojiIds.isEmpty {
                Button(action: {
                    document.delete(emojisWithIds: selectedEmojiIds)
                    selectedEmojiIds = []
                }) {
                    Text("Delete selected emojis")
                }
                .padding()
            }
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
            
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .overlay(
                        Group {
                            if document.background != nil {
                                AsyncImage(url: document.background)
                            }
                        }
                    )
                    .onTapGesture {
                        selectedEmojiIds = []
                    }
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                return drop(sturldatas, at: location, in: geometry)
            }
        }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        ForEach(document.emojis, id: \.self) { emoji in
            ZStack {
                if selectedEmojiIds.contains(emoji.id) && !dragging && gestureZoom == 1 && gesturePan == .zero {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: CGFloat(emoji.size) + 10, height: CGFloat(emoji.size) + 10)
                }
                Text(emoji.string)
                    .font(emoji.font)
            }
            .position(emoji.position.in(geometry))
            .onTapGesture {
                if selectedEmojiIds.contains(emoji.id) {
                    selectedEmojiIds.remove(emoji.id)
                } else {
                    selectedEmojiIds.insert(emoji.id)
                }
            }
            .gesture(dragSelectedEmojisGesture(for: emoji))
        }
    }
    
    @GestureState private var gestureOffset: CGOffset = .zero
    
    
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                if !selectedEmojiIds.isEmpty {
                    for id in selectedEmojiIds {
                        document.resize(emojiWithId: id, by: inMotionPinchScale)
                    }
                }
                gestureZoom = inMotionPinchScale
            }
            .onEnded { endingPinchScale in
                if !selectedEmojiIds.isEmpty {
                    for id in selectedEmojiIds {
                        document.resize(emojiWithId: id, by: endingPinchScale)
                    }
                } else {
                    zoom *= endingPinchScale
                }
            }
    }
    
    
    private func dragSelectedEmojisGesture(for emoji: Emoji) -> some Gesture {
        DragGesture()
            .updating($gestureOffset) { inMotionDragGestureValue, gestureOffset, _ in
                let x = inMotionDragGestureValue.translation.width / zoom
                let y = inMotionDragGestureValue.translation.height / zoom
                gestureOffset = CGSize(width: x, height: y)
            }
            .onEnded { endingDragGestureValue in
                let finalx = endingDragGestureValue.translation.width / zoom
                let finaly = endingDragGestureValue.translation.height / zoom
                let finalOffset = CGSize(width: finalx, height: finaly)
                if selectedEmojiIds.contains(emoji.id) {
                    document.move(emojiWithIds: selectedEmojiIds, by: finalOffset)
                }
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { inMotionDragGestureValue, gesturePan, _ in
                if selectedEmojiIds.isEmpty {
                    let x = inMotionDragGestureValue.translation.width / zoom
                    let y = inMotionDragGestureValue.translation.height / zoom
                    gesturePan = CGSize(width: x, height: y)
                }
            }
            .onEnded { endingDragGestureValue in
                if selectedEmojiIds.isEmpty {
                    let finalx = endingDragGestureValue.translation.width / zoom
                    let finaly = endingDragGestureValue.translation.height / zoom
                    pan += CGSize(width: finalx, height: finaly)
                }
            }
    }
    
    
    private func drop(_ sturldatas: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url)
                return true
            case .string(let emoji):
                document.addEmoji(
                    emoji,
                    at: emojiPosition(at: location, in: geometry),
                    size: paletteEmojiSize / zoom
                )
                return true
            default:
                break
            }
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
}

struct EmojiArtDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
            .environmentObject(PaletteStore(named: "Preview"))
    }
}
