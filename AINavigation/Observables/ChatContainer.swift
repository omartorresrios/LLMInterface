//
//  ChatContainer.swift
//  AINavigation
//
//  Created by Omar Torres on 12/15/24.
//

import Foundation
import Observation

@Observable
final class ChatContainer: Identifiable {
	let id = UUID()
	var sections: [ChatSection]
	var searchText = ""
	
	init() {
		sections = [ChatSection()]
	}
	
	func removeChatSection(index: Int) {
		sections.remove(at: index)
	}
	
	func addChatSection() {
		sections.append(ChatSection())
	}
}
