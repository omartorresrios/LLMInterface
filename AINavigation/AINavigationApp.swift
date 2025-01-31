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
		WindowGroup {
			ChatContainersView()
		}
		.windowToolbarStyle(.unified(showsTitle: false))
    }
}
