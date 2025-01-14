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
		VStack(alignment: .leading) {
			Text("Selected text: \(chatCardViewManager.highlightedText)")
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
				if hasMoreThanTwoLines {
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
					if hasMoreThanTwoLines && chatCardViewManager.isExpanded {
						TextEditor(text: .constant(chat.output))
							.padding(.top, -3)
							.padding(.leading, -5)
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
					} else {
						let cleanedText = chat.output.replacingOccurrences(of: "[:;.]", with: "", options: .regularExpression)
						Text(cleanedText + (hasMoreThanTwoLines ? "\n" : ""))
							.font(.custom("Helvetica Neue", size: 16))
							.lineLimit(hasMoreThanTwoLines ? 2 : nil)
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
		.onChange(of: chat.output, { oldValue, newValue in
			hasMoreThanTwoLines = countLines(in: newValue) > 2
		})
		.onChange(of: chatCardViewManager.highlightedText) { _, newValue in
			if !newValue.isEmpty {
				chatViewManager.setHighlightedCard(chat.id)
				chatViewManager.setActiveAIExplainPopupViewId(chat.id)
			}
		}
		.onChange(of: chatViewManager.highlightedCardId) { _, newValue in
			if newValue != chat.id {
				clearHighlightAndDeepDive()
			}
		}
	}
	
	private func countLines(in string: String) -> Int {
			let lines = string.components(separatedBy: .newlines)
			return lines.reduce(0) { count, line in
				let words = line.split(separator: " ")
				let lineCount = words.count / 10 + (words.count % 10 > 0 ? 1 : 0)
				return count + max(1, lineCount)
			}
		}
	
	private func clearTextSelection(notification: Notification) {
		guard let textView = notification.object as? NSTextView else { return }
		textView.insertionPointColor = .clear
		textView.selectedRange = NSRange(location: 0, length: 0)
	}

	private func updateHighlightedText(notification: Notification) {
		guard let textView = notification.object as? NSTextView else { return }
		textView.insertionPointColor = .clear

		let selectionRange = textView.selectedRange()

		DispatchQueue.main.async {
			if selectionRange.length > 0 {
				let startIndex = String.Index(utf16Offset: selectionRange.lowerBound, in: chat.output)
				let endIndex = String.Index(utf16Offset: selectionRange.upperBound, in: chat.output)
				let substringRange = startIndex..<endIndex
				chatCardViewManager.highlightedText = String(chat.output[substringRange])
			} else {
				if !chatCardViewManager.highlightedText.isEmpty {
					chatCardViewManager.highlightedText = ""
				}
			}
		}
	}
	
	private func clearHighlightAndDeepDive() {
		chatCardViewManager.highlightedText = ""
		chatCardViewManager.setAIExplainPopup(false)
	}
}

#Preview {
	ChatCardView(chat: Chat.cards.first!, 
				 width: 20,
				 disablePromptEntry: .constant(false), 
				 chatViewManager: ChatViewManager(), 
				 removePrompt: { _ in })
}
