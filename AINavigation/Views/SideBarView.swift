//
//  SideBarView.swift
//  AINavigation
//
//  Created by Omar Torres on 12/15/24.
//

import SwiftUI

struct SidebarView: View {
	@Bindable var chatsManager: ChatsManager
	
	var body: some View {
		List(chatsManager.chatContainers,
			 id: \.id,
			 selection: $chatsManager.selectedChatContainerId) { chatContainer in
			Text("\(chatContainer.id)")
		}
		.toolbar {
			Button(action: { chatsManager.addChatContainer() }) {
				Label("Add Chat", systemImage: "plus")
			}
			.disabled(chatsManager.chatContainers.count > 2)
		}
	}
}

#Preview {
	SidebarView(chatsManager: ChatsManager())
}