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
				} else {
					self.parent.selectedText = ""
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
	let card: Chat
	@Binding var width: CGFloat
	@Binding var disablePromptEntry: Bool
	@Bindable var chatSection: ChatSection
	@State private var isExpanded = false
	@State private var showDeepDiveView = false
	@State private var showThreadView = false
	@State private var showAIExplainPopupView = false
	@State private var highlightedText = ""
	@State private var selectableTextViewHeight: CGFloat = 0
	var onRemove: () -> Void
	var onBranchOut: () -> Void
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text(card.prompt)
					.font(.headline)
				Spacer()
				Button(action: {
					if !isExpanded {
						isExpanded = true
					}
					if showAIExplainPopupView {
						showAIExplainPopupView = false
					}
					onBranchOut()
					showThreadView = true
					highlightedText = ""
				}) {
					Image(systemName: "arrow.triangle.branch")
						.foregroundColor(.red)
				}
				.disabled(showThreadView)
				Button {
					onRemove()
					if showDeepDiveView {
						showDeepDiveView = false
					}
				} label: {
					Image(systemName: "trash")
						.foregroundColor(.red)
				}
				Button {
					isExpanded.toggle()
				} label: {
					Text(isExpanded ? "Collapse" : "Show more")
						.font(.footnote)
						.foregroundColor(.blue)
				}
			}
			.disabled(showDeepDiveView)
			if isExpanded {
				HStack {
					selectableTextView
					if showThreadView {
						VStack {
							Button {
								showThreadView.toggle()
							} label: {
								Image(systemName: "arrow.right")
							}
							Text("This is just a test of the pop up view.")
						}
					}
				}
			} else {
				VStack {
					Text(card.output)
						.font(.body)
						.lineLimit(2)
						.truncationMode(.tail)
				}
			}
		}
		.padding()
		.background(Color.gray.opacity(0.2))
		.cornerRadius(8)
		.onAppear {
			selectableTextViewHeight = calculateHeight(for: card.output, 
													   with: width)
		}
		.onChange(of: width) { _, newValue in
			selectableTextViewHeight = calculateHeight(for: card.output, 
													   with: newValue)
		}
		.onChange(of: highlightedText) { _, newValue in
			if !newValue.isEmpty {
				chatSection.setHighlightedCard(card.id)
				chatSection.setActiveAIExplainPopupViewId(card.id)
			}
		}
		.onChange(of: chatSection.highlightedCardId) { _, newValue in
			if newValue != card.id {
				clearHighlightAndDeepDive()
			}
		}
	}
	
	private var selectableTextView: some View {
		SelectableTextView(selectedText: $highlightedText,
						   showExplainPopup: $showAIExplainPopupView,
						   text: card.output,
						   onViewClick: { chatSection.clearAllSelections() })
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
							chatSection.activeAIExplainPopupViewId == card.id {
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
		let size = CGSize(width: width - 40, height: .greatestFiniteMagnitude)
		let boundingRect = (text as NSString).boundingRect(with: size,
														   options: [.usesLineFragmentOrigin, .usesFontLeading],
														   attributes: attributes,
														   context: nil)
		return ceil(boundingRect.height)
	}
}

#Preview {
	ChatCardView(card: Chat.cards.first!,
				 width: .constant(0),
				 disablePromptEntry: .constant(false),
				 chatSection: ChatSection(),
				 onRemove: { },
				 onBranchOut: { })
}
