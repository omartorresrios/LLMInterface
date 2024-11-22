//
//  ContentView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/17/24.
//

import SwiftUI

struct ChatViewModel: Identifiable {
	let id = UUID()
	var position: CGSize
	var cards: [Card]
}

enum Edge {
	case topLeft, topRight, bottomLeft, bottomRight
}

struct ResizeHandles: View {
	@Binding var size: CGSize
	
	var body: some View {
		ZStack {
			ResizeHandle { dx, dy in
				size.width = max(400, size.width + dx)
				size.height = max(300, size.height + dy)
			}
			.position(x: size.width - 10, y: size.height - 10) // Position at bottom right
			
			ResizeHandle { dx, dy in
				size.width = max(400, size.width - dx)
				size.height = max(300, size.height + dy)
			}
			.position(x: 10, y: size.height - 10) // Position at bottom left
			
			ResizeHandle { dx, dy in
				size.width = max(400, size.width + dx)
				size.height = max(300, size.height - dy)
			}
			.position(x: size.width - 10, y: 10) // Position at top right
			
			ResizeHandle { dx, dy in
				size.width = max(400, size.width - dx)
				size.height = max(300, size.height - dy)
			}
			.position(x: 10, y: 10) // Position at top left
		}
	}
}

struct ResizeHandle: View {
	let onResize: (CGFloat, CGFloat) -> Void
	
	var body: some View {
		Rectangle()
			.fill(Color.blue.opacity(0.5))
			.frame(width: 20, height: 20)
			.gesture(
				DragGesture(minimumDistance: 0)
					.onChanged { value in
						onResize(value.translation.width, value.translation.height)
					}
			)
	}
}

struct DraggableChatView: View {
	@Binding var position: CGSize
	@State var selectedQuestionIndex: Int?
	@Binding var cards: [Card]
	@State private var expandedCardIndices: Set<Int> = []
	@State private var dragOffset = CGSize.zero
	@State private var isSidebarVisible: Bool = true
	var onClose: () -> Void
	
	@State private var size: CGSize = CGSize(width: 800, height: 600)
	
	private var screenHeight: CGFloat {
		NSScreen.main?.frame.height ?? 1000
	}
	
	private var maxBoxHeight: CGFloat {
		screenHeight * 0.8
	}

	var body: some View {
		ZStack(alignment: .topLeading) {
			RoundedRectangle(cornerRadius: 16)
				.fill(Color.gray.opacity(0.2))
				.frame(width: size.width, height: min(size.height, maxBoxHeight))
				.overlay(
					HStack(alignment: .top, spacing: 0) {
						if isSidebarVisible {
							sidebarContent
								.frame(width: 200)
								.background(Color.gray.opacity(0.1))
						}
						mainContent
					}
				)
				.overlay(
				   ResizeHandles(size: $size)
			   )
				.offset(x: position.width + dragOffset.width,
						y: position.height + dragOffset.height)
				.gesture(
					DragGesture()
						.onChanged { gesture in
							dragOffset = gesture.translation
						}
						.onEnded { gesture in
							position.width += gesture.translation.width
							position.height += gesture.translation.height
							dragOffset = .zero
						}
				)
			
			Button {
				onClose()
			} label: {
				Image(systemName: "xmark.circle.fill")
					.resizable()
					.scaledToFit()
					.frame(width: 20, height: 20)
			}
			.buttonStyle(.plain)
			.padding(8)
			.offset(x: position.width + dragOffset.width,
					y: position.height + dragOffset.height)
		}
	}
	
	private var sidebarContent: some View {
		VStack(alignment: .leading) {
			Text("Indexed Questions")
				.font(.headline)
				.padding()
			Divider()
			ForEach(cards.indices, id: \.self) { index in
				Button(action: {
					selectedQuestionIndex = index
				}) {
					Text(cards[index].question)
					.foregroundColor(selectedQuestionIndex == index ? .blue : .primary)
				}
				.padding(.vertical, 4)
			}
		}
		.padding()
	}
	
