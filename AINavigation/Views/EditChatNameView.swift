//
//  EditChatNameView.swift
//  AINavigation
//
//  Created by Omar Torres on 12/20/24.
//

import SwiftUI

struct EditChatNameView: View {
	@Binding var chatName: String
	@Binding var isPresented: Bool
	var chatContainerWidth: CGFloat
	@FocusState private var isFocused: Bool
	
	var body: some View {
		VStack {
			Text("Edit Chat Name")
				.font(.headline)
				.padding()
			TextField("Chat Name", text: $chatName)
				.textFieldStyle(.plain)
				.focused($isFocused)
			
			HStack {
				Button("Cancel") {
					isPresented = false
				}
				.padding()
				
				Spacer()
				
				Button("Save") {
					isPresented = false
				}
				.padding()
			}
		}
		.padding()
		.cornerRadius(10)
		.shadow(radius: 10)
		.frame(width: chatContainerWidth * 0.5)
		.background(Color.green.opacity(0.2))
		.onAppear {
			isFocused = true
		}
	}
}

#Preview {
	EditChatNameView(chatName: .constant(""),
					 isPresented: .constant(true),
					 chatContainerWidth: 0)
}
