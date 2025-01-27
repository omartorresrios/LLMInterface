//
//  PromptInputView.swift
//  AINavigation
//
//  Created by Omar Torres on 1/26/25.
//

import SwiftUI

struct PromptInputView: View {
	@State private var prompt = ""
	var sendPrompt: (String) -> Void
	@FocusState var isFocused: Bool
	var disablePromptEntry: Bool
	
	var body: some View {
		HStack {
			TextField("Enter your prompt", text: $prompt)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.onSubmit {
					if !prompt.isEmpty {
						sendPrompt(prompt)
					}
				}
				.focused($isFocused)
			
			Button(action: { sendPrompt(prompt) }) {
				Text("Send")
					.padding(.horizontal)
					.padding(.vertical, 8)
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(8)
			}
			.buttonStyle(.plain)
			.disabled(prompt.isEmpty)
		}
		.disabled(disablePromptEntry)
		.onAppear {
			DispatchQueue.main.async {
				isFocused = true
			}
		}
	}
}

#Preview {
	PromptInputView(sendPrompt: { _ in },
					disablePromptEntry: false)
}
