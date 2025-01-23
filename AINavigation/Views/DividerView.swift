//
//  DividerView.swift
//  AINavigation
//
//  Created by Omar Torres on 1/23/25.
//

import SwiftUI

struct DividerView: View {
	var body: some View {
		Rectangle()
			.fill(Color.gray.opacity(0.5))
			.frame(width: 4)
			.onHover { hovering in
				if hovering {
					NSCursor.resizeLeftRight.push()
				} else {
					NSCursor.pop()
				}
			}
	}
}

#Preview {
    DividerView()
}
