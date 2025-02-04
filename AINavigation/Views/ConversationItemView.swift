//
//  ConversationItemView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct TextEditor: NSViewRepresentable {
	var chatViewManager: ChatViewManager
	var conversationItemViewManager: ConversationItemViewManager
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
					parent.conversationItemViewManager.setAIExplainButton(false)
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
						self?.parent.conversationItemViewManager.highlightedText = selectedText
						self?.parent.conversationItemViewManager.setAIExplainButton(true)
						self?.parent.conversationItemViewManager.buttonPosition = CGPoint(
							x: containerOrigin.x + boundingRect.maxX,
							y: containerOrigin.y + boundingRect.minY
						)
					}
				}
			} else {
				DispatchQueue.main.async { [weak self] in
					self?.parent.conversationItemViewManager.highlightedText = ""
					self?.parent.conversationItemViewManager.setAIExplainButton(false)
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
		textView.font = NSFont(name: "HelveticaNeue", size: 14) ?? .systemFont(ofSize: 14)
		textView.textContainer?.lineFragmentPadding = 0
		textView.textContainer?.widthTracksTextView = true
		textView.isHorizontallyResizable = false
		textView.isVerticallyResizable = true
		textView.autoresizingMask = [.width]
		textView.delegate = context.coordinator
		scrollView.documentView = textView
		scrollView.contentView.backgroundColor = .clear
		scrollView.drawsBackground = false
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
		if conversationItemViewManager.isExpanded {
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
						.font: NSFont(name: "HelveticaNeue-Bold", size: 24) ?? .systemFont(ofSize: 24, weight: .bold)
					]
				)
				attributedString.append(header)
			} else if line.starts(with: "## ") {
				let subHeaderText = String(line.dropFirst(3))
				let subHeader = NSAttributedString(
					string: "\(subHeaderText)\n",
					attributes: [
						.font: NSFont(name: "HelveticaNeue-Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .semibold)
					]
				)
				attributedString.append(subHeader)
			} else if line.starts(with: "- ") {
				let bulletPointText = String(line.dropFirst(2))
				let bulletPoint = NSAttributedString(
					string: "• \(bulletPointText)\n",
					attributes: [
						.font: NSFont(name: "HelveticaNeue", size: 14) ?? .systemFont(ofSize: 14)
					]
				)
				attributedString.append(bulletPoint)
			} else {
				// Regular text
				let paragraph = applyBoldStyle(to: String(line))
				attributedString.append(paragraph)
				attributedString.append(NSAttributedString(string: "\n", attributes: [
					.font: NSFont(name: "HelveticaNeue", size: 14) ?? .systemFont(ofSize: 14)]))
			}
		}

		return attributedString
	}
	
	private func applyBoldStyle(to text: String) -> NSAttributedString {
		let attributedString = NSMutableAttributedString(string: text, attributes: [
			.font: NSFont(name: "Helvetica Neue", size: 14) ?? .systemFont(ofSize: 14)])

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
					attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 14) ?? .boldSystemFont(ofSize: 14)]
				)

				// Replace the entire match range (including ** **) with the styled bold text
				attributedString.replaceCharacters(in: fullRange, with: boldAttributedString)
			}
		}
		return attributedString
	}
}

struct ConversationItemView: View {
	@Environment(\.customWidths) private var widths: [ViewSide: CGFloat]
	@Bindable var conversationItemManager: ConversationItemViewManager
	@Bindable var chatViewManager: ChatViewManager
	@Binding var highlightedText: String
	@Binding var disablePromptEntry: Bool
	@State private var hasMoreThanTwoLines = false
	@State private var displayedText = ""
	@State private var isAnimating = false
	@State private var currentIndex = 0
	@State private var timer: Timer?
	@State private var textView: NSTextView?
	@State private var textEditorHeight: CGFloat = 0
	@State var fullOutput = ""
	let conversationItem: ConversationItem
	var isThreadView: Bool
	var side: ViewSide
	var removePrompt: (String) -> Void
	var scrollToSelectedItem: (String) -> Void
	
	init(chatViewManager: ChatViewManager,
		 conversationItemManager: ConversationItemViewManager,
		 highlightedText: Binding<String>,
		 disablePromptEntry: Binding<Bool>,
		 conversationItem: ConversationItem,
		 isThreadView: Bool,
		 side: ViewSide,
		 removePrompt: @escaping (String) -> Void,
		 scrollToSelectedItem: @escaping (String) -> Void) {
		self.chatViewManager = chatViewManager
		self.conversationItemManager = conversationItemManager
		_highlightedText = highlightedText
		_disablePromptEntry = disablePromptEntry
		self.conversationItem = conversationItem
		self.isThreadView = isThreadView
		self.side = side
		self.removePrompt = removePrompt
		self.scrollToSelectedItem = scrollToSelectedItem
	}
	
