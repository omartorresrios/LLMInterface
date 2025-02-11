//
//  ConversationsScrollView.swift
//  AINavigation
//
//  Created by Omar Torres on 1/26/25.
//

import SwiftUI

struct ConversationsScrollView: View {
	@Bindable var chatViewManager: ChatViewManager
	var conversationItems: [ConversationItem]
	@State var disablePromptEntry = false
	@Binding var highlightedText: String
	@Binding var scrollViewProxy: ScrollViewProxy?
	@FocusState var isFocused: Bool
	var isThreadView: Bool
	let side: ViewSide
	var sendPrompt: ((String) -> Void)?
	@Environment(\.colorScheme) var colorScheme
	
	init(chatViewManager: ChatViewManager,
		 conversationItems: [ConversationItem],
		 highlightedText: Binding<String>,
		 scrollViewProxy: Binding<ScrollViewProxy?>,
		 isThreadView: Bool,
		 side: ViewSide,
		 sendPrompt: ((String) -> Void)? = nil) {
		self.chatViewManager = chatViewManager
		self.conversationItems = conversationItems
		_highlightedText = highlightedText
		_scrollViewProxy = scrollViewProxy
		self.isThreadView = isThreadView
		self.side = side
		self.sendPrompt = sendPrompt
	}
	
	private var inverseTextColor: Color {
		colorScheme == .dark ? textColorLight : textColorDark
	}
	
	var filteredItems: [ConversationItem] {
		if chatViewManager.searchText.isEmpty {
			return conversationItems
		} else {
			return conversationItems.filter { $0.output.localizedCaseInsensitiveContains(chatViewManager.searchText) }
		}
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			if conversationItems.isEmpty {
				PromptInputView(sendPrompt: { prompt in
					if side == .left {
						chatViewManager.sendPrompt(prompt)
					} else {
						sendPrompt?(prompt)
					}
				},
								isFocused: _isFocused,
								disablePromptEntry: disablePromptEntry)
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: side == .left ? .center : .bottom)
				.padding(side == .left ? 16 : 0)
			} else {
				ScrollViewReader { scrollProxy in
					ScrollView {
						LazyVStack(alignment: .leading, spacing: 8) {
							ForEach(filteredItems, id: \.id) { conversationItem in
								ConversationItemView(chatViewManager: chatViewManager,
													 conversationItemManager: conversationItemManager(conversationItem.id),
													 highlightedText: $highlightedText,
													 disablePromptEntry: $disablePromptEntry,
													 conversationItem: conversationItem,
													 isThreadView: isThreadView,
													 side: side,
													 removePrompt: removeConversationItem,
													 scrollToSelectedItem: { id in 
									scrollToSelectedItem(in: scrollViewProxy, to: id) }
								)
								.id(conversationItem.id)
							}
						}
						.padding([.leading, .top, .trailing], side == .left ? 16 : 0)
					}
					.onAppear {
						scrollViewProxy = scrollProxy
					}
					.overlay(alignment: .bottomTrailing) {
						Group {
							if chatViewManager.conversationItemIsAnimating {
								HStack(spacing: 4) {
									Text("Press")
										.font(normalFont)
										.foregroundStyle(inverseTextColor)
									
									Image("enter")
										.resizable()
										.renderingMode(.template)
										.foregroundStyle(inverseTextColor)
										.fontWeight(.heavy)
										.aspectRatio(contentMode: .fit)
										.frame(width: 18, height: 18)
										.clipped()
									
									Text("to get the answer right away")
										.font(normalFont)
										.foregroundStyle(inverseTextColor)
								}
								.padding(8)
								.background(buttonColor)
								.clipShape(RoundedRectangle(cornerRadius: 6.0))
							}
						}
						.padding(.trailing, side == .left ? 32 : 16)
						.padding([.bottom, .leading], side == .left ? 16 : 16)
					}
				}
				PromptInputView(sendPrompt: { prompt in
					if side == .left {
						chatViewManager.sendPrompt(prompt)
					} else {
						sendPrompt?(prompt)
					}
				},
								isFocused: _isFocused,
								disablePromptEntry: disablePromptEntry,
								onTapGesture: {
					withAnimation(.easeInOut(duration: 0.3)) {
						chatViewManager.showThreadView = false
					}
				})
				.padding([.leading, .bottom, .trailing], side == .left ? 16 : 0)
			}
		}
		.onChange(of: disablePromptEntry) { _, newValue in
			isFocused = !newValue
		}
	}
	
	private func scrollToSelectedItem(in scrollProxy: ScrollViewProxy?, to id: String) {
		if let currentSelectedConversationItemId = chatViewManager.currentOpenedConversationItemId {
			DispatchQueue.main.async {
				withAnimation {
					scrollProxy?.scrollTo(currentSelectedConversationItemId, anchor: .top)
				}
			}
		}
	}
	
	private func conversationItemManager(_ conversationItemId: String) -> ConversationItemViewManager {
		chatViewManager.getConversationItemManager(for: conversationItemId)
	}
	
	private func removeConversationItem(_ id: String) {
		withAnimation(.easeInOut(duration: 0.1)) {
			chatViewManager.removeConversationItem(id)
			chatViewManager.removeConversationItemManager(id: id)
		}
		if chatViewManager.conversationItems.isEmpty {
			isFocused = true
		 }
	}
}

#Preview {
	ConversationsScrollView(chatViewManager: ChatViewManager(),
							conversationItems: [ConversationItem.items.first!],
							highlightedText: .constant(""),
							scrollViewProxy: .constant(nil),
							isThreadView: true,
							side: .right, 
							sendPrompt: { _ in })
}
