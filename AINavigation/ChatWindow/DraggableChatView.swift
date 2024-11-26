//
//  DraggableChatView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct DraggableChatView: View {
	@Binding var position: CGSize
	@State var selectedQuestionIndex: Int?
	@Binding var cards: [Card]
	@State private var expandedCardIndices: Set<Int> = []
	@State private var dragOffset = CGSize.zero
	@State private var isSidebarVisible: Bool = true // add logic: if main height is less that screen
	@State private var prompt: String = ""
	@State private var currentCardIndex: Int = 0
	@Binding var size: CGSize
	@State private var isResizing: Bool = false
	@State private var isPromptCentered = true
	var onClose: () -> Void
	var onAddNewPrompt: () -> Void
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .topLeading) {
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.gray.opacity(0.2))
					.frame(width: size.width, height: size.height)
					.overlay(
						HStack(alignment: .top, spacing: 0) {
							if !cards.isEmpty {
								sidebarContent
									.frame(width: 200)
									.background(Color.gray.opacity(0.1))
							}
							mainContent
						}
					)
					.overlay(
						ResizeHandles(size: $size, isResizing: $isResizing)
					)
					.offset(x: position.width + dragOffset.width,
							y: position.height + dragOffset.height)
					.gesture(
						DragGesture()
							.onChanged { gesture in
								if !isResizing {
									let newPosition = CGSize(
										width: position.width + gesture.translation.width,
										height: position.height + gesture.translation.height
									)
									dragOffset = constrainDragOffset(for: newPosition, in: geometry.size)
								}
							}
							.onEnded { gesture in
								if !isResizing {
									let newPosition = CGSize(
										width: position.width + gesture.translation.width,
										height: position.height + gesture.translation.height
									)
									position = constrainPosition(newPosition, in: geometry.size)
									dragOffset = .zero
								}
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
	}
	
	private func constrainDragOffset(for newPosition: CGSize, in windowSize: CGSize) -> CGSize {
		let maxX = windowSize.width - size.width
		let maxY = windowSize.height - size.height
		
		return CGSize(
			width: min(max(newPosition.width - position.width, -position.width), maxX - position.width),
			height: min(max(newPosition.height - position.height, -position.height), maxY - position.height)
		)
	}
	
	private func constrainPosition(_ position: CGSize, in windowSize: CGSize) -> CGSize {
		let maxX = windowSize.width - size.width
		let maxY = windowSize.height - size.height
		
		return CGSize(
			width: min(max(position.width, 0), maxX),
			height: min(max(position.height, 0), maxY)
		)
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
	
	private func sendPrompt() {
		guard !prompt.isEmpty && currentCardIndex < Card.cards.count else { return }
		withAnimation(.easeInOut) {
			isPromptCentered = false
		}
		var newCard = Card.cards[currentCardIndex]
		newCard.setQuestion(question: prompt)
		cards.append(newCard)
		currentCardIndex += 1
		prompt = ""
	}
	
	private var mainContent: some View {
		GeometryReader { geometry in
			ScrollViewReader { scrollProxy in
				VStack(spacing: 10) {
					if cards.isEmpty && isPromptCentered {
						Spacer()
						promptInputView
						Spacer()
					} else {
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
										},
										onAddNewPrompt: {
											onAddNewPrompt()
										}
									)
									.transition(.opacity)
								}
								promptInputView
							}
							.padding()
							.animation(.default, value: cards)
						}
						.onChange(of: selectedQuestionIndex) { _, newIndex in
							if let newIndex = newIndex {
								withAnimation {
									scrollProxy.scrollTo(newIndex, anchor:.top)
								}
							}
						}
					}
				}
			}
		}
	}

	private var promptInputView: some View {
		HStack {
			TextField("Enter your prompt", text: $prompt)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding(.leading)
			Button(action: sendPrompt) {
				Text("Send")
					.padding(.horizontal)
					.padding(.vertical, 8)
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(8)
			}
			.padding(.trailing)
			.disabled(prompt.isEmpty || currentCardIndex >= Card.cards.count)
		}
	}
}

#Preview {
	DraggableChatView(position: .constant(.zero),
					  cards: .constant([]),
					  size: .constant(.zero), onClose: { },
					  onAddNewPrompt: { })
}
