//
//  ChatCardView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct SelectableTextView: NSViewRepresentable {
	@Binding var selectedText: String
	@Binding var showExplainPopup: Bool
	let text: String
	var onViewClick: () -> Void

	func makeNSView(context: Context) -> ClickableTextView {
		let customFont = NSFont(name: "Helvetica Neue", size: 16)
		let textView = ClickableTextView()
		textView.string = text
		textView.font = customFont
		textView.isEditable = false
		textView.isSelectable = true
		textView.delegate = context.coordinator
		
		textView.backgroundColor = NSColor.clear
		textView.textColor = NSColor.textColor
		textView.insertionPointColor = .green
		textView.selectedTextAttributes = [
			.backgroundColor: NSColor.green.withAlphaComponent(0.3),
			.foregroundColor: NSColor.textColor
		]
		
		textView.setupClickGesture()
		textView.onViewClick = onViewClick
		return textView
	}

	func updateNSView(_ nsView: ClickableTextView, context: Context) {
		nsView.onViewClick = onViewClick
		nsView.textColor = NSColor.textColor
		nsView.selectedTextAttributes = [
			.backgroundColor: NSColor.green.withAlphaComponent(0.3),
			.foregroundColor: NSColor.textColor
		]
		if selectedText.isEmpty {
			nsView.setSelectedRange(NSRange(location: 0, length: 0))
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, NSTextViewDelegate {
		var parent: SelectableTextView

		init(_ parent: SelectableTextView) {
			self.parent = parent
		}

		func textViewDidChangeSelection(_ notification: Notification) {
			guard let textView = notification.object as? NSTextView else { return }
			let selectedRange = textView.selectedRange()

			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				if selectedRange.length > 0 {
					let selectedText = (textView.string as NSString).substring(with: selectedRange)
					self.parent.selectedText = selectedText
					self.parent.showExplainPopup = true
				} else if !self.parent.selectedText.isEmpty {
					self.parent.selectedText = ""
					self.parent.showExplainPopup = false
				}
			}
		}
	}
	
	final class ClickableTextView: NSTextView {
		var onViewClick: (() -> Void)?
		private var clickGestureRecognizer: NSClickGestureRecognizer?

		func setupClickGesture() {
			if clickGestureRecognizer == nil {
				clickGestureRecognizer = NSClickGestureRecognizer(target: self,
																  action: #selector(handleClick(_:)))
				clickGestureRecognizer?.numberOfClicksRequired = 1
				if let recognizer = clickGestureRecognizer {
					addGestureRecognizer(recognizer)
				}
			}
		}

		@objc private func handleClick(_ gestureRecognizer: NSClickGestureRecognizer) {
			if gestureRecognizer.state == .ended {
				onViewClick?()
			}
		}
	}
}

struct ChatCardView: View {
	let chat: Chat
	let width: CGFloat
	@Binding var disablePromptEntry: Bool
	@State var chatCardViewManager = ChatCardViewManager()
	@Bindable var chatViewManager: ChatViewManager
	@State private var showDeepDiveView = false
	@State private var showAIExplainPopupView = false
	@State private var highlightedText = ""
	@State private var isExpanded = false
	
	init(chat: Chat,
		 width: CGFloat,
		 disablePromptEntry: Binding<Bool>,
		 chatViewManager: ChatViewManager) {
		self.chat = chat
		self.width = width
		_disablePromptEntry = disablePromptEntry
		self.chatViewManager = chatViewManager
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(chat.prompt)
					.font(.headline)
				Button(action: {
					if showAIExplainPopupView {
						showAIExplainPopupView = false
					}
					chatCardViewManager.toggleThreadView()
					highlightedText = ""
				}) {
					Image(systemName: "arrow.triangle.branch")
						.foregroundColor(.red)
				}
				.disabled(chatCardViewManager.showThreadView)
				Button {
					chatViewManager.removeChat(at: Int(chat.id) ?? 0)
					if showDeepDiveView {
						showDeepDiveView = false
					}
				} label: {
					Image(systemName: "trash")
						.foregroundColor(.red)
				}
				Button {
					chatViewManager.toggleExpanded(chat.id)
					isExpanded.toggle()
				} label: {
					Text(chatViewManager.isExpanded(chat.id) ? "Collapse" : "Show more")
						.font(.footnote)
						.foregroundColor(.blue)
				}
			}
			.disabled(showDeepDiveView)
			HStack(alignment: .top) {
				selectableTextView
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
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding()
		.background(Color.gray.opacity(0.2))
		.cornerRadius(8)
		.onChange(of: highlightedText) { _, newValue in
			if !newValue.isEmpty {
				chatViewManager.setHighlightedCard(Int(chat.id) ?? 0)
				chatViewManager.setActiveAIExplainPopupViewId(Int(chat.id) ?? 0)
			}
		}
		.onChange(of: chatViewManager.highlightedCardId) { _, newValue in
			if newValue != Int(chat.id) ?? 0 {
				clearHighlightAndDeepDive()
			}
		}
	}
	
	private func truncatedOutput() -> String {
		if chat.output.count > 100 {
			return chat.output.prefix(100) + "..."
		}
		return chat.output
	}
	
	private var selectableTextView: some View {
		return SelectableTextView(selectedText: $highlightedText,
						   showExplainPopup: $showAIExplainPopupView,
						   text: chat.output,
						   onViewClick: { chatViewManager.clearAllSelections() })
		.frame(height: selectableTextViewHeight)
		.clipped()
		.overlay(
			Group {
				if showAIExplainPopupView && !highlightedText.isEmpty {
					VStack {
						Button("Explain") {
							showAIExplainPopupView = false
							showDeepDiveView = true
							disablePromptEntry = true
						}
						.padding()
						.background(.red)
						.cornerRadius(8)
						.shadow(radius: 5)
					}
					.position(x: 50, y: 50)
				} else if showDeepDiveView &&
							chatViewManager.activeAIExplainPopupViewId == Int(chat.id) ?? 0 {
					VStack {
						Text("This is a random explanation from the model.")
							.padding()
						Button("Close") {
							showDeepDiveView = false
							highlightedText = ""
							disablePromptEntry = false
						}
						.buttonStyle(.bordered)
					}
					.padding()
					.background(Color(NSColor.windowBackgroundColor))
					.foregroundColor(Color(NSColor.labelColor))
					.cornerRadius(8)
					.shadow(radius: 5)
				}
			}
		)
	}
	
	private func clearHighlightAndDeepDive() {
		highlightedText = ""
		showAIExplainPopupView = false
	}
	
	private func calculateHeight(for text: String,
								 with width: CGFloat) -> CGFloat {
		guard let customFont = NSFont(name: "Helvetica Neue", size: 16) else { return 0 }
		let attributes: [NSAttributedString.Key: Any] = [.font: customFont]
		let size = CGSize(width: width - 40, height: .greatestFiniteMagnitude) // Adjust for padding
		let boundingRect = (text as NSString).boundingRect(with: size,
														   options: [.usesLineFragmentOrigin, .usesFontLeading],
														   attributes: attributes,
														   context: nil)
		return ceil(boundingRect.height)
	}
	
	private var selectableTextViewHeight: CGFloat {
		calculateHeight(for: isExpanded ? chat.output : truncatedOutput(), with: width)
	}
}

#Preview {
	ChatCardView(chat: Chat.cards.first!, 
				 width: 20,
				 disablePromptEntry: .constant(false), 
				 chatViewManager: ChatViewManager())
}
