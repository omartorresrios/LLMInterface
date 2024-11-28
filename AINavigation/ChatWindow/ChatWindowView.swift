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
	@State private var windowSize: CGSize = .zero
	
	init(chatId: UUID) {
		self.chatId = chatId
	}
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				ForEach(chatViews.indices, id: \.self) { index in
					DraggableChatView(
						position: $chatViews[index].position,
						cards: $chatViews[index].cards,
						size: $chatViews[index].size,
						onClose: { closeChatView(id: chatViews[index].id) },
						onAddNewPrompt: { addNewChatView() }
					)
				}
				
				VStack {
					Spacer()
					HStack {
						Spacer()
						Button(action: { addNewChatView() }) {
							Image(systemName: "plus.circle.fill")
								.resizable()
								.frame(width: 44, height: 44)
						}
						.padding()
					}
				}
			}
			.onAppear {
				windowSize = geometry.size
				if chatViews.isEmpty {
					addInitialChatView(in: windowSize)
				}
			}
		}
	}
	
	private func updateChatViewPositions() {
		let size = windowSize
		let padding: CGFloat = 20
		
		if chatViews.count == 1 {
			chatViews[0].size = CGSize(width: size.width - 40,
									   height: size.height - (padding * 2))
			chatViews[0].position = CGSize(width: padding, height: padding)
		} else if chatViews.count == 2 {
			let viewHeight = size.height - (padding * 2)
			let spaceBetween: CGFloat = 20
			let availableWidth = size.width - (2 * padding) - spaceBetween
			let viewWidth = availableWidth / 2
			
			chatViews[0].size = CGSize(width: viewWidth, height: viewHeight)
			chatViews[0].position = CGSize(width: padding, height: padding)
			
			chatViews[1].size = CGSize(width: viewWidth, height: viewHeight)
			chatViews[1].position = CGSize(width: padding + viewWidth + spaceBetween,
										   height: padding)
		} else if chatViews.count == 3 {
			let leftViewWidth = size.width / 2 - padding
			let rightViewWidth = size.width / 2 - padding
			let fullHeight = size.height - (padding * 2)
			let halfHeight = (size.height - (padding * 3)) / 2
			
			chatViews[0].size = CGSize(width: leftViewWidth, height: fullHeight)
			chatViews[0].position = CGSize(width: padding, height: padding)
			
			chatViews[1].size = CGSize(width: rightViewWidth, height: halfHeight)
			chatViews[1].position = CGSize(width: size.width / 2 + padding, height: padding)
		}
	}
	
	private func addInitialChatView(in size: CGSize) {
		let padding: CGFloat = 20
		let initialSize = CGSize(width: size.width - 40, 
								 height: size.height - (padding * 2))
		let centerX = size.width / 2
		let centerY = size.height / 2
		let initialPosition = CGSize(width: centerX - initialSize.width / 2,
									 height: centerY - initialSize.height / 2)
		let initialChatView = ChatViewModel(size: initialSize,
											position: initialPosition,
											cards: [])
		chatViews.append(initialChatView)
	}

	private func closeChatView(id: UUID) {
		chatViews.removeAll { $0.id == id }
		if chatViews.isEmpty {
			closeWindow()
		}
	}
	
	private func addNewChatView() {
		let padding: CGFloat = 20
			let newSize: CGSize
			let newPosition: CGSize
		let halfScreenWidth = windowSize.width / 2
				let viewWidth = halfScreenWidth - padding
				let viewHeight = windowSize.height - (padding * 2)
				newSize = CGSize(width: viewWidth, height: viewHeight)
				newPosition = CGSize(width: windowSize.width - padding - viewWidth / 2, height: windowSize.height / 2)
		let newChat = ChatViewModel(size: newSize, position: newPosition, cards: [])
			chatViews.append(newChat)
			updateChatViewPositions()
	}
	
	private func closeWindow() {
		NSApplication.shared.keyWindow?.close()
	}
}

#Preview {
	ChatWindowView(chatId: UUID())
}
