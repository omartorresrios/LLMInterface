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
	@State private var leftViewWidth: CGFloat = 0
	@State private var totalWidth: CGFloat = 0
	@State private var rightViewWidth: CGFloat = 0
	
	var body: some View {
		GeometryReader { geometry in
//			ZStack {
				HStack(alignment: .top, spacing: 0) {
					// THIS SIDEBAR COULD BE SHOWN ON TOP OF THE HSTACK
//					if chatViewManager.showSidebar {
//						promptsSidebarView
//							.frame(width: geometry.size.width * 0.2)
//					}
						ConversationsScrollView(chatViewManager: chatViewManager,
												disablePromptEntry: $disablePromptEntry,
												highlightedText: $highlightedText,
												scrollViewProxy: $scrollViewProxy,
												isThreadView: false,
												side: .left)
						.frame(width: leftViewWidth)
						.onPreferenceChange(ContentHeightPreferenceKey.self) { height in
							chatViewManager.showSidebar = height > geometry.size.height
						}
						.environment(\.customWidths, [.left: leftViewWidth])
//					}
					
					.onChange(of: chatViewManager.conversationItems.count) { _, _ in
						if let scrollViewProxy = scrollViewProxy {
							scrollToBottom(proxy: scrollViewProxy)
						}
					}
					if chatViewManager.showThreadView {
						DividerView()
							.frame(width: 4)
							.background(Color.gray)
							.gesture(
								DragGesture()
									.onChanged { value in
										let translation = value.translation.width
										let totalWidth = geometry.size.width
										
										// Adjust left and right view widths proportionally
										let newLeftWidth = leftViewWidth + translation
										let newRightWidth = rightViewWidth - translation
										
										// Set minimum and maximum constraints
										let minWidth = totalWidth * 0.3
										let maxWidth = totalWidth * 0.7
										
										// Ensure views stay within constraints
										if newLeftWidth >= minWidth && newLeftWidth <= maxWidth &&
										   newRightWidth >= minWidth && newRightWidth <= maxWidth {
											leftViewWidth = newLeftWidth
											rightViewWidth = newRightWidth
										}
									}
							)
						ThreadView(chatViewManager: chatViewManager)
							.frame(width: rightViewWidth)
							.environment(\.customWidths, [.right: rightViewWidth])
					}
				}
				.background(.green.opacity(0.5))
				.onAppear {
					DispatchQueue.main.async {
						totalWidth = geometry.size.width
						leftViewWidth = getConversationsScrollViewWidth(with: totalWidth,
																		showThreadView: chatViewManager.showThreadView)
						rightViewWidth = getThreadViewConversationsScrollViewWidth(with: totalWidth)
					}
				}
				.onChange(of: chatViewManager.showThreadView) { _, newValue in
					leftViewWidth = getConversationsScrollViewWidth(with: totalWidth,
																	showThreadView: newValue)
					rightViewWidth = getThreadViewConversationsScrollViewWidth(with: totalWidth)
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
		}
	}
	
	private func getConversationsScrollViewWidth(with geometryWidth: CGFloat, showThreadView: Bool) -> CGFloat {
		let sidebarWidth = chatViewManager.showSidebar ? geometryWidth * 0.2 : 0
		let threadViewWidth = showThreadView ? geometryWidth * 0.3 : 0
		return geometryWidth - sidebarWidth - threadViewWidth
	}
	
	private func getThreadViewConversationsScrollViewWidth(with geometryWidth: CGFloat) -> CGFloat {
		let conversationsScrollViewWidth = geometryWidth * 0.7
		return geometryWidth - conversationsScrollViewWidth
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
	@Bindable var chatViewManager: ChatViewManager
	@Binding var disablePromptEntry: Bool
	@Binding var highlightedText: String
	@Binding var scrollViewProxy: ScrollViewProxy?
	@FocusState var isFocused: Bool
	var isThreadView: Bool
	let side: ViewSide
	
	init(chatViewManager: ChatViewManager = ChatViewManager(),
		 disablePromptEntry: Binding<Bool>,
		 highlightedText: Binding<String>,
		 scrollViewProxy: Binding<ScrollViewProxy?>,
		 isThreadView: Bool,
		 side: ViewSide) {
		self.chatViewManager = chatViewManager
		_disablePromptEntry = disablePromptEntry
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
	//							.background(.blue)
						}
						.padding()
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
	ChatView(chatViewManager: .constant(ChatViewManager()), addNewPrompt: { _ in })
}
