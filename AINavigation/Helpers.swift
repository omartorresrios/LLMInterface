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

extension EnvironmentValues {
	var customWidths: [ViewSide: CGFloat] {
		get { self[WidthKey.self] }
		set { self[WidthKey.self] = newValue }
	}
}
