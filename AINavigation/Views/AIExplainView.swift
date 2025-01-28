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
	
    var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Button {
				closeView()
			} label: {
				Image(systemName: "xmark.circle")
			}
			.buttonStyle(.plain)
			.font(.system(size: 16))
			VStack(alignment: .leading) {
				Text("Explaining: \(subjectToExplainText)")
					.fontWeight(.bold)
				if AIExplainItemIsPending {
					ProgressView()
						.frame(maxWidth: .infinity,
							   maxHeight: .infinity,
							   alignment: .top)
				} else {
					ScrollView {
						Text(outputText)
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
