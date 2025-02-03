//
//  Helpers.swift
//  AINavigation
//
//  Created by Omar Torres on 1/25/25.
//

import SwiftUI

enum ViewSide: String {
	case left
	case right
}

struct WidthKey: EnvironmentKey {
	static let defaultValue: [ViewSide: CGFloat] = [:]
}

struct ChatsWidthKey: EnvironmentKey {
	static let defaultValue: CGFloat = 0.0
}

extension EnvironmentValues {
	var customWidths: [ViewSide: CGFloat] {
		get { self[WidthKey.self] }
		set { self[WidthKey.self] = newValue }
	}
	
	var chatsWidth: CGFloat {
		get { self[ChatsWidthKey.self] }
		set { self[ChatsWidthKey.self] = newValue }
	}
}
