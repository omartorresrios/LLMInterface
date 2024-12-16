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
		if !chatContainer.sections.isEmpty {
			HStack(spacing: 20) {
				ChatSectionView(chats: chatContainer.sections[0].chats,
								onClose: { onClose(at: 0) },
								onBranchOut: { onBranchOut() },
								onBranchOutDisabled: chatContainer.sections.count > 2,
								addNewPrompt: { chat in
					addNewPrompt(at: 0, with: chat)
				},
								removePrompt: { promptIndex in
					removePrompt(at: 0, promptIndex: promptIndex)
				})
				
				VStack(spacing: 20) {
					ForEach(Array(chatContainer.sections.dropFirst().enumerated()),
							id: \.element.id) { index, section in
						ChatSectionView(chats: section.chats,
										onClose: { onClose(at: index + 1) },
										onBranchOut: { onBranchOut() },
										onBranchOutDisabled: chatContainer.sections.count > 2,
										addNewPrompt: { chat in
							addNewPrompt(at: index + 1, with: chat)
						},
										removePrompt: { promptIndex in
							removePrompt(at: index + 1, promptIndex: promptIndex)
						})
					}
				}
			}
			.searchable(text: $chatContainer.searchText, prompt: "Search in chat history")
		}
	}
	
	private func removePrompt(at index: Int, promptIndex: Int) {
		chatContainer.sections[index].removePrompt(index: promptIndex)
	}
	
	private func addNewPrompt(at index: Int, with chat: Chat) {
		chatContainer.sections[index].addPrompt(chat: chat)
	}
	
	private func onClose(at index: Int) {
		if chatContainer.sections.count > 1 {
			chatContainer.removeChatSection(index: index)
		}
	}
	
	private func onBranchOut() {
		chatContainer.addChatSection()
	}
}

#Preview {
	ChatView(chatContainer: ChatContainer())
}
