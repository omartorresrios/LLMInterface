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
	var showDeepDiveView = false
	var showAIExplainPopupView = false
	var highlightedText = ""
	
	func toggleThreadView() {
		showThreadView.toggle()
	}
	
	func toggleIsExpanded() {
		isExpanded.toggle()
	}
	
	func setAIExplainPopup(_ newState: Bool) {
		showAIExplainPopupView = newState
	}
	
	func setDeepDiveView(_ newState: Bool) {
		showDeepDiveView = newState
	}
}
