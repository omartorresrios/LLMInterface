//
//  ThreadView.swift
//  AINavigation
//
//  Created by Omar Torres on 1/25/25.
//

import SwiftUI

struct ThreadView: View {
	@State private var disablePromptEntry = false // We might not need this
	@State var highlightedText = ""
	@Bindable var chatViewManager: ChatViewManager
	
	init(chatViewManager: ChatViewManager) {
		self.chatViewManager = chatViewManager
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			Button {
				chatViewManager.toggleThreadView()
			} label: {
				Image(systemName: "arrow.right")
			}
			ConversationsScrollView(disablePromptEntry: $disablePromptEntry,
									highlightedText: $highlightedText,
									scrollViewProxy: .constant(nil),
									isThreadView: true,
									side: .right)
			.background(.blue.opacity(0.7))
		}
		.padding()
		.background(.yellow.opacity(0.7))
	}
}

#Preview {
	ThreadView(chatViewManager: ChatViewManager())
}
