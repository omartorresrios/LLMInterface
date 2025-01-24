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
	@State var highlightedText = ""
	@State private var displayedText = ""
	@State private var isAnimating = false//To-do We are not using it currently. See if we can use for some validation
	@State private var currentIndex = 0
	@State private var timer: Timer?
	
	var body: some View {
		GeometryReader { geometry in
//			ZStack {
				HStack(alignment: .top, spacing: 0) {
//					if chatViewManager.showSidebar {
//						promptsSidebarView
//							.frame(width: geometry.size.width * 0.2)
//					}
						ConversationsScrollView(chatViewManager: chatViewManager,
												disablePromptEntry: disablePromptEntry,
												highlightedText: $highlightedText,
												scrollViewProxy: $scrollViewProxy,
												width: getWidth(geometryWidth: geometry.size.width),
												isThreadView: false)
						.onPreferenceChange(ContentHeightPreferenceKey.self) { height in
							chatViewManager.showSidebar = height > geometry.size.height
						}
//					}
					.frame(width: getWidth(geometryWidth: geometry.size.width))
					.onChange(of: chatViewManager.conversationItems.count) { _, _ in
						if let scrollViewProxy = scrollViewProxy {
							scrollToBottom(proxy: scrollViewProxy)
						}
					}
				}
				
//				if chatViewManager.showAIExplanationView {
//					Color.black.opacity(0.3)
//						.edgesIgnoringSafeArea(.all)
//					VStack {
//						Text("Explaining -> \(highlightedText)")
//						if chatViewManager.AIExplainItem.outputStatus == .pending {
//							ProgressView()
//						} else {
//							ScrollView {
//								Text(displayedText)
//									.padding()
//							}
//							Button("Close") {
//								chatViewManager.showAIExplanationView = false
//								chatViewManager.resetAIExplainItem()
//								displayedText = ""
//								disablePromptEntry = false
//								stopAnimation()
//							}
//							.buttonStyle(.bordered)
//						}
//					}
//					.onAppear {
//						startAnimation()
//					}
//					.onChange(of: chatViewManager.AIExplainItem) { _, _ in
//						startAnimation()
//					}
//					.padding()
//					.frame(maxWidth: geometry.size.width * 0.5, maxHeight: geometry.size.height * 0.8)
//					.background(Color(NSColor.windowBackgroundColor))
//					.foregroundColor(Color(NSColor.labelColor))
//					.cornerRadius(8)
//					.shadow(radius: 5)
//				}
//			}
//			.onChange(of: disablePromptEntry) { _, newValue in
//				isFocused = !newValue
//			}
		}
	}
	
	private func startAnimation() {
		guard currentIndex == 0 else { return }
		disablePromptEntry = true
		isAnimating = true
		timer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { timer in
			guard currentIndex < chatViewManager.AIExplainItem.output.count else {
				timer.invalidate()
				isAnimating = false
				disablePromptEntry = false
				currentIndex = 0
				return
			}
			
			let index = chatViewManager.AIExplainItem.output.index(chatViewManager.AIExplainItem.output.startIndex,
																   offsetBy: currentIndex)
			displayedText += String(chatViewManager.AIExplainItem.output[index])
			currentIndex += 1
		}
	}
	
	private func stopAnimation() {
		timer?.invalidate()
		timer = nil
		isAnimating = false
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
		let sidebarWidth = chatViewManager.showSidebar ? geometryWidth * 0.2 : 0
		return geometryWidth - sidebarWidth
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

struct PromptInputView: View {
	@Bindable var chatViewManager: ChatViewManager
	@FocusState var isFocused: Bool
	var disablePromptEntry: Bool
	
	var body: some View {
		HStack {
			TextField("Enter your prompt", text: $chatViewManager.prompt)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.onSubmit {
					if !chatViewManager.prompt.isEmpty {
						chatViewManager.sendPrompt()
					}
				}
				.focused($isFocused)
			
			Button(action: { chatViewManager.sendPrompt() }) {
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
}

struct ConversationsScrollView: View {
	@State var chatViewManager = ChatViewManager()
	@State var disablePromptEntry: Bool
	@Binding var highlightedText: String
	@Binding var scrollViewProxy: ScrollViewProxy?
	@FocusState var isFocused: Bool
	var width: CGFloat
	var isThreadView: Bool
	
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
								PromptView(conversationItem: conversationItem,
										   width: width,
										   disablePromptEntry: $disablePromptEntry,
										   chatViewManager: chatViewManager,
										   removePrompt: removeConversationItem,
										   highlightedText: $highlightedText,
										   isThreadView: isThreadView)
									.id(conversationItem.id)
							}
	//							.background(.blue)
						}
						.padding()
						.background(
							Group {
								if scrollViewProxy != nil {
									GeometryReader { contentGeometry in
										Color.clear.preference(key: ContentHeightPreferenceKey.self, value: contentGeometry.size.height)
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
	ChatView(chatViewManager: .constant(ChatViewManager()), addNewPrompt: { _ in })
}
