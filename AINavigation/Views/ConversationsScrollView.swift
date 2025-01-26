//
//  ConversationsScrollView.swift
//  AINavigation
//
//  Created by Omar Torres on 1/26/25.
//

import SwiftUI

struct ConversationsScrollView: View {
	@Bindable var chatViewManager: ChatViewManager
	@State var disablePromptEntry = false
	@Binding var highlightedText: String
	@Binding var scrollViewProxy: ScrollViewProxy?
	@FocusState var isFocused: Bool
	var isThreadView: Bool
	let side: ViewSide
	
	init(chatViewManager: ChatViewManager = ChatViewManager(),
		 highlightedText: Binding<String>,
		 scrollViewProxy: Binding<ScrollViewProxy?>,
		 isThreadView: Bool,
		 side: ViewSide) {
		self.chatViewManager = chatViewManager
		_highlightedText = highlightedText
		_scrollViewProxy = scrollViewProxy
		self.isThreadView = isThreadView
		self.side = side
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			if chatViewManager.conversationItems.isEmpty {
				PromptInputView(chatViewManager: chatViewManager,
								isFocused: _isFocused,
								disablePromptEntry: disablePromptEntry)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
			} else {
				ScrollViewReader { scrollProxy in
					ScrollView {
						LazyVStack(alignment: .leading, spacing: 8) {
							ForEach(chatViewManager.conversationItems, id: \.id) { conversationItem in
								PromptView(chatViewManager: chatViewManager,
										   highlightedText: $highlightedText,
										   disablePromptEntry: $disablePromptEntry,
										   conversationItem: conversationItem,
										   isThreadView: isThreadView,
										   side: side,
										   removePrompt: removeConversationItem)
									.id(conversationItem.id)
							}
						}
						.padding(side == .left ? 16 : 0)
						.background(
							Group {
								if scrollViewProxy != nil {
									GeometryReader { contentGeometry in
										Color.clear.preference(key: ContentHeightPreferenceKey.self,
															   value: contentGeometry.size.height)
									}
								}
							}
						)
					}
					.onAppear {
						scrollViewProxy = scrollProxy
					}
				}
				PromptInputView(chatViewManager: chatViewManager,
								isFocused: _isFocused,
								disablePromptEntry: disablePromptEntry)
			}
		}
		.onChange(of: disablePromptEntry) { _, newValue in
			isFocused = !newValue
		}
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

#Preview {
	ConversationsScrollView(highlightedText: .constant(""),
							scrollViewProxy: .constant(nil),
							isThreadView: true,
							side: .right)
}
