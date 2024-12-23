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
	
	func addPrompt(chat: Chat) {
		chats.append(chat)
	}
}
