//
//  ChatContainersView.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI
import Observation

struct ShowEditModal {
	var show: Bool
	var currentChatName: String
	var editingChatId: UUID
	
	init(show: Bool = false, 
		 currentChatName: String = "",
		 editingChatId: UUID? = nil) {
		self.show = show
		self.currentChatName = currentChatName
		self.editingChatId = editingChatId ?? UUID()
	}
	
	mutating func setValues(_ show: Bool,
							_ currentChatName: String,
							_ editingChatId: UUID) {
		self.show = show
		self.currentChatName = currentChatName
		self.editingChatId = editingChatId
	}
}

struct ChatContainersView: View {
	@State private var chatContainersManager = ChatContainersManager()
	@State private var showEditModal = ShowEditModal()
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				HStack(spacing: 0) {
					ChatsSidebarView(chatContainersManager: chatContainersManager,
								showEditModal: $showEditModal)
						.frame(width: geometry.size.width * 0.2)
					Divider()
					if let chatViewManager = chatContainersManager.getSelectedChat() {
						ChatView(chatViewManager: chatViewManager)
						.searchable(text: chatViewManager.searchText, prompt: "Search in chat history")
					}
				}
				.background(Color(hex: "F9F2E2"))
				if showEditModal.show {
					Color.black.opacity(0.4)
						.edgesIgnoringSafeArea(.all)
					
					EditChatNameView(chatName: $showEditModal.currentChatName, 
									 isPresented: $showEditModal.show,
									 chatContainerWidth: geometry.size.width)
						.onDisappear {
							if let index = chatContainersManager.chatViewManagers.firstIndex(where: { $0.id == showEditModal.editingChatId }) {
								chatContainersManager.chatViewManagers[index].setName(showEditModal.currentChatName)
							}
						}
						.transition(.scale)
				}
			}
		}
	}
}

#Preview {
	ChatContainersView()
}
