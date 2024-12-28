//
//  ChatSectionView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct ChatSectionView: View {
	@Bindable var chatContainer: ChatContainer
	@State var selectedPromptIndex: Int?
	@State private var currentPromptIndex: Int = 0
	@State private var prompt: String = ""
	@State var chatCardViewWidth: CGFloat = 0.0
	var addNewPrompt: (Chat) -> Void
	@State private var disablePromptEntry = false
	@FocusState private var isFocused: Bool

	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .top, spacing: 0) {
				if chatContainer.showSidebar {
					sidebarContent
						.frame(width: geometry.size.width * 0.2)
				}
				mainContent(geometry)
					.frame(maxWidth: .infinity)
			}
		}
	}
	
	private var sidebarContent: some View {
		VStack(alignment: .leading) {
			Text("Prompts")
				.font(.headline)
				.padding()
			Divider()
			ForEach(chatContainer.section.chats.indices, id: \.self) { index in
				Button(action: {
					selectedPromptIndex = index
				}) {
					Text(chatContainer.section.chats[index].prompt)
						.foregroundColor(selectedPromptIndex == index ? .blue : .primary)
				}
				.padding(.vertical, 4)
			}
		}
		.padding()
	}

	private func mainContent(_ geometry: GeometryProxy) -> some View {
		VStack(spacing: 10) {
			if chatContainer.section.chats.isEmpty {
				Spacer()
				promptInputView
				Spacer()
			} else {
				ScrollViewReader { scrollProxy in
					ScrollView {
						VStack(spacing: 10) {
							ForEach(chatContainer.section.chats.indices, id:\.self) { index in
								ChatCardView(card: chatContainer.section.chats[index],
											 width: $chatCardViewWidth,
											 disablePromptEntry: $disablePromptEntry,
											 chatSection: chatContainer.section,
											 onRemove: { removePrompt(at: index) },
											 onBranchOut: { branchOut(from: scrollProxy, at: index) })
								.transition(.opacity.combined(with: .move(edge: .top)))
								.id(index)
								.background(
									GeometryReader { proxy in
										Color.clear
											.onAppear {
												chatCardViewWidth = proxy.size.width
											}
											.onChange(of: proxy.size.width) { _, newValue in
												chatCardViewWidth = newValue
											}
									}
								)
							}
							promptInputView
						}
						.padding()
						.background(
							GeometryReader { contentGeometry in
								Color.clear
									.onAppear {
										chatContainer.showSidebar = contentGeometry.size.height > geometry.size.height
									}
									.onChange(of: contentGeometry.size.height) { _, newHeight in
										chatContainer.showSidebar = newHeight > geometry.size.height
									}
							}
						)
					}
					.onChange(of: selectedPromptIndex) { _, newIndex in
						if let newIndex = newIndex {
							withAnimation {
								scrollProxy.scrollTo(newIndex, anchor: .top)
								selectedPromptIndex = nil
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
				.onSubmit {
					if !prompt.isEmpty {
						sendPrompt()
					}
				}
				.focused($isFocused)
			
			Button(action: sendPrompt) {
				Text("Send")
					.padding(.horizontal)
					.padding(.vertical,8)
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(8)
			}
			.buttonStyle(.plain)
			.disabled(prompt.isEmpty)
		}
		.disabled(disablePromptEntry)
		.padding(.horizontal, chatContainer.section.chats.count > 0 ? 0 : 16)
		.onAppear {
			DispatchQueue.main.async {
				isFocused = true
			}
		}
	}
	
	private func sendPrompt() {
		guard currentPromptIndex < Chat.cards.count else { return }
		var newPrompt = Chat.cards[currentPromptIndex]
		newPrompt.setPrompt(prompt)
		
		withAnimation(.easeInOut(duration: 0.5)) {
			addNewPrompt(newPrompt)
		}
		prompt = ""
		currentPromptIndex += 1
		isFocused = true
	}
	
	private func removePrompt(at index: Int) {
		withAnimation(.easeInOut(duration: 0.1)) {
			chatContainer.section.removeChat(at: index)
		}
		if chatContainer.section.chats.isEmpty {
			isFocused = true
		 }
	}
	
	private func branchOut(from scrollProxy: ScrollViewProxy, at index: Int) {
		withAnimation {
			scrollProxy.scrollTo(index, anchor: .center)
		}
	}
}
