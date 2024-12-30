//
//  ChatsManager.swift
//  AINavigation
//
//  Created by Omar Torres on 12/15/24.
//

import Foundation
import Observation

@Observable
final class ChatsManager {
	var chatContainers: [ChatContainer] = []
	var selectedChatContainerId: UUID?
	
	init() {
		addInitialChatContainer()
	}
	
	func addInitialChatContainer() {
		let newChatContainer = ChatContainer()
		chatContainers.append(newChatContainer)
		selectedChatContainerId = newChatContainer.id
	}
	
	func removeChatContainer(id: UUID) {
		chatContainers.removeAll { $0.id == id }
	}

	func addChatContainer() {
		let newChatContainer = ChatContainer()
		chatContainers.append(newChatContainer)
		selectedChatContainerId = newChatContainer.id
	}
	
	func getSelectedChat() -> ChatContainer? {
		guard let selectedId = selectedChatContainerId else { return nil }
		return chatContainers.first(where: { $0.id == selectedId })
	}
}
