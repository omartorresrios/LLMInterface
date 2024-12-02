//
//  ChatViewModel.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import Foundation

struct ChatViewModel: Equatable, Identifiable {
	let id = UUID()
	var position: CGSize
	var cards: [Card]
	var branchOutDisabled: Bool = false
}
