//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by CS193p Instructor on 5/8/23.
//  Copyright (c) 2023 Stanford University
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArt.Emoji
    
    @Published private var emojiArt = EmojiArt()
    
    init() {
        //        emojiArt.addEmoji("🚲", at: .init(x: -200, y: -150), size: 200)
        //        emojiArt.addEmoji("🔥", at: .init(x: 250, y: 100), size: 80)
    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: URL? {
        emojiArt.background
    }
    
    // MARK: - Intent(s)
    
    
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat) {
        emojiArt.addEmoji(emoji, at: position, size: Int(size))
    }
    
    func move(_ emoji: Emoji, by offset: CGSize) {
        let existingPosition = emojiArt[emoji].position
        emojiArt[emoji].position = Emoji.Position(
            x: existingPosition.x + Int(offset.width),
            y: existingPosition.y - Int(offset.height)
        )
    }
    
    func move(emojiWithId id: Emoji.ID, by offset: CGSize) {
        if let emoji = emojiArt[id] {
            move(emoji, by: offset)
        }
    }
    
    func move(emojiWithIds ids: Set<Emoji.ID>, by offset: CGSize) {
        for id in ids {
            move(emojiWithId: id, by: offset)
        }
    }
    
    func resize(_ emoji: Emoji, by scale: CGFloat) {
        var newSize = Int(CGFloat(emojiArt[emoji].size) * scale)
        newSize = max(10, min(newSize, 1000))
        emojiArt[emoji].size = newSize
    }
    
    func resize(emojiWithId id: Emoji.ID, by scale: CGFloat) {
        if let emoji = emojiArt[id] {
            resize(emoji, by: scale)
        }
    }
    
    func scaleAllEmojis(by scale: CGFloat) {
        for emoji in emojiArt.emojis {
            resize(emoji, by: scale)
        }
    }
    
    func delete(emojisWithIds ids: Set<EmojiArt.Emoji.ID>) {
        for id in ids {
            emojiArt.deleteEmoji(withId: id)
        }
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}

