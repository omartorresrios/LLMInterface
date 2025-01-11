//
//  ChatsSidebarView.swift
//  AINavigation
//
//  Created by Omar Torres on 12/15/24.
//

import SwiftUI

struct ChatsSidebarView: View {
	@Bindable var chatContainersManager: ChatContainersManager
	@Binding var showEditModal: ShowEditModal // remove this if EditChatName is removed
	@State private var editingChatId: UUID?
	@State private var temporaryName: String = ""
	@FocusState private var isFocused: Bool
	@State private var forceRerender = false
	var body: some View {
		ZStack {
			Color(hex: "F8DEC8")
			List(chatContainersManager.chatViewManagers, id: \.id) { chatViewManager in
				HStack {
					if editingChatId == chatViewManager.id {
						TextField("Chat Name",
								  text: $temporaryName,
								  onCommit: {
							chatViewManager.setName(temporaryName)
							editingChatId = nil
						})
						.focused($isFocused)
						.onAppear {
							temporaryName = chatViewManager.name
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.textFieldStyle(.plain)
					} else {
						Text(chatViewManager.name)
							.fontWeight(chatContainersManager.selectedChatContainerId == chatViewManager.id ? .bold : .medium)
							.frame(maxWidth: .infinity, alignment: .leading)
							.contentShape(Rectangle())
							.simultaneousGesture(
								TapGesture(count: 2)
									.onEnded {
										DispatchQueue.main.async {
											isFocused = true
											editingChatId = chatViewManager.id
										}
									}
							)
							.simultaneousGesture(
								TapGesture()
									.onEnded {
										chatContainersManager.selectedChatContainerId = chatViewManager.id
									}
							)
						Button(action: {
							//						showEditModal.setValues(true,
							//												chatContainer.name,
							//												chatContainer.id)
						}) {
							Image(systemName: "pencil")
								.foregroundColor(.blue)
						}
					}
				}
				.contentShape(Rectangle())
				.listRowBackground(Color.clear)
			}
			.listStyle(.sidebar)
			.scrollContentBackground(.hidden)
			.toolbar {
				Button(action: {
					chatContainersManager.addChatContainer()
				}) {
					Label("Add Chat", systemImage: "plus")
				}
				.disabled(chatContainersManager.chatViewManagers.count > 2)
			}
		}
	}
}

#Preview {
	ChatsSidebarView(chatContainersManager: ChatContainersManager(), 
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
