//
//  PromptView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct TextEditor: NSViewRepresentable {
	var chatViewManager: ChatViewManager
	var promptViewManager: PromptViewManager
	let conversationItem: ConversationItem
	let text: String
	var width: CGFloat
	@Binding var height: CGFloat
	@Binding var textView: NSTextView?
	
	class Coordinator: NSObject, NSTextViewDelegate {
		var parent: TextEditor
		
		init(_ parent: TextEditor) {
			self.parent = parent
		}
		
		func textViewDidChangeSelection(_ notification: Notification) {
			guard let textView = notification.object as? NSTextView else { return }
			parent.chatViewManager.register(textView)
			DispatchQueue.main.async { [weak self] in
				self?.parent.textView = textView
			}
			let selectedRange = textView.selectedRange()
				
			if selectedRange.length > 0 {
				let selectedText = (textView.string as NSString).substring(with: selectedRange).trimmingCharacters(in: .whitespacesAndNewlines)
				guard !selectedText.isEmpty else {
					parent.promptViewManager.setAIExplainButton(false)
					return
				}
				
				parent.chatViewManager.clearSelections(except: textView)
				
				if let layoutManager = textView.layoutManager,
				   let textContainer = textView.textContainer {
					let glyphRange = layoutManager.glyphRange(forCharacterRange: selectedRange, actualCharacterRange: nil)
					let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
					let containerOrigin = textView.textContainerOrigin
					
					if parent.chatViewManager.currentSelectedConversationItemId != parent.conversationItem.id {
						parent.chatViewManager.currentSelectedConversationItemId = parent.conversationItem.id
					}
					DispatchQueue.main.async { [weak self] in
						self?.parent.promptViewManager.highlightedText = selectedText
						self?.parent.promptViewManager.setAIExplainButton(true)
						self?.parent.promptViewManager.buttonPosition = CGPoint(
							x: containerOrigin.x + boundingRect.maxX,
							y: containerOrigin.y + boundingRect.minY
						)
					}
				}
			} else {
				DispatchQueue.main.async { [weak self] in
					self?.parent.promptViewManager.highlightedText = ""
					self?.parent.promptViewManager.setAIExplainButton(false)
				}
			}
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	func makeNSView(context: Context) -> NSScrollView {
		let scrollView = NSScrollView()
		let textView = NSTextView()

		textView.isEditable = false
		textView.isSelectable = true
		textView.backgroundColor = .clear
		textView.drawsBackground = true
		textView.isRichText = true
		textView.font = .systemFont(ofSize: NSFont.systemFontSize)
		textView.textContainer?.lineFragmentPadding = 0
		textView.textContainer?.widthTracksTextView = true
		textView.isHorizontallyResizable = false
		textView.isVerticallyResizable = true
		textView.autoresizingMask = [.width]
		textView.delegate = context.coordinator
		scrollView.documentView = textView
		scrollView.hasVerticalScroller = false
		scrollView.verticalScrollElasticity = .none
		scrollView.hasHorizontalScroller = false
		scrollView.autohidesScrollers = true
		
		return scrollView
	}
	
	func updateNSView(_ scrollView: NSScrollView, context: Context) {
		guard let textView = scrollView.documentView as? NSTextView else { return }
		
		textView.textStorage?.setAttributedString(renderMarkdown(text))
		
		textView.frame.size.width = width
		scrollView.frame.size.width = width
		textView.layoutManager?.ensureLayout(for: textView.textContainer!)
		
		let totalHeight = textView.layoutManager?.usedRect(for: textView.textContainer!).height ?? 0
		let newHeight: CGFloat
		if promptViewManager.isExpanded {
			newHeight = totalHeight
		} else {
			newHeight = min(100, totalHeight)
		}

		DispatchQueue.main.async {
			self.height = newHeight
			scrollView.frame.size.height = newHeight
		}
	}
	
	private func renderMarkdown(_ markdown: String) -> NSAttributedString {
		let attributedString = NSMutableAttributedString(string: "")

		let lines = markdown.split(separator: "\n", omittingEmptySubsequences: false)
		for line in lines {
			if line.starts(with: "# ") {
				let headerText = String(line.dropFirst(2))
				let header = NSAttributedString(
					string: "\(headerText)\n",
					attributes: [
						.font: NSFont.systemFont(ofSize: 24, weight: .bold)
					]
				)
				attributedString.append(header)
			} else if line.starts(with: "## ") {
				let subHeaderText = String(line.dropFirst(3))
				let subHeader = NSAttributedString(
					string: "\(subHeaderText)\n",
					attributes: [
						.font: NSFont.systemFont(ofSize: 20, weight: .semibold)
					]
				)
				attributedString.append(subHeader)
			} else if line.starts(with: "- ") {
				let bulletPointText = String(line.dropFirst(2))
				let bulletPoint = NSAttributedString(
					string: "• \(bulletPointText)\n",
					attributes: [
						.font: NSFont.systemFont(ofSize: 14)
					]
				)
				attributedString.append(bulletPoint)
			} else {
				// Regular text
				let paragraph = applyBoldStyle(to: String(line))
				attributedString.append(paragraph)
				attributedString.append(NSAttributedString(string: "\n"))
			}
		}

		return attributedString
	}
	
	private func applyBoldStyle(to text: String) -> NSAttributedString {
		let attributedString = NSMutableAttributedString(string: text)

		// Regex pattern for bold (**text**)
		let boldPattern = "\\*\\*(.*?)\\*\\*"

		if let regex = try? NSRegularExpression(pattern: boldPattern) {
			let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
			for match in matches.reversed() {
				let fullRange = match.range // Full range, including ** **
				let capturedRange = match.range(at: 1) // Captured group range for the text inside ** **

				// Extract and style the bold text
				let boldText = (text as NSString).substring(with: capturedRange)
				let boldAttributedString = NSAttributedString(
					string: boldText,
					attributes: [.font: NSFont.boldSystemFont(ofSize: 14)]
				)

				// Replace the entire match range (including ** **) with the styled bold text
				attributedString.replaceCharacters(in: fullRange, with: boldAttributedString)
			}
		}
		return attributedString
	}
}

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
	@Binding var highlightedText: String
	@State private var textView: NSTextView?
	@State private var textEditorHeight: CGFloat = 0
	
	init(conversationItem: ConversationItem,
		 width: CGFloat,
		 disablePromptEntry: Binding<Bool>,
		 chatViewManager: ChatViewManager,
		 removePrompt: @escaping (String) -> Void,
		 highlightedText: Binding<String>) {
		self.conversationItem = conversationItem
		self.width = width
		_disablePromptEntry = disablePromptEntry
		self.chatViewManager = chatViewManager
		self.removePrompt = removePrompt
		_highlightedText = highlightedText
	}
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				HStack {
					Text(conversationItem.prompt)
						.font(.headline)
					Button(action: {
						promptViewManager.toggleThreadView()
					}) {
						Image(systemName: "arrow.triangle.branch")
							.foregroundColor(.red)
					}
					.disabled(promptViewManager.showThreadView)
					Button {
						removePrompt(conversationItem.id)
						if let textView = textView {
							chatViewManager.unregister(textView)
						}
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
							TextEditor(chatViewManager: chatViewManager,
									   promptViewManager: promptViewManager,
									   conversationItem: conversationItem,
									   text: displayedText,
									   width: width - 64,
									   height: $textEditorHeight,
									   textView: $textView)
							.frame(height: textEditorHeight)
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
			.onChange(of: promptViewManager.highlightedText) { _, newValue in
				highlightedText = newValue
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
			chatViewManager.prompt = promptViewManager.highlightedText
			chatViewManager.sendAIExplainPrompt()
			chatViewManager.showAIExplanationView = true
			disablePromptEntry = true
		}
		.padding(8)
		.background(.red)
		.foregroundColor(.white)
		.cornerRadius(8)
		.shadow(radius: 5)
		.position(promptViewManager.buttonPosition)
	}
	
	private func startAnimation() {
		disablePromptEntry = true
		guard !conversationItem.output.isEmpty,
			  currentIndex == 0 else { return }
		
		isAnimating = true
		timer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { timer in
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
}

#Preview {
	PromptView(conversationItem: ConversationItem.cards.first!, 
			   width: 20,
			   disablePromptEntry: .constant(false),
			   chatViewManager: ChatViewManager(),
			   removePrompt: { _ in },
			   highlightedText: .constant(""))
}
