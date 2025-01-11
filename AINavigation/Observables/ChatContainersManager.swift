//
//  ChatContainersManager.swift
//  AINavigation
//
//  Created by Omar Torres on 12/15/24.
//

import Observation
import SwiftUI

@Observable
final class ChatContainersManager {
	var chatViewManagers: [ChatViewManager] = []
	var selectedChatContainerId: UUID?
	
	init() {
		addInitialChatContainer()
	}
	
	func addInitialChatContainer() {
		let newChatContainer = ChatViewManager()
		chatViewManagers.append(newChatContainer)
		selectedChatContainerId = newChatContainer.id
	}
	
	func removeChatContainer(id: UUID) {
		chatViewManagers.removeAll { $0.id == id }
	}

	func addChatContainer() {
		let newChatContainer = ChatViewManager()
		chatViewManagers.append(newChatContainer)
		selectedChatContainerId = newChatContainer.id
	}
	
	func getSelectedChat() -> Binding<ChatViewManager>? {
		guard let selectedId = selectedChatContainerId,
			  let index = chatViewManagers.firstIndex(where: { $0.id == selectedId }) else {
			return nil
		}
		return Binding(
				get: { self.chatViewManagers[index] },
				set: { self.chatViewManagers[index] = $0 }
			)
	}
}
