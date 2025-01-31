//
//  ConversationItemViewManager.swift
//  AINavigation
//
//  Created by Omar Torres on 1/11/25.
//

import Observation
import Foundation

@Observable
final class ConversationItemViewManager {
	var isExpanded = true
	var showAIExplainButton = false
	var hasAnimatedOnce = false
	var buttonPosition: CGPoint = .zero
	var highlightedText = ""
	
	func toggleIsExpanded() {
		isExpanded.toggle()
	}
	
	func setAIExplainButton(_ newState: Bool) {
		showAIExplainButton = newState
	}
}
