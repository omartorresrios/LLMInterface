//
//  ChatCardView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct SelectableTextView: NSViewRepresentable {
	let text: String
	@Binding var selectedText: String
	@Binding var showExplainPopup: Bool

	func makeNSView(context: Context) -> NSTextView {
		let customFont = NSFont(name: "Helvetica Neue", size: 16)
		let textView = NSTextView()
		textView.string = text
		textView.font = customFont
		textView.isEditable = false
		textView.isSelectable = true
		textView.delegate = context.coordinator
		
		// Configure text view for selection highlighting
		textView.backgroundColor = NSColor.clear
		
		textView.textColor = NSColor.textColor
		
		// Customize selection attributes
		textView.insertionPointColor = .green
		textView.selectedTextAttributes = [
			.backgroundColor: NSColor.green.withAlphaComponent(0.3),
			.foregroundColor: NSColor.textColor
		]
		return textView
	}

	func updateNSView(_ nsView: NSTextView, context: Context) {
		nsView.textColor = NSColor.textColor
		nsView.selectedTextAttributes = [
			.backgroundColor: NSColor.green.withAlphaComponent(0.3),
			.foregroundColor: NSColor.textColor
		]
		if selectedText.isEmpty {
			nsView.setSelectedRange(NSRange(location: NSNotFound, length: 0))
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
}


struct ChatCardView: View {
	let card: Chat
	@Binding var width: CGFloat
	@Binding var disablePromptEntry: Bool
	@State private var isExpanded = false
	@State private var showDeepDiveView = false
	@State private var showThreadView = false
	@State private var showExplainPopup = false
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
					if showExplainPopup {
						showExplainPopup = false
					}
					onBranchOut()
					showThreadView = true
					highlightedText = ""
				}) {
					Image(systemName: "arrow.triangle.branch")
						.foregroundColor(.red)
				}
				.disabled(showThreadView)
				Button(action: onRemove) {
					Image(systemName: "trash")
						.foregroundColor(.red)
				}
				Button(action: {
					isExpanded.toggle()
				}) {
					Text(isExpanded ? "Collapse" : "Show more")
						.font(.footnote)
						.foregroundColor(.blue)
				}
			}
			.disabled(showDeepDiveView)
			if isExpanded {
				HStack {
					SelectableTextView(text: card.output,
									   selectedText: $highlightedText,
									   showExplainPopup: $showExplainPopup)
					.frame(height: selectableTextViewHeight)
					.clipped()
					.overlay(
						Group {
							if showExplainPopup && !highlightedText.isEmpty {
								VStack {
									Button("Explain") {
										showExplainPopup = false
										showDeepDiveView = true
										disablePromptEntry = true
									}
									.padding()
									.background(.red)
									.cornerRadius(8)
									.shadow(radius: 5)
								}
								.position(x: 50, y: 50)
							} else if showDeepDiveView {
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
				 onRemove: { },
				 onBranchOut: { })
}
