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
		ChatSectionView(chatContainer: chatContainer,
						addNewPrompt: { newChat in addNewPrompt(with: newChat) })
		.searchable(text: $chatContainer.searchText, prompt: "Search in chat history")
	}
	
	private func addNewPrompt(with chat: Chat) {
		chatContainer.showSidebar = false
		chatContainer.section.addPrompt(chat: chat)
	}
}

#Preview {
	ChatView(chatContainer: ChatContainer())
}
