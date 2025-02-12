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
	@Environment(\.colorScheme) var colorScheme
	let side: ViewSide
	
	private var textColor: Color {
		colorScheme == .dark ? textColorDark : textColorLight
	}
	
	private var inverseTextColor: Color {
		colorScheme == .dark ? textColorLight : textColorDark
	}
	
	var body: some View {
		HStack {
			TextField("Enter your prompt", text: $prompt)
				.textFieldStyle(.plain)
				.font(normalFont)
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
							if side == .left {
								onTapGesture?()
							}
						}
				)
				.focused($isFocused)
			
			Button(action: {
				sendPrompt(prompt)
				prompt = ""
			}) {
				Text("Send")
					.padding(.horizontal)
					.foregroundStyle(inverseTextColor)
					.font(normalFont)
					.padding(.vertical, 8)
					.background(buttonColor)
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
					disablePromptEntry: false,
					side: .left)
}
