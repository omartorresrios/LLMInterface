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
	var conversationItems: [ConversationItem] = []
	var prompt = ""
	var searchText = ""
	var selectedPromptIndex: Int?
	var showSidebar = false
	var showAIExplanationView = false
	var currentSelectedConversationItemId: String?
	
	func sendPrompt() {
		let conversationId = UUID().uuidString
		let newConversation = ConversationItem(id: conversationId,
											   prompt: prompt,
											   output: "",
											   outputStatus: .pending)
		conversationItems.append(newConversation)
		DispatchQueue.main.async {
			self.prompt = ""
		}
		guard let url = URL(string: "http://127.0.0.1:11434/api/chat") else {
			print("Invalid URL")
			return
		}

		let payload: [String: Any] = [
			"model": "llama3.2",
			"messages": [
				[
					"role": "user",
					"content": newConversation.prompt
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

		URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
						if let index = self?.conversationItems.firstIndex(where: { $0.id == conversationId }) {
							var updatedConversation = self?.conversationItems[index]
							updatedConversation?.output = content
							updatedConversation?.outputStatus = .completed
							self?.conversationItems[index] = updatedConversation ?? newConversation
						}
					}
				}
			} catch {
				print("Error parsing JSON: \(error)")
			}
		}.resume()
	}
	
	func addPrompt(conversationItem: ConversationItem) {
		conversationItems.append(conversationItem)
	}
	
	func removeConversationItem(_ conversationId: String) {
		if let index = conversationItems.firstIndex(where: { $0.id == conversationId }) {
			conversationItems.remove(at: index)
		}
	}
	
	func setName(_ name: String) {
		self.name = name
	}
}
