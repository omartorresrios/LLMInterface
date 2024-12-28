//
//  ChatSection.swift
//  AINavigation
//
//  Created by Omar Torres on 12/15/24.
//

import Foundation
import Observation

@Observable
class ChatSection: Identifiable {
	let id = UUID()
	var chats: [Chat] = []
	var activeAIExplainPopupViewId: Int?
	var highlightedCardId: Int?
	
	func addPrompt(chat: Chat) {
		chats.append(chat)
	}
	
	func setHighlightedCard(_ id: Int?) {
		highlightedCardId = id
		if id != activeAIExplainPopupViewId {
			activeAIExplainPopupViewId = nil
		}
	}
	
	func setActiveAIExplainPopupViewId(_ id: Int?) {
		activeAIExplainPopupViewId = id
	}
	
	func removeChat(at index: Int) {
		chats.remove(at: index)
	}
	
	func clearAllSelections() {
		highlightedCardId = nil
		activeAIExplainPopupViewId = nil
	}
}
