//
//  PromptInputView.swift
//  AINavigation
//
//  Created by Omar Torres on 1/26/25.
//

import SwiftUI

struct PromptInputView: View {
	@State private var prompt = ""
	var sendPrompt: (String) -> Void
	@FocusState var isFocused: Bool
	var disablePromptEntry: Bool
	var onTapGesture: (() -> Void)? = nil
	@Environment(\.colorScheme) var colorScheme
	let side: ViewSide
	let noItems: Bool
	
	private var textColor: Color {
		colorScheme == .dark ? textColorDark : textColorLight
	}
	
	private var inverseTextColor: Color {
		colorScheme == .dark ? textColorLight : textColorDark
	}
	
	private var clipShape: AnyShape {
		if side == .left {
			return noItems ? AnyShape(RoundedRectangle(cornerRadius: 8.0)) : AnyShape(RoundedCorners(topLeft: 8, topRight: 8))
		} else {
			return AnyShape(RoundedCorners(topLeft: 8, topRight: 8))
		}
	}
	
	private var overlay: some View {
		let shape: AnyShape = side == .left
			? (noItems ? AnyShape(RoundedRectangle(cornerRadius: 8)) : AnyShape(RoundedCorners(topLeft: 8, topRight: 8)))
			: AnyShape(RoundedCorners(topLeft: 8, topRight: 8))
		
		return shape.stroke(Color.gray, lineWidth: 0.5) // Apply stroke here
	}
	
	var body: some View {
		HStack {
			TextField("Enter your prompt", text: $prompt)
				.textFieldStyle(.plain)
				.font(normalFont)
				.onSubmit {
					if !prompt.isEmpty {
						sendPrompt(prompt)
						DispatchQueue.main.async {
							prompt = ""
						}
					}
				}
				.overlay(
					Color.clear
						.contentShape(Rectangle())
						.onTapGesture {
							isFocused = true
							if side == .left {
								onTapGesture?()
							}
						}
				)
				.focused($isFocused)
			
			Button(action: {
				sendPrompt(prompt)
				prompt = ""
			}) {
				Text("Send")
					.padding(.horizontal)
					.foregroundStyle(inverseTextColor)
					.font(normalFont)
					.padding(.vertical, 8)
					.background(buttonColor)
					.cornerRadius(8)
			}
			.buttonStyle(.plain)
			.disabled(prompt.isEmpty)
		}
		.padding()
		.background()
		.clipShape(clipShape)
		.overlay(overlay)
		.disabled(disablePromptEntry)
		.onAppear {
			DispatchQueue.main.async {
				isFocused = true
			}
		}
	}
}

struct RoundedCorners: Shape {
	var topLeft: CGFloat = 0
	var topRight: CGFloat = 0

	func path(in rect: CGRect) -> Path {
		var path = Path()

		let tl = min(topLeft, rect.height / 2)
		let tr = min(topRight, rect.height / 2)

		path.move(to: CGPoint(x: 0, y: rect.height)) // Bottom-left corner
		path.addLine(to: CGPoint(x: 0, y: tl)) // Left edge
		path.addArc(
			center: CGPoint(x: tl, y: tl),
			radius: tl,
			startAngle: .degrees(180),
			endAngle: .degrees(270),
			clockwise: false
		) // Top-left corner
		path.addLine(to: CGPoint(x: rect.width - tr, y: 0)) // Top edge
		path.addArc(
			center: CGPoint(x: rect.width - tr, y: tr),
			radius: tr,
			startAngle: .degrees(270),
			endAngle: .degrees(0),
			clockwise: false
		) // Top-right corner
		path.addLine(to: CGPoint(x: rect.width, y: rect.height)) // Right edge
		path.closeSubpath()

		return path
	}
}

#Preview {
	PromptInputView(sendPrompt: { _ in },
					disablePromptEntry: false,
					side: .right,
					noItems: false)
}
