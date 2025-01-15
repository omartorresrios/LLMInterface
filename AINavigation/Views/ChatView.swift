//
//  ChatView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct ChatView: View {
	@Binding var chatViewManager: ChatViewManager
	@State private var disablePromptEntry = false
	@State private var scrollViewProxy: ScrollViewProxy?
	@FocusState private var isFocused: Bool
	var addNewPrompt: (Chat) -> Void
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .top, spacing: 0) {
				if chatViewManager.showSidebar {
					promptsSidebarView
						.frame(width: geometry.size.width * 0.2)
				}
				VStack(alignment: .leading, spacing: 0) {
					if chatViewManager.chats.isEmpty {
						promptInputView
							.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
					} else {
						ScrollViewReader { scrollProxy in
							ScrollView {
								LazyVStack(alignment: .leading, spacing: 8) {
									ForEach(chatViewManager.chats, id: \.id) { chat in
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
									chatViewManager.showSidebar = height > geometry.size.height
								}
								.frame(width: getWidth(geometryWidth: geometry.size.width))
								.onChange(of: chatViewManager.chats.count) { _, newValue in
									scrollToBottom(proxy: scrollProxy)
								}
							}
							.onAppear {
								scrollViewProxy = scrollProxy
							}
							promptInputView
						}
					}
				}
			}
		}
	}
	
	private func scrollToBottom(proxy: ScrollViewProxy) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			withAnimation {
				if let lastChat = chatViewManager.chats.last {
					proxy.scrollTo(lastChat.id, anchor: .bottom)
				}
			}
		}
	}
	
	private func getWidth(geometryWidth: CGFloat) -> CGFloat {
		return geometryWidth * (chatViewManager.showSidebar ? 0.8 : 1.0)
	}
	
	private func chatCardView(chat: Chat, geometry: GeometryProxy) -> some View {
		ChatCardView(chat: chat,
					 width: getWidth(geometryWidth: geometry.size.width),
					 disablePromptEntry: $disablePromptEntry,
					 chatViewManager: chatViewManager,
					 removePrompt: removePrompt)
	}
	
	private var promptsSidebarView: some View {
		VStack(alignment: .leading) {
			Text("Prompts")
				.font(.headline)
				.padding()
			Divider()
			ForEach(chatViewManager.chats, id: \.id) { chat in
				Button(action: {
					if let index = chatViewManager.chats.firstIndex(where: { $0.id == chat.id }) {
						chatViewManager.selectedPromptIndex = index
						scrollToPrompt(chat.id)
					}
				}) {
					Text(chat.prompt)
						.foregroundColor(chatViewManager.selectedPromptIndex == chatViewManager.chats.firstIndex(where: { $0.id == chat.id }) ? .blue : .primary)
				}
				.padding(.vertical, 4)
			}
		}
		.padding()
	}
	
	private func scrollToPrompt(_ chatId: String) {
		if let scrollViewProxy = scrollViewProxy {
			withAnimation {
				scrollViewProxy.scrollTo(chatId)
			}
		}
	}

	private var promptInputView: some View {
		HStack {
			TextField("Enter your prompt", text: $chatViewManager.prompt)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.onSubmit {
					if !chatViewManager.prompt.isEmpty {
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
			.disabled(chatViewManager.prompt.isEmpty)
		}
		.disabled(disablePromptEntry)
		.padding(.horizontal, chatViewManager.chats.count > 0 ? 0 : 16)
		.onAppear {
			DispatchQueue.main.async {
				isFocused = true
			}
		}
	}
	
	private func sendPrompt() {
//		guard chatViewManager.chats.count < Chat.cards.count else { return }
//		var newPrompt = Chat.cards[chatViewManager.chats.count]
//		newPrompt.setPrompt(prompt)
//		
//		withAnimation(.easeInOut(duration: 0.5)) {
//			addNewPrompt(newPrompt)
//		}
		chatViewManager.sendPrompt()
		isFocused = true
	}
	
	private func removePrompt(_ chatId: String) {
		withAnimation(.easeInOut(duration: 0.1)) {
			chatViewManager.removeChat(chatId)
		}
		if chatViewManager.chats.isEmpty {
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
