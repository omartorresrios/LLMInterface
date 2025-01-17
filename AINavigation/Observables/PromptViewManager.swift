//
//  PromptViewManager.swift
//  AINavigation
//
//  Created by Omar Torres on 1/11/25.
//


import Observation

@Observable
final class PromptViewManager {
	var showThreadView = false
	var isExpanded = true
	var showAIExplainButton = false
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
