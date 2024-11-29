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
			HStack(spacing: 20) {
				if !chatViews.isEmpty {
					draggableChatView(for: $chatViews[0])
					.frame(width: halfView(geometry.size.width),
						   height: fullHeight(geometry.size.height))
					
					VStack(spacing: 20) {
						ForEach(1..<chatViews.count, id: \.self) { index in
							draggableChatView(for: $chatViews[index])
							.frame(width: halfView(geometry.size.width),
								   height: chatViews.count == 2 ? fullHeight(geometry.size.height) : halfView(geometry.size.height))
						}
					}
					.frame(width: halfView(geometry.size.width),
						   height: fullHeight(geometry.size.height))
				}
			}
			.padding(20)
			.onAppear {
				windowSize = geometry.size
				if chatViews.isEmpty {
					addInitialChatView(in: windowSize)
				}
			}
			.onChange(of: chatViews.count) { _, newCount in
				for index in chatViews.indices {
					chatViews[index].branchOutDisabled = newCount > 2
				}
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
					.disabled(chatViews.count > 2)
				}
			}
		}
	}
	
	private func draggableChatView(for chatView: Binding<ChatViewModel>) -> some View {
		DraggableChatView(
			position: chatView.position,
			cards: chatView.cards,
			branchOutDisabled: chatView.branchOutDisabled.wrappedValue,
			onClose: { closeChatView(id: chatView.id) },
			onBranchOut: { addNewChatView() }
		)
	}
	
	private func fullHeight(_ parentHeight: CGFloat) -> CGFloat {
		return parentHeight - 40
	}
	
	private func halfView(_ parentWidth: CGFloat) -> CGFloat {
		return (parentWidth - 60) / 2
	}
	
	private func addInitialChatView(in size: CGSize) {
		let initialPosition = CGSize(width: 0, height: 0)
		let initialChatView = ChatViewModel(position: initialPosition, cards: [])
		chatViews.append(initialChatView)
	}

	private func closeChatView(id: UUID) {
		chatViews.removeAll { $0.id == id }
		if chatViews.isEmpty {
			closeWindow()
		}
	}

	private func addNewChatView() {
		guard chatViews.count < 3 else { return }
		let newChat = ChatViewModel(position: .zero, cards: [])
		chatViews.append(newChat)
	}

	private func closeWindow() {
		NSApplication.shared.keyWindow?.close()
	}
}

#Preview {
	ChatWindowView(chatId: UUID())
}
