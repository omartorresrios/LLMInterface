//
//  ChatCardView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct ChatCardView: View {
	let card: Chat
	var isExpanded: Bool
	var branchOutDisabled: Bool
	var onToggleExpand: () -> Void
	var onRemove: () -> Void
	var onBranchOut: () -> Void
	
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
			}
			
			VStack(alignment: .leading, spacing: 4) {
				if isExpanded {
					Text(card.output)
						.font(.body)
				} else {
					Text(card.output)
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

#Preview {
	ChatCardView(card: Chat.cards.first!,
				 isExpanded: false,
				 branchOutDisabled: false,
				 onToggleExpand: { },
				 onRemove: { },
				 onBranchOut: { })
}
