//
//  ResizeHandles.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

struct ResizeHandles: View {
	@Binding var size: CGSize
	@Binding var isResizing: Bool
	@State private var startLocation: CGPoint?
	@State private var startSize: CGSize?
	
	var body: some View {
		ZStack {
			ResizeHandle(corner: .bottomRight, size: size) { location in
				if startLocation == nil {
					startLocation = location
					startSize = size
				}
				isResizing = true
				updateSize(location: location)
			} onEnded: {
				isResizing = false
				startLocation = nil
				startSize = nil
			}
		}
	}
	
	private func updateSize(location: CGPoint) {
		guard let startLocation = startLocation,
			  let startSize = startSize else { return }

		let dx = location.x - startLocation.x
		let dy = location.y - startLocation.y

		size.width = max(700, startSize.width + dx)
		size.height = max(400, startSize.height + dy)
	}
}

struct ResizeHandle: View {
	let corner: Corner
	let size: CGSize
	let onResize: (CGPoint) -> Void
	let onEnded: () -> Void

	var body: some View {
		Rectangle()
			.fill(Color.blue.opacity(0.3))
			.frame(width: 20, height: 20)
			.position(corner.position(in: size))
			.gesture(
				DragGesture(minimumDistance: 0)
					.onChanged { value in
						onResize(value.location)
					}
					.onEnded { _ in
						onEnded()
					}
			)
	}
}

enum Corner: CaseIterable {
	case bottomRight

	func position(in size: CGSize) -> CGPoint {
		CGPoint(x: size.width - 10, y: size.height - 10)
	}
}

#Preview {
	ResizeHandles(size: .constant(.zero), isResizing: .constant(false))
}
