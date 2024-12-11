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
	@Binding var zoomingOut: Bool
	@Binding var chatViewsCount: Int
	
	init(chatId: UUID,
		 zoomingOut: Binding<Bool>,
		 chatViewsCount: Binding<Int>) {
		self.chatId = chatId
		_zoomingOut = zoomingOut
		_chatViewsCount = chatViewsCount
	}
	
	var body: some View {
		GeometryReader { geometry in
			HStack(spacing: 20) {
				if !chatViews.isEmpty {
					draggableChatView(for: $chatViews[0])
						.frame(width: singleChatViewWidth(geometry: geometry),
						   height: full(geometry.size.height))
					
					VStack(spacing: 20) {
						ForEach(1..<chatViews.count, id: \.self) { index in
							draggableChatView(for: $chatViews[index])
							.frame(width: half(geometry.size.width),
								   height: multipleChatViewHeight(geometry: geometry))
						}
					}
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
				chatViewsCount = newCount
				for index in chatViews.indices {
					chatViews[index].branchOutDisabled = newCount > 2
				}
			}
			
			VStack {
				Spacer()
				HStack {
					Spacer()
					Button {
						addNewChatView()
					} label: {
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
		DraggableChatView(position: chatView.position,
						  cards: chatView.cards,
						  branchOutDisabled: chatView.branchOutDisabled.wrappedValue,
						  onClose: { closeChatView(id: chatView.id) },
						  onBranchOut: { addNewChatView() })
	}
	
	private func full(_ parentHeight: CGFloat) -> CGFloat {
		return parentHeight - 40
	}
	
	private func half(_ parentHeight: CGFloat) -> CGFloat {
		return (parentHeight - 60) / 2
	}
	
	private func singleChatViewWidth(geometry: GeometryProxy) -> CGFloat {
		zoomingOut ? half(geometry.size.width) : full(geometry.size.width)
	}
	
	private func multipleChatViewHeight(geometry: GeometryProxy) -> CGFloat {
		chatViews.count == 2 ? full(geometry.size.height) : half(geometry.size.height)
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
	ChatWindowView(chatId: UUID(), 
				   zoomingOut: .constant(false),
				   chatViewsCount: .constant(0))
}
