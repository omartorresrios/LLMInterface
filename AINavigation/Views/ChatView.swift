//
//  ChatView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct ChatView: View {
	@Binding var chatViewManager: ChatViewManager
	@State private var scrollViewProxy: ScrollViewProxy?
	@FocusState private var isFocused: Bool
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
			ZStack {
				HStack(alignment: .top, spacing: 0) {
					// THIS SIDEBAR COULD BE SHOWN ON TOP OF THE HSTACK
					//					if chatViewManager.showSidebar {
					//						promptsSidebarView
					//							.frame(width: geometry.size.width * 0.2)
					//					}
					ConversationsScrollView(chatViewManager: chatViewManager, 
											conversationItems: chatViewManager.conversationItems,
											highlightedText: $highlightedText,
											scrollViewProxy: $scrollViewProxy,
											isThreadView: false,
											side: .left)
					.frame(idealWidth: leftViewWidth, maxWidth: .infinity)
					.onPreferenceChange(ContentHeightPreferenceKey.self) { height in
						chatViewManager.showSidebar = height > geometry.size.height
					}
					.environment(\.customWidths, [.left: leftViewWidth])
					.onChange(of: chatViewManager.conversationItems.count) { _, _ in
						if let scrollViewProxy = scrollViewProxy {
							scrollToBottom(proxy: scrollViewProxy)
						}
					}
					
					if chatViewManager.showThreadView,
					   let threadManager = chatViewManager.getThreadManager() {
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
						ThreadView(chatViewManager: chatViewManager,
								   threadViewManager: threadManager)
							.frame(width: rightViewWidth)
							.environment(\.customWidths, [.right: rightViewWidth])
					}
				}
				.background(.green.opacity(0.5))
				.onAppear {
					DispatchQueue.main.async {
						totalWidth = geometry.size.width
						leftViewWidth = conversationsScrollViewWidth(with: totalWidth,
																		showThreadView: chatViewManager.showThreadView)
						rightViewWidth = threadViewConversationsScrollViewWidth(with: totalWidth)
					}
				}
				.onChange(of: chatViewManager.showThreadView) { _, newValue in
					leftViewWidth = conversationsScrollViewWidth(with: totalWidth,
																	showThreadView: newValue)
					rightViewWidth = threadViewConversationsScrollViewWidth(with: totalWidth)
				}
				
				if chatViewManager.showAIExplanationView {
					Color.black.opacity(0.3)
						.edgesIgnoringSafeArea(.all)
					AIExplainView(subjectToExplainText: highlightedText,
								  outputText: displayedText,
								  AIExplainItemIsPending: chatViewManager.AIExplainItem.outputStatus == .pending,
								  maxWidth: geometry.size.width * 0.5,
								  maxHeight: geometry.size.height * 0.8,
								  closeView: closeAIExplainViewAction)
					.onAppear {
						startAnimation()
					}
					.onChange(of: chatViewManager.AIExplainItem) { _, _ in
						startAnimation()
					}
				}
			}
		}
	}
	
	private func closeAIExplainViewAction() {
		chatViewManager.showAIExplanationView = false
		chatViewManager.resetAIExplainItem()
		displayedText = ""
		stopAnimation()
	}
	
	private func conversationsScrollViewWidth(with geometryWidth: CGFloat, showThreadView: Bool) -> CGFloat {
		let sidebarWidth = chatViewManager.showSidebar ? geometryWidth * 0.2 : 0
		let threadViewWidth = showThreadView ? geometryWidth * 0.3 : 0
		return geometryWidth - sidebarWidth - threadViewWidth
	}
	
	private func threadViewConversationsScrollViewWidth(with geometryWidth: CGFloat) -> CGFloat {
		let conversationsScrollViewWidth = geometryWidth * 0.7
		return geometryWidth - conversationsScrollViewWidth
	}
	
	private func startAnimation() {
		guard currentIndex == 0 else { return }
		isAnimating = true
		timer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { timer in
			guard currentIndex < chatViewManager.AIExplainItem.output.count else {
				timer.invalidate()
				isAnimating = false
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

#Preview {
	ChatView(chatViewManager: .constant(ChatViewManager()))
}
