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
	var addNewPrompt: (ConversationItem) -> Void
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				HStack(alignment: .top, spacing: 0) {
					if chatViewManager.showSidebar {
						promptsSidebarView
							.frame(width: geometry.size.width * 0.2)
					}
					VStack(alignment: .leading, spacing: 0) {
						if chatViewManager.conversationItems.isEmpty {
							promptInputView
								.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
						} else {
							ScrollViewReader { scrollProxy in
								ScrollView {
									LazyVStack(alignment: .leading, spacing: 8) {
										ForEach(chatViewManager.conversationItems, id: \.id) { conversationItem in
											promptView(conversationItem: conversationItem, geometry: geometry)
												.id(conversationItem.id)
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
									.onChange(of: chatViewManager.conversationItems.count) { _, newValue in
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
				
				if chatViewManager.showAIExplanationView {
					Color.black.opacity(0.3)
						.edgesIgnoringSafeArea(.all)
					VStack {
						Text("This is a random explanation from the model.")
							.padding()
						Button("Close") {
							chatViewManager.showAIExplanationView = false
							disablePromptEntry = false
						}
						.buttonStyle(.bordered)
					}
					.padding()
					.frame(width: min(geometry.size.width * 0.8, 500))
					.background(Color(NSColor.windowBackgroundColor))
					.foregroundColor(Color(NSColor.labelColor))
					.cornerRadius(8)
					.shadow(radius: 5)
				}
			}
		}
	}
	
	private func scrollToBottom(proxy: ScrollViewProxy) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			withAnimation {
				if let lastCoversation = chatViewManager.conversationItems.last {
					proxy.scrollTo(lastCoversation.id, anchor: .bottom)
				}
			}
		}
	}
	
	private func getWidth(geometryWidth: CGFloat) -> CGFloat {
		return geometryWidth * (chatViewManager.showSidebar ? 0.8 : 1.0)
	}
	
	private func promptView(conversationItem: ConversationItem, geometry: GeometryProxy) -> some View {
		PromptView(conversationItem: conversationItem,
				   width: getWidth(geometryWidth: geometry.size.width),
				   disablePromptEntry: $disablePromptEntry,
				   chatViewManager: chatViewManager,
				   removePrompt: removeConversationItem)
	}
	
	private var promptsSidebarView: some View {
		VStack(alignment: .leading) {
			Text("Prompts")
				.font(.headline)
				.padding()
			Divider()
			ForEach(chatViewManager.conversationItems, id: \.id) { conversationItem in
				Button(action: {
					if let index = chatViewManager.conversationItems.firstIndex(where: { $0.id == conversationItem.id }) {
						chatViewManager.selectedPromptIndex = index
						scrollToConversationItem(conversationItem.id)
					}
				}) {
					Text(conversationItem.prompt)
						.foregroundColor(chatViewManager.selectedPromptIndex == chatViewManager.conversationItems.firstIndex(where: { $0.id == conversationItem.id }) ? .blue : .primary)
				}
				.padding(.vertical, 4)
			}
		}
		.padding()
	}
	
	private func scrollToConversationItem(_ id: String) {
		if let scrollViewProxy = scrollViewProxy {
			withAnimation {
				scrollViewProxy.scrollTo(id)
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
		.padding(.horizontal, chatViewManager.conversationItems.count > 0 ? 0 : 16)
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
	
	private func removeConversationItem(_ id: String) {
		withAnimation(.easeInOut(duration: 0.1)) {
			chatViewManager.removeConversationItem(id)
		}
		if chatViewManager.conversationItems.isEmpty {
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
