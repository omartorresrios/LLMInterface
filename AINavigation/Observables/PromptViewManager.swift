//
//  PromptViewManager.swift
//  AINavigation
//
//  Created by Omar Torres on 1/11/25.
//

import Observation
import Foundation

@Observable
final class PromptViewManager {
	var showThreadView = false
	var isExpanded = true
	var showAIExplainButton = false
	var buttonPosition: CGPoint = .zero
	var highlightedText = ""
	
	func toggleThreadView() {
		showThreadView.toggle()
	}
	
	func toggleIsExpanded() {
		isExpanded.toggle()
	}
	
	func setAIExplainButton(_ newState: Bool) {
		showAIExplainButton = newState
	}
}
