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
	var onTapGesture: (() -> Void)? = nil
	
	var body: some View {
		HStack {
			TextField("Enter your prompt", text: $prompt)
				.textFieldStyle(.plain)
				.font(.system(size: 14))
				.onSubmit {
					if !prompt.isEmpty {
						sendPrompt(prompt)
						DispatchQueue.main.async {
							prompt = ""
						}
					}
				}
				.overlay(
					Color.clear
						.contentShape(Rectangle())
						.onTapGesture {
							isFocused = true
							onTapGesture?()
						}
				)
				.focused($isFocused)
			
			Button(action: {
				sendPrompt(prompt)
				prompt = ""
			}) {
				Text("Send")
					.padding(.horizontal)
					.font(.system(size: 14))
					.padding(.vertical, 8)
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(8)
			}
			.buttonStyle(.plain)
			.disabled(prompt.isEmpty)
		}
		.padding()
		.cornerRadius(8)
		.overlay(
			RoundedRectangle(cornerRadius: 8)
				.stroke(Color.gray, lineWidth: 0.5)
		)
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
