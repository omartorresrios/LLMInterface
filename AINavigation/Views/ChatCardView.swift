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

	func makeNSView(context: Context) -> NSTextView {
		let customFont = NSFont(name: "Helvetica Neue", size: 14)
		let textView = NSTextView()
		textView.string = text
		textView.font = customFont
		textView.isEditable = false
		textView.isSelectable = true
		textView.delegate = context.coordinator
		
		// Configure text view for selection highlighting
		textView.backgroundColor = NSColor.clear
		
		// Customize selection attributes
		textView.insertionPointColor = .blue
		textView.selectedTextAttributes = [
			.backgroundColor: NSColor.blue.withAlphaComponent(0.3),
			.foregroundColor: NSColor.black
		]

		return textView
	}

	func updateNSView(_ nsView: NSTextView, context: Context) {
		nsView.string = text
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

			DispatchQueue.main.async {
				if selectedRange.length > 0 {
					let selectedText = (textView.string as NSString).substring(with: selectedRange)
					self.parent.selectedText = selectedText
				} else {
					self.parent.selectedText = ""
				}
			}
		}
	}
}


struct ChatCardView: View {
	let card: Chat
	@State var isExpanded: Bool = false
	var branchOutDisabled: Bool
	var onRemove: () -> Void
	var onBranchOut: () -> Void
	@Binding var width: CGFloat
	
	@State private var selectedText: String = ""
	@State private var textHeight: CGFloat = 0

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text(card.prompt)
					.font(.headline)
				Spacer()
				Button(action: onBranchOut) {
					Image(systemName: "arrow.triangle.branch")
						.foregroundColor(.red)
				}
				.disabled(branchOutDisabled)
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
			if isExpanded {
				SelectableTextView(text: card.output, 
								   selectedText: $selectedText)
					.frame(height: textHeight)
					.clipped()
					.background(.red)
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
			textHeight = calculateHeight(for: card.output, with: width)
		}
		.onChange(of: width) { _, newValue in
			textHeight = calculateHeight(for: card.output, with: newValue)
		}
	}
	
	private func calculateHeight(for text: String, 
								with width: CGFloat) -> CGFloat {
		let customFont = NSFont(name: "Helvetica Neue", size: 14)
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
				 isExpanded: false,
				 branchOutDisabled: false,
				 onRemove: { },
				 onBranchOut: { }, width: .constant(20))
}
