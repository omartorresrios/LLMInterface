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
	@State var branchOutDisabled: Bool
	@State private var expandedCardIndices: Set<Int> = []
	@State private var dragOffset = CGSize.zero
	@State private var prompt: String = ""
	@State private var currentCardIndex: Int = 0
	var onClose: () -> Void
	var onBranchOut: () -> Void
	
	var body: some View {
		ZStack(alignment: .topLeading) {
			RoundedRectangle(cornerRadius: 16)
				.fill(Color.gray.opacity(0.2))
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

			Button(action: onClose) {
				Image(systemName: "xmark.circle.fill")
					.resizable()
					.scaledToFit()
					.frame(width: 20, height: 20)
			}
			.buttonStyle(.plain)
			.padding(8)
		}
		.gesture(
			DragGesture()
				.onChanged { value in
					dragOffset = value.translation
				}
				.onEnded { value in
					withAnimation {
						position.width += value.translation.width
						position.height += value.translation.height
						dragOffset = CGSize.zero
					}
				}
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

	private var mainContent: some View {
		VStack(spacing: 10) {
			if cards.isEmpty {
				Spacer()
				promptInputView
				Spacer()
			} else {
				ScrollViewReader { scrollProxy in
					ScrollView {
						VStack(spacing: 10) {
							ForEach(cards.indices, id:\.self) { index in
								ChatCardView(
									card : cards[index],
									isExpanded : expandedCardIndices.contains(index),
									branchOutDisabled: branchOutDisabled,
									onToggleExpand: {
										if expandedCardIndices.contains(index) {
											expandedCardIndices.remove(index)
										} else {
											expandedCardIndices.insert(index)
										}
									},
									onRemove: {
										cards.remove(at: index)
										if let selectedIndex = selectedQuestionIndex,
										   selectedIndex >= index {
											selectedQuestionIndex = max(selectedIndex - 1, 0)
										}
									},
									onBranchOut: onBranchOut
								)
								.transition(.opacity)
							}
							promptInputView
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
	}

	private var promptInputView: some View {
		HStack {
			TextField("Enter your prompt", text: $prompt)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding(.leading)

			Button(action: sendPrompt){
				Text("Send")
					.padding(.horizontal)
					.padding(.vertical,8)
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(8)
			}
			.padding(.trailing).disabled(prompt.isEmpty || currentCardIndex >= Card.cards.count)
		}
	}

	private func sendPrompt(){
		guard !prompt.isEmpty && currentCardIndex < Card.cards.count else { return }
		
		var newCard = Card.cards[currentCardIndex]
		newCard.setQuestion(question: prompt)
		
		cards.append(newCard)
		currentCardIndex += 1
		prompt = ""
	}
}

#Preview {
	DraggableChatView(position: .constant(.zero),
					  cards: .constant([]),
					  branchOutDisabled: true,
					  onClose: { },
					  onBranchOut: { })
}