	private var mainContent: some View {
		ScrollViewReader { scrollProxy in
			ScrollView {
				VStack(spacing: 10) {
					ForEach(cards.indices, id: \.self) { index in
						ChatCardView(
							card: cards[index],
							isExpanded: expandedCardIndices.contains(index),
							onToggleExpand: {
								if expandedCardIndices.contains(index) {
									expandedCardIndices.remove(index)
								} else {
									expandedCardIndices.insert(index)
								}
							},
							onRemove: {
								cards.remove(at: index)
								if let selectedIndex = selectedQuestionIndex, selectedIndex >= index {
									selectedQuestionIndex = max(selectedIndex - 1, 0)
								}
							}
						)
						.id(index)
					}
				}
				.padding()
			}
			.onChange(of: selectedQuestionIndex) { _, newIndex in
				if let newIndex = newIndex {
					withAnimation {
						scrollProxy.scrollTo(newIndex, anchor: .top)
					}
				}
			}
		}
	}
}

struct ContentView: View {
	@State private var chatIds: [UUID] = []
	@Environment(\.openWindow) private var openWindow
		
	var body: some View {
		VStack {
			Text("Main Window")
			Button("New Chat Window") {
				let newChatId = UUID()
				chatIds.append(newChatId)
				openWindow(id: "chat", value: newChatId)
			}
		}
	}
}

//struct MainAreaView: View {
//	@State private var expandedCardIndices: Set<Int> = []
//	@Binding var selectedQuestion: Card?
//	@Binding var isSidebarVisible: Bool
//	@Binding var cards: [Card]
//	
//	var body: some View {
//		ScrollViewReader { scrollProxy in
//			ScrollView {
//				VStack(spacing: 10) {
//					ForEach(cards.indices, id: \.self) { index in
//						ChatCardView(
//							card: cards[index],
//							isExpanded: expandedCardIndices.contains(index),
//							onToggleExpand: {
//								if expandedCardIndices.contains(index) {
//									expandedCardIndices.remove(index)
//								} else {
//									expandedCardIndices.insert(index)
//								}
//							},
//							onRemove: {
//								cards.remove(at: index)
//							}
//						)
//					}
//				}
//				.padding()
//				.background(GeometryReader { innerGeometry in
//					Color.clear
//						.onAppear {
//							updateSidebarVisibility(withHeight: innerGeometry.size.height)
//						}
//						.onChange(of: innerGeometry.size.height) { _, newHeight in
//							updateSidebarVisibility(withHeight: newHeight)
//						}
//				})
//				.onChange(of: selectedQuestion) { _, newIndex in
//					if let newIndex = newIndex {
//						withAnimation {
//							scrollProxy.scrollTo(newIndex, anchor: .top)
//						}
//					}
//				}
//			}
//		}
//	}
//	
//	private func updateSidebarVisibility(withHeight height: CGFloat) {
//		if let screenHeight = NSScreen.main?.frame.height {
//			isSidebarVisible = height > screenHeight
//		}
//	}
//}

struct Card: Hashable {
	let id: Int
	let question: String
	let response: String
	
	static let cards = [Card(id: 1,
										 question: "What is SwiftUI?",
					   response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
					   String(repeating: "This is a long response. ", count: 100)),
				  Card(id: 2,
					   question: "Other title that nobody cares",
					   response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
					   String(repeating: "This is a long response. ", count: 100)),
				  Card(id: 3,
					   question: "This could be something else",
					   response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
					   String(repeating: "This is a long response. ", count: 100)),
				  Card(id: 4,
					   question: "And also the beginnings of the same things",
					   response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
					   String(repeating: "This is a long response. ", count: 100)),
				  Card(id: 5,
					   question: "The batteries that are rechargeable",
					   response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
					   String(repeating: "This is a long response. ", count: 100)),
				  Card(id: 6,
					   question: "Title 6",
					   response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
									String(repeating: "This is a long response. ", count: 100)),
				  Card(id: 7,
					   question: "Title 7",
					   response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
									String(repeating: "This is a long response. ", count: 100)),
				  Card(id: 8,
					   question: "Title 8",
					   response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
									String(repeating: "This is a long response. ", count: 100)),
				  Card(id: 9,
					   question: "Title 9",
					   response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
									String(repeating: "This is a long response. ", count: 100)),
				  Card(id: 10,
					   question: "Title 10",
					   response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
									String(repeating: "This is a long response. ", count: 100))]
}

