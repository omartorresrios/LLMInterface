//
//  ChatViewManager.swift
//  AINavigation
//
//  Created by Omar Torres on 12/15/24.
//

import Foundation
import Observation

@Observable
final class ChatViewManager: Identifiable {
	let id = UUID()
	var name = "Unnamed chat"
	var chats: [Chat] = []
	var prompt = ""
	var searchText = ""
	var selectedPromptIndex: Int?
	var showSidebar = false
	var activeAIExplainPopupViewId: String?
	var highlightedCardId: String?
	private var expandedPrompts: Set<Int> = []
	
	func sendPrompt() {
		guard let url = URL(string: "http://127.0.0.1:11434/api/chat") else {
			print("Invalid URL")
			return
		}
		
		let payload: [String: Any] = [
			"model": "llama3.2",
			"messages": [
				[
					"role": "user",
					"content": prompt
				]
			],
			"stream": false
		]
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: payload)
		} catch {
			print("Error creating request body: \(error)")
			return
		}
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("Error: \(error)")
				return
			}
			
			guard let data = data else {
				print("No data received")
				return
			}
			
			do {
				if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
				   let message = json["message"] as? [String: Any],
				   let content = message["content"] as? String {
					DispatchQueue.main.async {
						print("Observing objects: ", content)
						let chat = Chat(id: UUID().uuidString, prompt: self.prompt, output: content)
						self.chats.append(chat)
						print("self.responses: ", self.chats)
						self.prompt = ""
					}
				}
			} catch {
				print("Error parsing JSON: \(error)")
			}
		}.resume()
	}
	
	func addPrompt(chat: Chat) {
		chats.append(chat)
	}
	
	func removeChat(at index: Int) {
		chats.remove(at: index)
	}
	
	func setName(_ name: String) {
		self.name = name
	}
	
	func setHighlightedCard(_ id: String) {
		highlightedCardId = id
		if id != activeAIExplainPopupViewId {
			activeAIExplainPopupViewId = nil
		}
	}
	
	func setActiveAIExplainPopupViewId(_ id: String?) {
		activeAIExplainPopupViewId = id
	}
	
	func clearAllSelections() {
		highlightedCardId = nil
		activeAIExplainPopupViewId = nil
	}
	
	func toggleExpanded(_ id: String) {
		if expandedPrompts.contains(Int(id) ?? 0) {
			expandedPrompts.remove(Int(id) ?? 0)
		} else {
			expandedPrompts.insert(Int(id) ?? 0)
		}
	}
	
	func isExpanded(_ id: String) -> Bool {
		expandedPrompts.contains(Int(id) ?? 0)
	}
}
