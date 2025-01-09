//
//  ChatSectionView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct ChatSectionView: View {
	@Bindable var chatContainer: ChatContainer
	@State private var prompt: String = ""
	var addNewPrompt: (Chat) -> Void
	@State private var disablePromptEntry = false
	@FocusState private var isFocused: Bool
	@State private var contentHeight: CGFloat = 0
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .top, spacing: 0) {
				if chatContainer.showSidebar {
					sidebarContent
						.frame(width: geometry.size.width * 0.2)
				}
				VStack(alignment: .leading, spacing: 0) {
					if chatContainer.section.chats.isEmpty {
						promptInputView
							.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
					} else {
						ScrollView {
							ScrollViewReader { scrollProxy in
								LazyVStack(alignment: .leading, spacing: 8) {
									ForEach(chatContainer.section.chats, id: \.self) { chat in
										chatCardView(chat: chat, geometry: geometry)
											.id(chat.id)
									}
									.padding()
									.background(.blue.opacity(0.3))
								}
								.background(
									GeometryReader { contentGeometry in
										Color.clear.preference(key: ContentHeightPreferenceKey.self, value: contentGeometry.size.height)
									}
								)
								.onPreferenceChange(ContentHeightPreferenceKey.self) { height in
									contentHeight = height
									updateSidebarVisibility(screenHeight: geometry.size.height)
								}
								.frame(width: getWidth(geometryWidth: geometry.size.width))
								.onChange(of: chatContainer.section.chats.count) { _, newValue in
									scrollToBottom(proxy: scrollProxy)
								}
							}
						}
						promptInputView
					}
				}
			}
		}
	}
	
	private func updateSidebarVisibility(screenHeight: CGFloat) {
		chatContainer.showSidebar = contentHeight > screenHeight
	}
	
	private func scrollToBottom(proxy: ScrollViewProxy) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			withAnimation {
				if let lastChat = chatContainer.section.chats.last {
					proxy.scrollTo(lastChat.id, anchor: .bottom)
				}
			}
		}
	}
	
	private func getWidth(geometryWidth: CGFloat) -> CGFloat {
		return geometryWidth * (chatContainer.showSidebar ? 0.8 : 1.0)
	}
	
	private func chatCardView(chat: Chat, geometry: GeometryProxy) -> some View {
		ChatCardView(card: chat,
					 width: getWidth(geometryWidth: geometry.size.width),
					 disablePromptEntry: $disablePromptEntry,
					 chatSection: chatContainer.section,
					 onRemove: {},
					 onBranchOut: {})
	}
	
	private var sidebarContent: some View {
		VStack(alignment: .leading) {
			Text("Prompts")
				.font(.headline)
				.padding()
			Divider()
			ForEach(chatContainer.section.chats, id: \.id) { chat in
				Button(action: {
					if let index = chatContainer.section.chats.firstIndex(where: { $0.id == chat.id }) {
						chatContainer.selectedPromptIndex = index
					}
				}) {
					Text(chat.prompt)
						.foregroundColor(chatContainer.selectedPromptIndex == chatContainer.section.chats.firstIndex(where: { $0.id == chat.id }) ? .blue : .primary)
				}
				.padding(.vertical, 4)
			}
		}
		.padding()
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
					.padding(.vertical, 8)
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
		guard chatContainer.section.chats.count < Chat.cards.count else { return }
		var newPrompt = Chat.cards[chatContainer.section.chats.count]
		newPrompt.setPrompt(prompt)
		
		withAnimation(.easeInOut(duration: 0.5)) {
			addNewPrompt(newPrompt)
		}
		prompt = ""
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
}
struct ContentHeightPreferenceKey: PreferenceKey {
	static var defaultValue: CGFloat = 0
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = max(value, nextValue())
	}
}
