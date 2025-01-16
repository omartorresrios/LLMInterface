//
//  ChatCardView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct ChatCardView: View {
	let chat: Chat
	let width: CGFloat
	@Binding var disablePromptEntry: Bool
	@State var chatCardViewManager = ChatCardViewManager()
	@Bindable var chatViewManager: ChatViewManager
	@State private var hasMoreThanTwoLines = false
	var removePrompt: (String) -> Void
	@State private var displayedText = ""
	@State private var isAnimating = false
	@State private var currentIndex = 0
	@State private var timer: Timer?
	
	init(chat: Chat,
		 width: CGFloat,
		 disablePromptEntry: Binding<Bool>,
		 chatViewManager: ChatViewManager,
		 removePrompt: @escaping (String) -> Void) {
		self.chat = chat
		self.width = width
		_disablePromptEntry = disablePromptEntry
		self.chatViewManager = chatViewManager
		self.removePrompt = removePrompt
	}
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				HStack {
					Text(chat.prompt)
						.font(.headline)
					Button(action: {
						if chatCardViewManager.showAIExplainPopupView {
							chatCardViewManager.setAIExplainPopup(false)
						}
						chatCardViewManager.toggleThreadView()
						chatCardViewManager.highlightedText = ""
					}) {
						Image(systemName: "arrow.triangle.branch")
							.foregroundColor(.red)
					}
					.disabled(chatCardViewManager.showThreadView)
					Button {
						removePrompt(chat.id)
						if chatCardViewManager.showDeepDiveView {
							chatCardViewManager.setDeepDiveView(false)
						}
					} label: {
						Image(systemName: "trash")
							.foregroundColor(.red)
					}
					if hasMoreThanTwoLines && !isAnimating {
						Button {
							chatCardViewManager.toggleIsExpanded()
						} label: {
							Text(chatCardViewManager.isExpanded ? "Collapse" : "Show more")
								.font(.footnote)
								.foregroundColor(.blue)
						}
					}
				}
				.disabled(chatCardViewManager.showDeepDiveView || chat.status == .pending)
				
				if chat.status == .completed {
					HStack(alignment: .top) {
						ZStack(alignment: .bottom) {
							TextEditor(text: .constant(displayedText))
								.frame(height: chatCardViewManager.isExpanded ? nil : 100)
								.font(.custom("Helvetica Neue", size: 16))
								.scrollIndicators(.hidden)
								.scrollDisabled(true)
								.scrollContentBackground(.hidden)
								.background(.clear)
								.onReceive(NotificationCenter.default.publisher(for: NSView.frameDidChangeNotification)) { notification in
									clearTextSelection(notification: notification)
								}
								.onReceive(NotificationCenter.default.publisher(for: NSTextView.didChangeSelectionNotification)) { notification in
									updateHighlightedText(notification: notification)
								}
							if !chatCardViewManager.isExpanded {
								LinearGradient(
									gradient: Gradient(colors: [
										Color.gray.opacity(0),
										Color.gray.opacity(0.2)
									]),
									startPoint: .top,
									endPoint: .bottom
								)
								.frame(height: 50) // Height of blur effect
							}
						}
						if chatCardViewManager.showThreadView {
							VStack {
								Button {
									chatCardViewManager.toggleThreadView()
								} label: {
									Image(systemName: "arrow.right")
								}
								Text("This is just a test of the pop up view.")
							}
						}
					}
				} else {
					ProgressView()
						.padding(.top, 8)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding()
			.background(Color.gray.opacity(0.2))
			.cornerRadius(8)
			.onAppear {
				startAnimation()
			}
			.onChange(of: chat.output) { oldValue, newValue in
				startAnimation()
				if let font  = NSFont(name: "Helvetica Neue", size: 16) {
					hasMoreThanTwoLines = countLines(in: newValue,
													 width: width - 40,
													 font: font) > 20
				}
			}
			if chatCardViewManager.showAIExplainPopupView &&
				chatViewManager.currentlySelectedChatId == chat.id {
				VStack {
					Button("Explain") {
						chatCardViewManager.setAIExplainPopup(false)
						chatCardViewManager.setDeepDiveView(true)
						disablePromptEntry = true
					}
					.padding()
					.background(.red)
					.cornerRadius(8)
					.shadow(radius: 5)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else if chatCardViewManager.showDeepDiveView {
				VStack {
					Text("This is a random explanation from the model.")
						.padding()
					Button("Close") {
						chatCardViewManager.setDeepDiveView(false)
						chatCardViewManager.highlightedText = ""
						disablePromptEntry = false
					}
					.buttonStyle(.bordered)
				}
				.padding()
				.background(Color(NSColor.windowBackgroundColor))
				.foregroundColor(Color(NSColor.labelColor))
				.cornerRadius(8)
				.shadow(radius: 5)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
	}
	
	private func startAnimation() {
		guard currentIndex == 0 else { return }
		disablePromptEntry = true
		isAnimating = true
		timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
			guard currentIndex < chat.output.count else {
				timer.invalidate()
				isAnimating = false
				disablePromptEntry = false
				return
			}
			
			let index = chat.output.index(chat.output.startIndex, offsetBy: currentIndex)
			displayedText += String(chat.output[index])
			currentIndex += 1
		}
	}
	
	private func stopAnimation() {
		timer?.invalidate()
		timer = nil
		displayedText = chat.output
		isAnimating = false
		disablePromptEntry = false
	}
	
	private func countLines(in string: String, width: CGFloat, font: NSFont) -> Int {
		let attributedString = NSAttributedString(
			string: string,
			attributes: [.font: font]
		)
		let textStorage = NSTextStorage(attributedString: attributedString)
		let textContainer = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
		textContainer.lineFragmentPadding = 0
		
		let layoutManager = NSLayoutManager()
		layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(layoutManager)
		
		var numberOfLines = 0
		var index = 0
		var lineRange = NSRange(location: 0, length: 0)
		
		while index < textStorage.length {
			layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
			index = NSMaxRange(lineRange)
			numberOfLines += 1
		}
		return numberOfLines
	}
	
	private func clearTextSelection(notification: Notification) {
		guard let textView = notification.object as? NSTextView else { return }
		textView.insertionPointColor = .clear
		textView.selectedRange = NSRange(location: 0, length: 0)
	}

	private func updateHighlightedText(notification: Notification) {
		guard let textView = notification.object as? NSTextView,
			  let scrollView = textView.enclosingScrollView,
			  scrollView.superview != nil else { return }
		guard textView.string == chat.output else { return }
		print("helloooo")
		textView.insertionPointColor = .clear
		let selectionRange = textView.selectedRange()
		
		guard selectionRange.length > 0 else {
			if !chatCardViewManager.highlightedText.isEmpty {
				chatCardViewManager.highlightedText = ""
				chatCardViewManager.setAIExplainPopup(false)
			}
			return
		}

		DispatchQueue.main.async {
			if let substringRange = Range(selectionRange, in: chat.output) {
				if chatViewManager.currentlySelectedChatId != chat.id {
					// Clear previous selection
					chatViewManager.currentlySelectedChatId = chat.id
					// This will trigger the onChange in all other cards
					chatCardViewManager.highlightedText = ""
					chatCardViewManager.setAIExplainPopup(false)
				}
				// Set new selection
				chatCardViewManager.highlightedText = String(chat.output[substringRange])
				chatCardViewManager.setAIExplainPopup(true)
			}
		}
	}
}

#Preview {
	ChatCardView(chat: Chat.cards.first!, 
				 width: 20,
				 disablePromptEntry: .constant(false), 
				 chatViewManager: ChatViewManager(), 
				 removePrompt: { _ in })
}
