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

struct ContentHeightPreferenceKey: PreferenceKey {
	static var defaultValue: CGFloat = 0
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = max(value, nextValue())
	}
}

extension EnvironmentValues {
	var customWidths: [ViewSide: CGFloat] {
		get { self[WidthKey.self] }
		set { self[WidthKey.self] = newValue }
	}
}
