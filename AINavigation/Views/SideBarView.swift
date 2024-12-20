//
//  SideBarView.swift
//  AINavigation
//
//  Created by Omar Torres on 12/15/24.
//

import SwiftUI

struct SidebarView: View {
	@Bindable var chatsManager: ChatsManager
	@Binding var showEditModal: ShowEditModal // remove this if EditChatName is removed
	@State private var editingChatId: UUID?
	@State private var temporaryName: String = ""
	@FocusState private var isFocused: Bool
	
	var body: some View {
		ZStack {
			Color.green.opacity(0.3)
			List(chatsManager.chatContainers, id: \.id) { chatContainer in
				HStack {
					if editingChatId == chatContainer.id {
						TextField("Chat Name", 
								  text: $temporaryName,
								  onCommit: {
							chatContainer.setName(temporaryName)
							editingChatId = nil
						})
						.focused($isFocused)
						 .onAppear {
							 temporaryName = chatContainer.name
						 }
						 .frame(maxWidth: .infinity, alignment: .leading)
						 .textFieldStyle(.plain)
					} else {
						Text(chatContainer.name)
							.frame(maxWidth: .infinity, alignment: .leading)
							.contentShape(Rectangle())
							.simultaneousGesture(
								TapGesture(count: 2)
									.onEnded {
										DispatchQueue.main.async {
											isFocused = true
											editingChatId = chatContainer.id
										}
									}
							)
							.simultaneousGesture(
								TapGesture()
									.onEnded {
										chatsManager.selectedChatContainerId = chatContainer.id
									}
							)
						}
//					Button(action: {
//						showEditModal.setValues(true,
//												chatContainer.name,
//												chatContainer.id)
//					}) {
//						Image(systemName: "pencil")
//							.foregroundColor(.blue)
//					}
				}
				.contentShape(Rectangle())
				.listRowBackground(Color.clear)
			}
			.listStyle(.sidebar)
			.scrollContentBackground(.hidden)
			.toolbar {
				Button(action: { chatsManager.addChatContainer() }) {
					Label("Add Chat", systemImage: "plus")
				}
				.disabled(chatsManager.chatContainers.count > 2)
			}
		}
	}
}

#Preview {
	SidebarView(chatsManager: ChatsManager(), 
				showEditModal: .constant(ShowEditModal(show: false,
													   currentChatName: "")))
}
