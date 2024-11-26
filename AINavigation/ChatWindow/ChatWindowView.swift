//
//  ChatWindowView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct ChatWindowView: View {
	let chatId: UUID
	@State private var chatViews: [ChatViewModel] = []
	
	init(chatId: UUID) {
		self.chatId = chatId
	}
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				ForEach($chatViews) { $chatView in
					DraggableChatView(
						position: $chatView.position,
						cards: $chatView.cards,
						size: $chatView.size, 
						onClose: { closeChatView(id: chatView.id) },
						onAddNewPrompt: { addNewChatView(in: geometry.size) }
					)
				}
				
				VStack {
					Spacer()
					HStack {
						Spacer()
						Button(action: { addNewChatView(in: geometry.size) }) {
							Image(systemName: "plus.circle.fill")
								.resizable()
								.frame(width: 44, height: 44)
						}
						.padding()
					}
				}
			}
			.onAppear {
				if chatViews.isEmpty {
					let padding: CGFloat = 20
					let initialPosition = CGSize(
						width: (geometry.size.width - 700) / 2,
						height: padding
					)
					let initialSize = CGSize(width: 700,
											 height: geometry.size.height - (padding * 2)
					)
					let initialChatView = ChatViewModel(size: initialSize,
														position: initialPosition,
														cards: [])
					chatViews.append(initialChatView)
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
	
	private func addNewChatView(in parentSize: CGSize) {
		let padding: CGFloat = 20
		let newPosition = CGSize(width: (parentSize.width - 700) / 2, height: padding)
		let newSize = CGSize(width: 700, height: parentSize.height - (padding * 2))
		let newChatView = ChatViewModel(size: newSize, 
										position: newPosition,
										cards: [])
		chatViews.append(newChatView)
	}
	
	private func closeWindow() {
		NSApplication.shared.keyWindow?.close()
	}
}

#Preview {
	ChatWindowView(chatId: UUID())
}
