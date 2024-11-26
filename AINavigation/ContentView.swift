//
//  ContentView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/17/24.
//

import SwiftUI

struct ContentView: View {
	@State private var chatIds: [UUID] = []
	@Environment(\.openWindow) private var openWindow
	var showHiddenChat: () -> Void
	
	var body: some View {
		VStack {
			Text("Main Window")
			Button("New Chat Window") {
				let newChatId = UUID()
				chatIds.append(newChatId)
				openWindow(id: "chat", value: newChatId)
				showHiddenChat()
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
	ContentView(showHiddenChat: {})
		.frame(width: 600, height: 400)
}
