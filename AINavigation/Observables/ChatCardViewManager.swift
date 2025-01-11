//
//  ChatCardViewManager.swift
//  AINavigation
//
//  Created by Omar Torres on 1/11/25.
//


import Observation

@Observable
final class ChatCardViewManager {
	var showThreadView: Bool
	
	init(showThreadView: Bool = false) {
		self.showThreadView = showThreadView
	}
	
	func toggleThreadView() {
		showThreadView.toggle()
	}
}
