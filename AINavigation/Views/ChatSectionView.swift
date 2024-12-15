//
//  ChatSectionView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct ChatSectionView: View {
	var chats: [Chat]
	@State var selectedPromptIndex: Int?
	@State private var expandedPromptIndices: Set<Int> = []
	@State private var currentPromptIndex: Int = 0
	@State private var prompt: String = ""
	var onClose: () -> Void
	var onBranchOut: () -> Void
	var onBranchOutDisabled: Bool
	var addNewPrompt: (Chat) -> Void
	var removePrompt: (Int) -> Void
	
	var body: some View {
		ZStack(alignment: .topLeading) {
			RoundedRectangle(cornerRadius: 16)
				.fill(Color.gray.opacity(0.2))
				.overlay(
					HStack(alignment: .top, spacing: 0) {
						if !chats.isEmpty {
							sidebarContent
								.frame(width: 200)
								.background(Color.gray.opacity(0.1))
						}
						mainContent
					}
				)

			Button(action: onClose) {
				Image(systemName: "xmark.circle.fill")
					.resizable()
					.scaledToFit()
					.frame(width: 20, height: 20)
			}
			.buttonStyle(.plain)
			.padding(8)
		}
	}
	
	private var sidebarContent: some View {
		VStack(alignment: .leading) {
			Text("Indexed Questions")
				.font(.headline)
				.padding()
			Divider()
			ForEach(chats.indices, id: \.self) { index in
				Button(action: {
					selectedPromptIndex = index
				}) {
					Text(chats[index].prompt)
						.foregroundColor(selectedPromptIndex == index ? .blue : .primary)
				}
				.padding(.vertical, 4)
			}
		}
		.padding()
	}

	private var mainContent: some View {
		VStack(spacing: 10) {
			if chats.isEmpty {
				Spacer()
				promptInputView
				Spacer()
			} else {
				ScrollViewReader { scrollProxy in
					ScrollView {
						VStack(spacing: 10) {
							ForEach(chats.indices, id:\.self) { index in
								ChatCardView(
									card : chats[index],
									isExpanded : expandedPromptIndices.contains(index),
									branchOutDisabled: onBranchOutDisabled,
									onToggleExpand: {
										if expandedPromptIndices.contains(index) {
											expandedPromptIndices.remove(index)
										} else {
											expandedPromptIndices.insert(index)
										}
									},
									onRemove: {
										removePrompt(index)
									},
									onBranchOut: onBranchOut
								)
								.transition(.opacity)
							}
							promptInputView
						}
						.padding()
					}
					.onChange(of: selectedPromptIndex) { _, newIndex in
						if let newIndex = newIndex {
							withAnimation {
								scrollProxy.scrollTo(newIndex, anchor: .top)
							}
						}
					}
				}
			}
		}
	}
	
	private var promptInputView: some View {
		HStack {
			TextField("Enter your prompt", text: $prompt)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding(.leading)

			Button(action: sendPrompt){
				Text("Send")
					.padding(.horizontal)
					.padding(.vertical,8)
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(8)
			}
			.padding(.trailing).disabled(prompt.isEmpty || currentPromptIndex >= Chat.cards.count)
		}
	}
	
	private func sendPrompt() {
		guard !prompt.isEmpty && currentPromptIndex < Chat.cards.count else { return }
		
		var newPrompt = Chat.cards[currentPromptIndex]
		newPrompt.setQuestion(question: prompt)
		addNewPrompt(newPrompt)
		currentPromptIndex += 1
		prompt = ""
	}
}
