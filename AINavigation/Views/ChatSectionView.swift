//
//  ChatSectionView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct ScrollViewWrapper<Content: View>: NSViewRepresentable {
	let content: Content
	@Binding var selectedPromptIndex: Int?
	@Binding var height: CGFloat
	var itemPositions: [Int: CGRect] = [:]
	@Binding var chatsChanged: Bool
	
	init(@ViewBuilder content: () -> Content,
		 selectedPromptIndex: Binding<Int?> = .constant(nil),
		 height: Binding<CGFloat>,
		 itemPositions: [Int: CGRect],
		 chatsChanged: Binding<Bool>) {
		self.content = content()
		_selectedPromptIndex = selectedPromptIndex
		_height = height
		self.itemPositions = itemPositions
		_chatsChanged = chatsChanged
	}
	
	func makeNSView(context: Context) -> NSScrollView {
		let scrollView = NSScrollView()
		scrollView.hasVerticalScroller = true
		scrollView.hasHorizontalScroller = false
		updateContent(scrollView)
		return scrollView
	}
	
	func updateNSView(_ nsView: NSScrollView, context: Context) {
		if chatsChanged {
			let oldOffset = nsView.contentView.bounds.origin.y
			updateContent(nsView)
			
			// Maintain scroll position after update
			DispatchQueue.main.async {
				nsView.contentView.scroll(to: NSPoint(x: 0, y: oldOffset))
				nsView.reflectScrolledClipView(nsView.contentView)
				self.chatsChanged = false
			}
		}
		if let selectedIndex = selectedPromptIndex,
		   let position = itemPositions[selectedIndex] {
			DispatchQueue.main.async {
				// Get the visible rect of the scroll view
				let visibleRect = nsView.contentView.bounds
				
				// Get document view height (total scrollable height)
				let documentHeight = nsView.documentView?.frame.height ?? 0
				
				// Calculate how much space would be left below the selected item
				let spaceBelow = documentHeight - position.maxY
				
				// Calculate the ideal scroll position
				let scrollPoint: NSPoint
				
				if spaceBelow < visibleRect.height {
					// If there's not enough content below to fill the visible area,
					// scroll to show the bottom of the content
					let y = max(0, documentHeight - visibleRect.height)
					scrollPoint = NSPoint(x: 0, y: y)
				} else {
					// If there's enough content below, position the selected item
					// with some padding from the top
					let itemHeight = position.height
					let y = max(0, position.minY - itemHeight)
					scrollPoint = NSPoint(x: 0, y: y)
				}
				
				nsView.contentView.scroll(to: scrollPoint)
				nsView.reflectScrolledClipView(nsView.contentView)
				selectedPromptIndex = nil
			}
		}
	}
	
	private func updateContent(_ scrollView: NSScrollView) {
		let contentView = NSHostingView(rootView: content)
		contentView.translatesAutoresizingMaskIntoConstraints = false
		
		// Set new content view
		scrollView.documentView = contentView
		
		// Update frame to fit content
		contentView.frame = NSRect(x: 0, y: 0, width: scrollView.bounds.width, height: contentView.fittingSize.height)
		DispatchQueue.main.async {
			height = contentView.frame.height
		}
	}
}

struct ChatSectionView: View {
	@Bindable var chatContainer: ChatContainer
	@State private var currentPromptIndex: Int = 0
	@State private var prompt: String = ""
	var addNewPrompt: (Chat) -> Void
	@State private var disablePromptEntry = false
	@FocusState private var isFocused: Bool
	@State private var selectedPromptIndex: Int?
	@State var scrollViewHeight: CGFloat = 0
	@State private var itemPositions: [Int: CGRect] = [:]
	@State private var chatsChanged: Bool = false
	@State var showSidebar = false
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .top, spacing: 0) {
				if showSidebar {
					sidebarContent
						.frame(width: geometry.size.width * 0.2)
				}
				VStack(alignment: .leading, spacing: 0) {
					if chatContainer.section.chats.isEmpty {
						promptInputView
							.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
					} else {
						ScrollViewWrapper(content: {
							VStack(alignment: .leading, spacing: 8) {
								ForEach(chatContainer.section.chats.indices, id: \.self) { index in
									chatCardView(with: index, geometry: geometry)
								}
								.padding()
								.background(.blue.opacity(0.3))
							}
							.frame(width: getWidth(geometryWidth: geometry.size.width))
						},
										  selectedPromptIndex: $selectedPromptIndex,
										  height: $scrollViewHeight,
										  itemPositions: itemPositions,
										  chatsChanged: $chatsChanged)
						.onChange(of: scrollViewHeight) { _, newHeight in
							showSidebar = newHeight > geometry.size.height
						}
						promptInputView
					}
				}
			}
		}
	}
	
	private func getWidth(geometryWidth: CGFloat) -> CGFloat {
		return geometryWidth * (showSidebar ? 0.8 : 1.0)
	}
	
	private func chatCardView(with index: Int, geometry: GeometryProxy) -> some View {
		ChatCardView(card: chatContainer.section.chats[index],
					 width: getWidth(geometryWidth: geometry.size.width),
					 disablePromptEntry: $disablePromptEntry,
					 chatSection: chatContainer.section,
					 onRemove: {},
					 onBranchOut: {})
		.background(
			GeometryReader { geometry in
				Color.clear.onAppear {
					itemPositions[index] = geometry.frame(in: .global)
				}
			}
		)
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
						selectedPromptIndex = index
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
		guard currentPromptIndex < Chat.cards.count else { return }
		var newPrompt = Chat.cards[currentPromptIndex]
		newPrompt.setPrompt(prompt)
		
		withAnimation(.easeInOut(duration: 0.5)) {
			addNewPrompt(newPrompt)
		}
		chatsChanged = true
		prompt = ""
		currentPromptIndex += 1
		isFocused = true
	}
	
	private func removePrompt(at index: Int) {
		withAnimation(.easeInOut(duration: 0.1)) {
			chatContainer.section.removeChat(at: index)
		}
		chatsChanged = true
		if chatContainer.section.chats.isEmpty {
			isFocused = true
		 }
	}
}
