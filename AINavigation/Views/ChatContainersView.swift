//
//  ChatContainersView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI
import Observation

struct ChatContainersView: View {
	@State private var chatsManager = ChatsManager()
	
	var body: some View {
		GeometryReader { geometry in
			NavigationSplitView {
				SidebarView(chatsManager: chatsManager)
			} detail: {
				if let selectedChatId = chatsManager.selectedChatContainerId, 
					let chatContainer = chatsManager.chatContainers.first(where: { $0.id == selectedChatId })  {
					ChatView(chatContainer: chatContainer)
				} else {
					Text("Select a chat")
				}
			}
		}
	}
}

#Preview {
	ChatContainersView()
}
