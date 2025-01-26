//
//  PromptInputView.swift
//  AINavigation
//
//  Created by Omar Torres on 1/26/25.
//

import SwiftUI

struct PromptInputView: View {
	@Bindable var chatViewManager: ChatViewManager
	@FocusState var isFocused: Bool
	var disablePromptEntry: Bool
	
	var body: some View {
		HStack {
			TextField("Enter your prompt", text: $chatViewManager.prompt)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.onSubmit {
					if !chatViewManager.prompt.isEmpty {
						chatViewManager.sendPrompt()
					}
				}
				.focused($isFocused)
			
			Button(action: { chatViewManager.sendPrompt() }) {
				Text("Send")
					.padding(.horizontal)
					.padding(.vertical, 8)
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(8)
			}
			.buttonStyle(.plain)
			.disabled(chatViewManager.prompt.isEmpty)
		}
		.disabled(disablePromptEntry)
		.padding(.horizontal, chatViewManager.conversationItems.count > 0 ? 0 : 16)
		.onAppear {
			DispatchQueue.main.async {
				isFocused = true
			}
		}
	}
}

#Preview {
	PromptInputView(chatViewManager: ChatViewManager(), disablePromptEntry: false)
}
