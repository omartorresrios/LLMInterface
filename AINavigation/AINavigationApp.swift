//
//  AINavigationApp.swift
//  AINavigation
//
//  Created by Omar Torres on 11/17/24.
//

import SwiftUI

@main
struct AINavigationApp: App {
	@State private var hiddenChatId: UUID? = nil
	@State private var isHiddenChatVisible = false
	
    var body: some Scene {
        WindowGroup(id: "main") {
			ContentView(showHiddenChat: showHiddenChat)
        }
		
		WindowGroup(id: "chat", for: UUID.self) { $chatId in
			if let chatId = chatId {
				ChatWindowView(chatId: chatId)
			}
		}
		
		WindowGroup("HiddenChat") {
			if let hiddenChatId = hiddenChatId {
				ChatWindowView(chatId: hiddenChatId)
					.opacity(isHiddenChatVisible ? 1 : 0)
					.disabled(!isHiddenChatVisible)
					.onAppear {
						if isHiddenChatVisible {
							setFullScreenSize()
						}
					}
			}
		}
    }
	
	private func showHiddenChat() {
		if hiddenChatId == nil {
			hiddenChatId = UUID()
		}
		isHiddenChatVisible = true
		setFullScreenSize()
	}
	
	private func setFullScreenSize() {
		if let window = NSApplication.shared.windows.last {
			if let screen = NSScreen.main {
				window.setFrame(screen.visibleFrame, display: true, animate: false)
			}
		}
	}
}
