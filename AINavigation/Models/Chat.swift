//
//  Chat.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

struct Chat: Hashable {
	let id: Int
	var prompt: String = ""
	let output: String
	
	mutating func setQuestion(question: String) {
		self.prompt = question
	}
	
	static let cards = [Chat(id: 1,
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100)),
						Chat(id: 2,
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100)),
						Chat(id: 3,
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100)),
						Chat(id: 4,
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100)),
						Chat(id: 5,
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100)),
						Chat(id: 6,
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100)),
						Chat(id: 7,
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100)),
						Chat(id: 8,
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100)),
						Chat(id: 9,
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100)),
						Chat(id: 10,
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100))]
}
