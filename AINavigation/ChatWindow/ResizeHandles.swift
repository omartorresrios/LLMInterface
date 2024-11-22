//
//  ResizeHandles.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import SwiftUI

enum Edge {
case topLeft, topRight, bottomLeft, bottomRight
}

struct ResizeHandles: View {
   @Binding var size: CGSize
   
   var body: some View {
	   ZStack {
		   ResizeHandle { dx, dy in
			   size.width = max(400, size.width + dx)
			   size.height = max(300, size.height + dy)
		   }
		   .position(x: size.width - 10, y: size.height - 10) // Position at bottom right
		   
		   ResizeHandle { dx, dy in
			   size.width = max(400, size.width - dx)
			   size.height = max(300, size.height + dy)
		   }
		   .position(x: 10, y: size.height - 10) // Position at bottom left
		   
		   ResizeHandle { dx, dy in
			   size.width = max(400, size.width + dx)
			   size.height = max(300, size.height - dy)
		   }
		   .position(x: size.width - 10, y: 10) // Position at top right
		   
		   ResizeHandle { dx, dy in
			   size.width = max(400, size.width - dx)
			   size.height = max(300, size.height - dy)
		   }
		   .position(x: 10, y: 10) // Position at top left
	   }
   }
}

struct ResizeHandle: View {
   let onResize: (CGFloat, CGFloat) -> Void
   
   var body: some View {
	   Rectangle()
		   .fill(Color.blue.opacity(0.5))
		   .frame(width: 20, height: 20)
		   .gesture(
			   DragGesture(minimumDistance: 0)
				   .onChanged { value in
					   onResize(value.translation.width, value.translation.height)
				   }
		   )
   }
}

#Preview {
	ResizeHandles(size: .constant(.zero))
}
