//
//  AINavigationApp.swift
//  AINavigation
//
//  Created by Omar Torres on 11/17/24.
//

import SwiftUI

@main
struct AINavigationApp: App {
    var body: some Scene {
        WindowGroup(id: "main") {
			ContentView()
        }
		
		WindowGroup(id: "chat", for: UUID.self) { $chatId in
			if let chatId = chatId {
				ChatWindowView(chatId: chatId)
			}
		}
    }
}

struct ChatWindowView: View {
	let chatId: UUID
	@State private var chatViews: [ChatViewModel]
	
	init(chatId: UUID) {
		self.chatId = chatId
		_chatViews = State(initialValue: [ChatViewModel(position: .zero, cards: Card.cards)])
	}
	
	var body: some View {
		ZStack {
			ForEach($chatViews) { $chatView in
				DraggableChatView(
					position: $chatView.position,
					cards: $chatView.cards,
					onClose: { closeChatView(id: chatView.id) }
				)
			}
			
			VStack {
				Spacer()
				HStack {
					Spacer()
					Button(action: addNewChatView) {
						Image(systemName: "plus.circle.fill")
							.resizable()
							.frame(width: 44, height: 44)
					}
					.padding()
				}
			}
		}
	}
	
	private func closeChatView(id: UUID) {
		chatViews.removeAll { $0.id == id }
		if chatViews.isEmpty {
			closeWindow()
		}
	}
	
	private func addNewChatView() {
		let newPosition = CGSize(width: CGFloat.random(in: 0...200), height: CGFloat.random(in: 0...200))
		let newChatView = ChatViewModel(position: newPosition, cards: Card.cards)
		chatViews.append(newChatView)
	}
	
	private func closeWindow() {
		NSApplication.shared.keyWindow?.close()
	}
}
