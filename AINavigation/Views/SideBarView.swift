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
			Color(hex: "F8DEC8")
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
							.fontWeight(chatsManager.selectedChatContainerId == chatContainer.id ? .bold : .medium)
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
					// button stays? if so, we should disallow double click.
					Button(action: {
//						showEditModal.setValues(true,
//												chatContainer.name,
//												chatContainer.id)
					}) {
						Image(systemName: "pencil")
							.foregroundColor(.blue)
					}
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

extension Color {
	init?(hex: String) {
		var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

		var rgb: UInt64 = 0
		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 1.0

		let length = hexSanitized.count
		guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

		if length == 6 {
			r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
			g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
			b = CGFloat(rgb & 0x0000FF) / 255.0
		} else if length == 8 {
			r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
			g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
			b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
			a = CGFloat(rgb & 0x000000FF) / 255.0
		} else {
			return nil // Invalid hex format
		}

		self.init(red: r, green: g, blue: b, opacity: a)
	}
}
