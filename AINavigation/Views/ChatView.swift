//
//  ChatView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct ChatView: View {
	@Environment(\.chatsWidth) private var chatsSidebarWidth: CGFloat
	@Binding var chatViewManager: ChatViewManager
	@State private var scrollViewProxy: ScrollViewProxy?
	@FocusState private var isFocused: Bool
	@State var highlightedText = ""
	@State private var displayedText = ""
	@State private var isAnimating = false//To-do We are not using it currently. See if we can use for some validation
	@State private var showSidebar = false
	@State private var currentIndex = 0
	@State private var timer: Timer?
	@State private var totalWidth: CGFloat = 0
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .leading) {
				ZStack(alignment: .trailing) {
					VStack(alignment: .leading, spacing: 0) {
						if chatViewManager.conversationItems.count > 3 {
							withAnimation {
								SearchField(searchText: $chatViewManager.searchText)
									.padding(.horizontal)
									.padding(.top)
									.padding(.bottom, 8)
									.frame(maxWidth: (geometry.size.width * 0.8) / 2)
							}
						}
						
						ConversationsScrollView(chatViewManager: chatViewManager,
												conversationItems: chatViewManager.conversationItems,
												highlightedText: $highlightedText,
												scrollViewProxy: $scrollViewProxy,
												isThreadView: false,
												side: .left)
						.frame(maxWidth: .infinity)
						.environment(\.customWidths, [.left: geometry.size.width])
						.onChange(of: chatViewManager.conversationItems.count) { _, newValue in
							if let scrollViewProxy = scrollViewProxy {
								scrollToBottom(proxy: scrollViewProxy)
							}
						}
					}
				
					if chatViewManager.showThreadView,
					   let threadManager = chatViewManager.getThreadManager() {
						ThreadView(chatViewManager: chatViewManager,
								   threadViewManager: threadManager)
						.frame(width: geometry.size.width / 2)
						.environment(\.customWidths, [.right: geometry.size.width / 2])
						.background(Color(NSColor.windowBackgroundColor))
						.clipShape(RoundedRectangle(cornerRadius: 6.0))
							.shadow(
								color: .black.opacity(0.2),
								radius: 8,
								x: -4, // Negative x to place shadow on the left
								y: 2
							)
							.compositingGroup()
							.transition(
								.asymmetric(
									insertion: .move(edge: .trailing).combined(with: .opacity),
									removal: .move(edge: .trailing).combined(with: .opacity)
								)
							)
					}
				}
				.overlay(
					Group {
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
					}, alignment: .center
				)
				
				if showSidebar && chatViewManager.conversationItems.count > 3 {
					PromptsSidebarView(conversationItems: chatViewManager.conversationItems,
									   selectedPromptIndex: chatViewManager.selectedPromptIndex,
									   geometry: geometry,
									   onSelectedItem: { onSelectedItem($0.id) })
					.frame(width: geometry.size.width * 0.2)
					.clipShape(RoundedRectangle(cornerRadius: 6.0))
					.shadow(color: .black.opacity(0.2), radius: 8, x: 4, y: 0)
				}
			}
			.onChange(of: chatsSidebarWidth) { _, newValue in
				startMouseTracking(geometry, newValue)
			}
		}
	}
	
	private func startMouseTracking(_ geometry: GeometryProxy,
									_ chatsSidebarWidth: CGFloat) {
		NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { event in
			let adjustedX = event.locationInWindow.x - chatsSidebarWidth
			withAnimation(.easeInOut(duration: 0.2)) {
				if adjustedX < 20 && adjustedX > 0 {
					showSidebar = true
				} else if adjustedX > geometry.size.width * 0.2 {
					showSidebar = false
				}
			}
			return event
		}
	}
	
	private func onSelectedItem(_ conversationItemId: String) {
		if let index = chatViewManager.conversationItems.firstIndex(where: { $0.id == conversationItemId }) {
			chatViewManager.selectedPromptIndex = index
			scrollToConversationItem(conversationItemId)
		}
	}
	
	private func closeAIExplainViewAction() {
		chatViewManager.showAIExplanationView = false
		chatViewManager.resetAIExplainItem()
		displayedText = ""
		stopAnimation()
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
	
	private func scrollToConversationItem(_ id: String) {
		if let scrollViewProxy = scrollViewProxy {
			withAnimation {
				scrollViewProxy.scrollTo(id, anchor: .top)
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

struct PromptsSidebarView: View {
	let conversationItems: [ConversationItem]
	let selectedPromptIndex: Int?
	@State private var showPrompts = false
	let geometry: GeometryProxy
	var onSelectedItem: (ConversationItem) -> Void
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("Prompts")
				.font(.headline)
			ForEach(conversationItems, id: \.id) { conversationItem in
				Button(action: {
					onSelectedItem(conversationItem)
				}) {
					Text(conversationItem.prompt)
						.foregroundColor(selectedPromptIndex == conversationItems.firstIndex(where: { $0.id == conversationItem.id }) ? .blue : .primary)
				}
			}
		}
		.padding(8)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
		.background(Color(NSColor.windowBackgroundColor))
	}
}


#Preview {
	ChatView(chatViewManager: .constant(ChatViewManager()))
}
