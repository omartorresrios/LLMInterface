//
//  PromptView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct PromptView: View {
	let conversationItem: ConversationItem
	let width: CGFloat
	@Binding var disablePromptEntry: Bool
	@State var promptViewManager = PromptViewManager()
	@Bindable var chatViewManager: ChatViewManager
	@State private var hasMoreThanTwoLines = false
	var removePrompt: (String) -> Void
	@State private var displayedText = ""
	@State private var isAnimating = false
	@State private var currentIndex = 0
	@State private var timer: Timer?
	@State private var selectionFrame: CGRect = .zero
	
	init(conversationItem: ConversationItem,
		 width: CGFloat,
		 disablePromptEntry: Binding<Bool>,
		 chatViewManager: ChatViewManager,
		 removePrompt: @escaping (String) -> Void) {
		self.conversationItem = conversationItem
		self.width = width
		_disablePromptEntry = disablePromptEntry
		self.chatViewManager = chatViewManager
		self.removePrompt = removePrompt
	}
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				HStack {
					Text(conversationItem.prompt)
						.font(.headline)
					Button(action: {
						if promptViewManager.showAIExplainButton {
							promptViewManager.setAIExplainButton(false)
						}
						promptViewManager.toggleThreadView()
						promptViewManager.highlightedText = ""
					}) {
						Image(systemName: "arrow.triangle.branch")
							.foregroundColor(.red)
					}
					.disabled(promptViewManager.showThreadView)
					Button {
						removePrompt(conversationItem.id)
						// TO-DO: WE SHOULD NOT BE ABLE TO DO THIS. IF AIEXPLANATIONVIEW IS SHOWN, THIS BUTTON SHOULD BE DISABLED
						if chatViewManager.showAIExplanationView {
							chatViewManager.showAIExplanationView.toggle()
						}
					} label: {
						Image(systemName: "trash")
							.foregroundColor(.red)
					}
					if hasMoreThanTwoLines && !isAnimating {
						Button {
							promptViewManager.toggleIsExpanded()
						} label: {
							Text(promptViewManager.isExpanded ? "Collapse" : "Show more")
								.font(.footnote)
								.foregroundColor(.blue)
						}
					}
				}
				.disabled(chatViewManager.showAIExplanationView || conversationItem.outputStatus == .pending)
				
				if conversationItem.outputStatus == .completed {
					HStack(alignment: .top) {
						ZStack(alignment: .bottom) {
							TextEditor(text: .constant(displayedText))
								.frame(height: promptViewManager.isExpanded ? nil : 100)
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
									updateSelectionFrame(notification: notification)
								}
							if !promptViewManager.isExpanded {
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
						.disabled(!promptViewManager.isExpanded)
						if promptViewManager.showThreadView {
							VStack {
								Button {
									promptViewManager.toggleThreadView()
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
			.onChange(of: conversationItem.output) { oldValue, newValue in
				startAnimation()
				if let font  = NSFont(name: "Helvetica Neue", size: 16) {
					hasMoreThanTwoLines = countLines(in: newValue,
													 width: width - 40,
													 font: font) > 20
				}
			}
			if promptViewManager.showAIExplainButton &&
				chatViewManager.currentSelectedConversationItemId == conversationItem.id {
				AIExplainButton
			}
		}
	}
	
	private var AIExplainButton: some View {
		Button("Explain") {
			promptViewManager.setAIExplainButton(false)
			chatViewManager.showAIExplanationView = true
			disablePromptEntry = true
		}
		.padding(8)
		.background(.red)
		.foregroundColor(.white)
		.cornerRadius(8)
		.shadow(radius: 5)
		.position(x: selectionFrame.maxX, y: selectionFrame.maxY)
	}
	
	private func updateSelectionFrame(notification: Notification) {
		guard let textView = notification.object as? NSTextView,
			  let range = textView.selectedRanges.first as? NSRange,
			  range.length > 0 else {
			selectionFrame = .zero
			return
		}
		
		let glyphRange = textView.layoutManager?.glyphRange(forCharacterRange: range,
															actualCharacterRange: nil)
		if let glyphRange = glyphRange {
			let boundingRect = textView.layoutManager?.boundingRect(forGlyphRange: glyphRange,
																	in: textView.textContainer!)
			if let rect = boundingRect {
				selectionFrame = rect
			}
		}
	}
	
	private func startAnimation() {
		guard currentIndex == 0 else { return }
		disablePromptEntry = true
		isAnimating = true
		timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
			guard currentIndex < conversationItem.output.count else {
				timer.invalidate()
				isAnimating = false
				disablePromptEntry = false
				return
			}
			
			let index = conversationItem.output.index(conversationItem.output.startIndex, offsetBy: currentIndex)
			displayedText += String(conversationItem.output[index])
			currentIndex += 1
		}
	}
	
	private func stopAnimation() {
		timer?.invalidate()
		timer = nil
		displayedText = conversationItem.output
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
		guard textView.string == conversationItem.output else { return }
		
		textView.insertionPointColor = .clear
		let selectionRange = textView.selectedRange()
		
		guard selectionRange.length > 0 else {
			if !promptViewManager.highlightedText.isEmpty {
				promptViewManager.highlightedText = ""
				promptViewManager.setAIExplainButton(false)
			}
			return
		}

		DispatchQueue.main.async {
			if let substringRange = Range(selectionRange, in: conversationItem.output) {
				if chatViewManager.currentSelectedConversationItemId != conversationItem.id {
					// Clear previous selection
					chatViewManager.currentSelectedConversationItemId = conversationItem.id
					// This will trigger the onChange in all other cards
					promptViewManager.highlightedText = ""
					promptViewManager.setAIExplainButton(false)
				}
				// Set new selection
				promptViewManager.highlightedText = String(conversationItem.output[substringRange])
				promptViewManager.setAIExplainButton(true)
			}
		}
	}
}

#Preview {
	PromptView(conversationItem: ConversationItem.cards.first!, 
			   width: 20,
			   disablePromptEntry: .constant(false),
			   chatViewManager: ChatViewManager(),
			   removePrompt: { _ in })
}
