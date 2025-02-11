//
//  AIExplainView.swift
//  AINavigation
//
//  Created by Omar Torres on 1/28/25.
//

import SwiftUI

struct AIExplainView: View {
	let subjectToExplainText: String
	let outputText: String
	let AIExplainItemIsPending: Bool
	let maxWidth: CGFloat
	let maxHeight: CGFloat
	var closeView: () -> Void
	@State private var isCloseButtonHovered = false
	
    var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Image(systemName: "xmark")
				.foregroundColor(buttonDefaultColor)
				.fontWeight(.semibold)
				.font(.system(size: 10))
				.frame(width: 20, height: 20)
				.background(
					Circle()
						.stroke(isCloseButtonHovered ? buttonColor : buttonBorderColor.opacity(0.7), lineWidth: 2)
				)
				.contentShape(Circle())
				.onHover { isHovering in
					isCloseButtonHovered = isHovering
				}
				.onTapGesture {
					closeView()
				}
			VStack(alignment: .leading) {
				Text("Explaining: \(subjectToExplainText)")
					.fontWeight(.bold)
				if AIExplainItemIsPending {
					ProgressView()
						.frame(maxWidth: .infinity,
							   maxHeight: .infinity,
							   alignment: .top)
				} else {
					let attributedString = try? AttributedString(markdown: outputText,
																 options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
					ScrollView {
						VStack {
							Text(attributedString ?? "")
						}
					}
				}
			}
			.frame(maxWidth: .infinity, 
				   maxHeight: .infinity,
				   alignment: .topLeading)
		}
		.padding()
		.frame(maxWidth: maxWidth, maxHeight: maxHeight)
		.background(Color(NSColor.windowBackgroundColor))
		.foregroundColor(Color(NSColor.labelColor))
		.cornerRadius(8)
		.shadow(radius: 5)
    }
}

#Preview {
	AIExplainView(subjectToExplainText: "",
				  outputText: "",
				  AIExplainItemIsPending: true,
				  maxWidth: 350,
				  maxHeight: 400,
				  closeView: { })
}
