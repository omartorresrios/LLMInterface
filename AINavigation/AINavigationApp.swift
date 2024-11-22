//
//  AINavigationApp.swift
//  AINavigation
//
//  Created by Omar Torres on 11/17/24.
//

import SwiftUI

@main
struct AINavigationApp: App {
    var body: some Scene {
        WindowGroup(id: "main") {
			ContentView()
        }
		
		WindowGroup(id: "chat", for: UUID.self) { $chatId in
			if let chatId = chatId {
				ChatWindowView(chatId: chatId)
			}
		}
    }
}
