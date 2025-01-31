//
//  ThreadView.swift
//  AINavigation
//
//  Created by Omar Torres on 1/25/25.
//

import SwiftUI

@Observable
final class ThreadViewManager: Identifiable {
	let id: String
	var conversationItem: ConversationItem
	var threadConversations = [ConversationItem]()
	
	init(conversationItem: ConversationItem) {
		id = conversationItem.id
		self.conversationItem = conversationItem
	}
	
	func sendPrompt(_ prompt: String) {
		let conversationId = UUID().uuidString
		let newConversation = ConversationItem(id: conversationId,
											   prompt: prompt,
											   output: "",
											   outputStatus: .pending)
		threadConversations.append(newConversation)
		request(prompt: newConversation.prompt) { content in
			DispatchQueue.main.async { [weak self] in
				guard let self else { return }
				if let index = self.threadConversations.firstIndex(where: { $0.id == conversationId }) {
					var updatedConversation = self.threadConversations[index]
					updatedConversation.output = content
					updatedConversation.outputStatus = .completed
					self.threadConversations[index] = updatedConversation
				}
			}
		}
	}
	
	private func request(prompt: String, completion: @escaping (String) -> Void) {
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
					completion(content)
				}
			} catch {
				print("Error parsing JSON: \(error)")
			}
		}.resume()
	}
}

struct ThreadView: View {
	@Bindable var chatViewManager: ChatViewManager
	@Bindable var threadViewManager: ThreadViewManager
	@State var highlightedText = ""
	
	init(chatViewManager: ChatViewManager,
		 threadViewManager: ThreadViewManager) {
		self.chatViewManager = chatViewManager
		self.threadViewManager = threadViewManager
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			Button {
				withAnimation(.easeInOut(duration: 0.3)) {
					chatViewManager.toggleThreadView()
				}
			} label: {
				Image(systemName: "arrow.right")
			}
			Text(threadViewManager.conversationItem.prompt)
			ConversationsScrollView(chatViewManager: chatViewManager,
									conversationItems: threadViewManager.threadConversations,
									highlightedText: $highlightedText,
									scrollViewProxy: .constant(nil),
									isThreadView: true,
									side: .right,
									sendPrompt: { prompt in
				threadViewManager.sendPrompt(prompt)
			})
		}
		.padding()
	}
}

#Preview {
	ThreadView(chatViewManager: ChatViewManager(),
			   threadViewManager: ThreadViewManager(conversationItem: ConversationItem.items.first!))
}
