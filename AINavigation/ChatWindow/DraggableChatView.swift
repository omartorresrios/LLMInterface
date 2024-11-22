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
	var onClose: () -> Void
	var onAddNewPrompt: () -> Void
	@State private var prompt: String = ""
	@State private var currentCardIndex: Int = 0
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
						if !cards.isEmpty {
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
	
	private func sendPrompt() {
		guard !prompt.isEmpty && currentCardIndex < Card.cards.count else { return }
		var newCard = Card.cards[currentCardIndex]
		newCard.setQuestion(question: prompt)
		cards.append(newCard)
		currentCardIndex += 1
		prompt = ""
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
							},
							onAddNewPrompt: {
								onAddNewPrompt()
							}
						)
						.id(index)
						.transition(.opacity)
					}
					
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
				.padding()
				.animation(.default, value: cards)
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

#Preview {
	DraggableChatView(position: .constant(.zero),
					  cards: .constant([]),
					  onClose: { },
					  onAddNewPrompt: { })
}