struct ChatCardView: View {
	let card: Card
	var isExpanded: Bool
	var onToggleExpand: () -> Void
	var onRemove: () -> Void
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text(card.question)
					.font(.headline)
				Spacer()
				Button(action: onRemove) {
					Image(systemName: "trash")
						.foregroundColor(.red)
				}
			}
			
			VStack(alignment: .leading, spacing: 4) {
				if isExpanded {
					Text(card.response)
						.font(.body)
				} else {
					Text(card.response)
						.font(.body)
						.lineLimit(2)
						.truncationMode(.tail)
				}
				Button(action: onToggleExpand) {
					Text(isExpanded ? "Collapse" : "Show more")
						.font(.footnote)
						.foregroundColor(.blue)
				}
			}
		}
		.padding()
		.background(Color.gray.opacity(0.2))
		.cornerRadius(8)
	}
}
//struct ContentView: View {
//	@State private var prompt: String = ""
//	@State private var conversations: [Conversation] = []
//	@State private var isResponding = false
//	@State private var currentResponse: String = ""
//	@State private var timer: Timer?
//	@State private var currentPrompt: String = ""
//		
//	var body: some View {
//		VStack {
//			Text("Chat Simulation")
//				.font(.title2)
//				.fontWeight(.semibold)
//				.padding()
//				.frame(maxWidth: .infinity)
//				.background(Color.blue.opacity(0.2))
//			
//			HStack {
//				TextField("Enter your prompt", text: $prompt)
//					.textFieldStyle(RoundedBorderTextFieldStyle())
//					.padding(.leading)
//				Button(action: sendPrompt) {
//					Text("Send")
//						.padding(.horizontal)
//						.padding(.vertical, 8)
//						.background(Color.blue)
//						.foregroundColor(.white)
//						.cornerRadius(8)
//				}
//				.padding(.trailing)
//			}
//			.padding(.vertical)
//			
//			ScrollView {
//				VStack(spacing: 0) {
//					ForEach(conversations) { conversation in
//						VStack(alignment: .leading, spacing: 0) {
//							// Prompt Header (not scrollable)
//							Text("You: \(conversation.prompt)")
//								.padding()
//								.frame(maxWidth: .infinity, alignment: .leading)
//								.background(Color.gray.opacity(0.1))
//							
//							// Responses (scrollable)
//							ScrollView {
//								VStack(alignment: .leading, spacing: 16) {
//									ForEach(conversation.responses, id: \.self) { response in
//										ChatBubbleView(text: response)
//									}
//								}
//								.padding()
//							}
//							.frame(height: 150)
//						}
//						.background(Color.white)
//						.cornerRadius(12)
//						.shadow(radius: 2)
//						.padding(.vertical, 8)
//					}
//					
//					if isResponding {
//						VStack(alignment: .leading, spacing: 0) {
//							Text("You: \(prompt)")
//								.padding()
//								.frame(maxWidth: .infinity, alignment: .leading)
//								.background(Color.gray.opacity(0.1))
//							
//							ChatBubbleView(text: currentResponse)
//								.padding()
//						}
//						.background(Color.white)
//						.cornerRadius(12)
//						.shadow(radius: 2)
//						.padding(.vertical, 8)
//					}
//				}
//				.padding()
//			}
//		}
//		.frame(width: 600, height: 400)
//	}
//		
//	private func sendPrompt() {
//		guard !prompt.isEmpty else { return }
//		isResponding = true
//		currentResponse = ""
//		startResponding()
//	}
//	
//	private func startResponding() {
//		let fullResponse = "This is a simulated response. It is being delivered in chunks to mimic how ChatGPT responds. Hope this helps!This is a simulated response. It is being delivered in chunks to mimic how ChatGPT responds. Hope this helps!This is a simulated response. It is being delivered in chunks to mimic how ChatGPT responds. Hope this helps!This is a simulated response. It is being delivered in chunks to mimic how ChatGPT responds. Hope this helps!This is a simulated response. It is being delivered in chunks to mimic how ChatGPT responds. Hope this helps!This is a simulated response. It is being delivered in chunks to mimic how ChatGPT responds. Hope this helps!This is a simulated response. It is being delivered in chunks to mimic how ChatGPT responds. Hope this helps!"
//		let chunks = fullResponse.split(separator: " ").map(String.init)
//		
//		var chunkIndex = 0
//		timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
//			if chunkIndex < chunks.count {
//				currentResponse += (chunkIndex == 0 ? "" : " ") + chunks[chunkIndex]
//				chunkIndex += 1
//			} else {
//				isResponding = false
//				conversations.append(Conversation(prompt: prompt, responses: [currentResponse]))
//				prompt = ""
//				currentResponse = ""
//				timer.invalidate()
//			}
//		}
//	}
//}
//
//struct ChatBubbleView: View {
//	let text: String
//	
//	var body: some View {
//		HStack {
//			Text(text)
//				.padding()
//				.background(Color.blue.opacity(0.1))
//				.cornerRadius(8)
//			Spacer()
//		}
//	}
//}
//
//struct Conversation: Identifiable {
//	let id = UUID()
//	let prompt: String
//	var responses: [String]
//}
//import SwiftUI
//
//struct DraggableBox: Identifiable {
//	let id = UUID()
//	var title: String
//	var body: String
//	var position: CGSize
//}
////DraggableBox(title: "Box 1",
////			 body: "this is the potential body of this box. I will add something else here but ok so far.",
////			 position: .zero),
////DraggableBox(title: "Box 2",
////			 body: "this is the potential body of this box. I will add something else here but ok so far.",
////			 position: .zero)
//struct ContentView: View {
//	@State private var boxes: [DraggableBox] = [
//		DraggableBox(title: "Box 2",
//					 body: "this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.this is the potential body of this box. I will add something else here but ok so far.",
//					 position: .zero)
//	]
//	@State private var inputText: String = ""
//	let openAIChatCompletionsURL = "https://api.perplexity.ai/chat/completions"
//	let model = "llama-3.1-sonar-small-128k-online"
//	@State var showBoxes = false
//	
//	var body: some View {
//		Button(action: addNewBox) {
//			Text("Add Box")
//				.padding()
//				.background(Color.green)
//				.foregroundColor(.white)
//				.cornerRadius(8)
//		}
//		.padding()
//		ZStack(alignment: .topTrailing) {
//			if showBoxes {
//				boxesView
//			} else {
//				entryPrompt
//			}
//		}
//	}
//	
//	private var boxesView: some View {
//		ZStack {
//			ForEach(boxes.indices, id: \.self) { index in
//				DraggableBoxView(box: $boxes[index], onRemove: { removeBox(at: index) })
//			}
//		}
//		.padding()
//		.frame(maxWidth: .infinity, maxHeight: .infinity)
//		.background(Color.gray.opacity(0.2))
//
//	}
//	
//	private var entryPrompt: some View {
//		VStack {
//			TextField("Enter text here", text: $inputText)
//				.textFieldStyle(RoundedBorderTextFieldStyle()) // This gives it a border
//				.frame(width: NSScreen.main?.frame.width ?? 600 * 0.75)
//				.padding()
//			Button {
//				let box = DraggableBox(title: "Box 1", body: inputText, position: .zero)
//				boxes.append(box)
//				showBoxes = true
////				Task {
////					let chatCompletion = try await makeCompletion(with: inputText)
////					print("chatCompletion: ", chatCompletion)
////				}
//			} label: {
//				Image(systemName: "circle")
//					.resizable()
//					.frame(width: 20, height: 20)
//					.foregroundStyle(.black)
//			}
//		}
//		.frame(width: 300, height: 100)
//	}
//	
//	private func makeCompletion(with prompt: String) async throws -> ChatCompletion {
//		guard let url = URL(string: openAIChatCompletionsURL) else { throw Error.invalidURL }
//		let key = "key"
//		var request = URLRequest(url: url)
//		let messages: [String: String] = ["role": "user", "content": prompt]
//		let json: [String: Any] = ["model": model, "messages": messages]
//		let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
//		request.httpBody = jsonData
//		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//		request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
//		request.httpMethod = "POST"
//		
//		let (data, response) = try await URLSession.shared.data(for: request)
//		if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//			if statusCode == 401 {
//				throw ChatCompletionError.unauthorized
//			} else if statusCode == 500 {
//				throw ChatCompletionError.serverError
//			} else if statusCode == 401 {
//				throw ChatCompletionError.authentication
//			}
//		}
//		let decoder = JSONDecoder()
//		decoder.keyDecodingStrategy = .convertFromSnakeCase
//		let textCompletion = try JSONDecoder().decode(ChatCompletion.self, from: data)
//		return textCompletion
//	}
//	
//	private func addNewBox() {
//		let newBox = DraggableBox(title: "New Box \(boxes.count + 1)",
//								  body: "this is the potential body of this box. I will add something else here but ok so far.", 
//								  position: .zero)
//		boxes.append(newBox)
//	}
//
//	private func removeBox(at index: Int) {
//		boxes.remove(at: index)
//	}
//}
//
//enum ChatCompletionError: Swift.Error {
//	case unauthorized
//	case serverError
//	case authentication
//}
//
//
//enum Error: Swift.Error {
//	case invalidURL
//	case invalidData
//}
//
//struct Message: Decodable {
//	let role: String
//	let content: String
//}
//
//struct Delta: Decodable {
//	let role: String
//	let content: String
//}
//
//struct Choice: Decodable {
//	let index: Int
//	let finishReason: String
//	let message: Message
//	let delta: Delta
//}
//
//struct Usage: Decodable {
//	let promptTokens: Int
//	let completionTokens: Int
//	let totalTokens: Int
//}
//
//struct ChatCompletion: Decodable {
//	let id: String
//	let model: String
//	let object: String
//	let created: Date
//	let choices: [Choice]
//	let usage: Usage
//}
//
//// View for each draggable box
//struct DraggableBoxView: View {
//	@Binding var box: DraggableBox
//	var onRemove: () -> Void
//	@State private var dragOffset = CGSize.zero
//	@State private var contentHeight: CGFloat = 100
//	private var screenHeight: CGFloat {
//		NSScreen.main?.frame.height ?? 1000
//	}
//	
//	private var maxBoxHeight: CGFloat {
//			screenHeight * 0.8 // Limit to 80% of screen height, adjust as needed
//		}
//
//	var body: some View {
//		ZStack(alignment: .topTrailing) {
//			RoundedRectangle(cornerRadius: 16)
//				.fill(Color.gray.opacity(0.2))
//				.frame(width: 200, height: min(contentHeight, maxBoxHeight))
//				.overlay(
//					VStack(alignment: .leading, spacing: 5) {
//						Text(box.title)
//							.font(.headline)
//							.foregroundColor(.black)
//						ScrollView {
//							Text(box.body)
//								.fixedSize(horizontal: false, vertical: true)
//								.padding(.horizontal)
//						}
//						
//					}
//					.padding()
//				)
//				.offset(x: box.position.width + dragOffset.width,
//						y: box.position.height + dragOffset.height)
//				.gesture(
//					DragGesture()
//						.onChanged { gesture in
//							dragOffset = gesture.translation
//						}
//						.onEnded { gesture in
//							box.position.width += gesture.translation.width
//							box.position.height += gesture.translation.height
//							dragOffset = .zero
//						}
//				)
//
//			Button(action: onRemove, label: {
//				Image(systemName: "xmark")
//					.resizable()
//					.scaledToFit()
//					.frame(width: 8, height: 8)
//			})
//			.buttonBorderShape(.circle)
//			.offset(x: (box.position.width + dragOffset.width),
//					y: (box.position.height + dragOffset.height))
//		}
//	}
//}

#Preview {
	ContentView()
		.frame(width: 600, height: 400)
}
