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
	var name = "Unnamed chat"
	var section: ChatSection
	var searchText = ""
	var selectedPromptIndex: Int?
	var showSidebar = false
	
	init() {
		section = ChatSection()
	}
	
	func setName(_ name: String) {
		self.name = name
	}
}
