//
//  ChatView.swift
//  AINavigation
//
//  Created by Omar Torres on 12/15/24.
//

import SwiftUI

struct ChatView: View {
	@Bindable var chatContainer: ChatContainer
	
	var body: some View {
		ChatSectionView(chats: chatContainer.section.chats,
						addNewPrompt: { chat in
			addNewPrompt(with: chat)
		},
						removePrompt: { promptIndex in
			removePrompt(promptIndex: promptIndex)
		})
		.searchable(text: $chatContainer.searchText, prompt: "Search in chat history")
	}
	
	private func removePrompt(promptIndex: Int) {
		chatContainer.section.removePrompt(index: promptIndex)
	}
	
	private func addNewPrompt(with chat: Chat) {
		chatContainer.section.addPrompt(chat: chat)
	}
}

#Preview {
	ChatView(chatContainer: ChatContainer())
}