	private var disableWhileActions: Bool {
		chatViewManager.showAIExplanationView ||
		conversationItem.outputStatus == .pending ||
		isAnimating
	}
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				topButtonsView
					.padding(.top)
				if conversationItem.outputStatus == .completed {
					textEditorView
				} else {
					ProgressView()
						.padding(.bottom)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal)
			.background(.green.opacity(0.3))
			.clipShape(RoundedRectangle(cornerRadius: 8.0))
			.onChange(of: conversationItem.output) { oldValue, newValue in
				if !conversationItemManager.hasAnimatedOnce {
					startAnimation()
					conversationItemManager.hasAnimatedOnce = true
				} else {
					displayedText = newValue
					currentIndex = newValue.count
				}
				if let font  = NSFont(name: "Helvetica Neue", size: 16) {
					hasMoreThanTwoLines = countLines(in: newValue,
													 width: (widths[side] ?? 0.0) - 40,
													 font: font) > 20
				}
			}
			.onChange(of: conversationItemManager.highlightedText) { _, newValue in
				highlightedText = newValue
			}
			if conversationItemManager.showAIExplainButton &&
				chatViewManager.currentSelectedConversationItemId == conversationItem.id {
				AIExplainButton
			}
		}
		.onAppear {
			setupKeyboardMonitor()
			if !conversationItem.output.isEmpty && conversationItemManager.hasAnimatedOnce {
				displayedText = conversationItem.output
				currentIndex = conversationItem.output.count
			}
			disablePromptEntry = disableWhileActions
		}
		.onChange(of: disableWhileActions) { _, newValue in
			disablePromptEntry = newValue
		}
		.onChange(of: isAnimating) { _, newValue in
			chatViewManager.conversationItemIsAnimating = newValue && hasMoreThanTwoLines
		}
	}
	
	func setupKeyboardMonitor() {
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
			if event.keyCode == 36 && isAnimating {
				stopAnimation()
			}
			return event
		}
	}

	private var topButtonsView: some View {
		HStack {
			Text(conversationItem.prompt)
				.font(.custom("HelveticaNeue", size: 18))
				.bold()
			if hasMoreThanTwoLines && !isAnimating {
				Button {
					conversationItemManager.toggleIsExpanded()
				} label: {
					Text(conversationItemManager.isExpanded ? "Collapse" : "Show more")
						.font(.footnote)
						.foregroundColor(.blue)
				}
			}
			Spacer()
			if !isThreadView {
				HStack(spacing: 4) {
					Image(systemName: "arrow.triangle.branch")
						.foregroundColor(.red)
					Text("\(chatViewManager.threadConversationsCount(conversationItem.id)) prompts")
						.font(.system(size: 12))
				}
				.padding(.horizontal, 6)
				.padding(.vertical, 2)
				.background(Color.blue.opacity(0.2))
				.cornerRadius(8)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(Color.blue, lineWidth: 1)
				)
				.onTapGesture {
					withAnimation(.easeInOut(duration: 0.3)) {
						chatViewManager.toggleThreadView()
						chatViewManager.currentOpenedConversationItemId = conversationItem.id
						chatViewManager.setThreadManager(for: conversationItem)
						scrollToSelectedItem(conversationItem.id)
					}
				}
				.disabled(chatViewManager.showThreadView)
				
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
			}
		}
		.disabled(disableWhileActions)
	}
	
	private var textEditorView: some View {
		ZStack(alignment: .bottom) {
			TextEditor(chatViewManager: chatViewManager,
					   conversationItemViewManager: conversationItemManager,
					   conversationItem: conversationItem,
					   text: displayedText,
					   width: (widths[side] ?? 0.0) - 64,
					   height: $textEditorHeight,
					   textView: $textView)
			.frame(height: textEditorHeight)
			if !conversationItemManager.isExpanded {
				LinearGradient(
					gradient: Gradient(colors: [
						Color(NSColor.windowBackgroundColor).opacity(0),
						Color(NSColor.windowBackgroundColor)
					]),
					startPoint: .top,
					endPoint: .bottom
				)
				.frame(height: 50)
				.allowsHitTesting(false)
			}
		}
		.disabled(!conversationItemManager.isExpanded)
	}
	
	private var AIExplainButton: some View {
		VStack {
			Button("Explain") {
				conversationItemManager.setAIExplainButton(false)
				chatViewManager.sendAIExplainPrompt(conversationItemManager.highlightedText)
				chatViewManager.showAIExplanationView = true
			}
			.foregroundColor(.white)
			Button("Open thread") {
				chatViewManager.toggleThreadView()
				chatViewManager.currentOpenedConversationItemId = conversationItem.id
				chatViewManager.setThreadManager(for: conversationItem)
				conversationItemManager.setAIExplainButton(false)
			}
			.foregroundColor(.white)
			
		}
		.padding(8)
		.background(.red)
		.cornerRadius(8)
		.shadow(radius: 5)
		.position(conversationItemManager.buttonPosition)
		.onAppear {
			startAnimation()
		}
	}
	
	private func startAnimation() {
		guard !conversationItem.output.isEmpty,
			  currentIndex == 0 else { return }
		
		fullOutput = conversationItem.output
		isAnimating = true
		displayedText = ""
		
		timer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { timer in
			guard currentIndex < fullOutput.count else {
				timer.invalidate()
				isAnimating = false
				return
			}
			let index = fullOutput.index(fullOutput.startIndex, offsetBy: currentIndex)
			displayedText += String(fullOutput[index])
			currentIndex += 1
		}
	}
	
	private func stopAnimation() {
		timer?.invalidate()
		timer = nil
		displayedText = fullOutput
		currentIndex = fullOutput.count
		isAnimating = false
		chatViewManager.conversationItemIsAnimating = false
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
	ConversationItemView(chatViewManager: ChatViewManager(), 
						 conversationItemManager: ConversationItemViewManager(),
						 highlightedText: .constant(""),
						 disablePromptEntry: .constant(false),
						 conversationItem: ConversationItem.items.first!,
						 isThreadView: false,
						 side: .left,
						 removePrompt: { _ in }, 
						 scrollToSelectedItem: { _ in })
}
