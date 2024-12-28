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
	private var expandedPrompts: Set<Int> = []
	
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
	
	func toggleExpanded(_ id: Int) {
		if expandedPrompts.contains(id) {
			expandedPrompts.remove(id)
		} else {
			expandedPrompts.insert(id)
		}
	}
	
	func isExpanded(_ id: Int) -> Bool {
		expandedPrompts.contains(id)
	}
}
