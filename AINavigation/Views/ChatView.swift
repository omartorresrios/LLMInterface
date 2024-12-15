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
		ZStack(alignment: .topLeading) {
			if !chatContainer.sections.isEmpty {
				HStack(spacing: 20) {
					ChatSectionView(chats: chatContainer.sections[0].chats,
									onClose: { if chatContainer.sections.count > 1 {
										chatContainer.removeChatSection(index: 0)
	  } },
									onBranchOut: { chatContainer.addChatSection() },
									onBranchOutDisabled: chatContainer.sections.count > 2,
									addNewPrompt: { chat in chatContainer.sections[0].addPrompt(chat: chat) },
									removePrompt: { index in chatContainer.sections[0].removePrompt(index: index)})

					VStack(spacing: 20) {
						ForEach(Array(chatContainer.sections.dropFirst().enumerated()),
								id: \.element.id) { index, section in
							ChatSectionView(chats: section.chats,
											onClose: {
								chatContainer.removeChatSection(index: index + 1)
							},
											onBranchOut: {
								chatContainer.addChatSection()
							},
											onBranchOutDisabled: chatContainer.sections.count > 2,
											addNewPrompt: { chat in
								chatContainer.sections[index + 1].addPrompt(chat: chat)
							},
											removePrompt: { promptIndex in
								chatContainer.sections[index + 1].removePrompt(index: promptIndex)
							})
						}
					}
				}
			}
		}
	}
}

#Preview {
	ChatView(chatContainer: ChatContainer())
}
