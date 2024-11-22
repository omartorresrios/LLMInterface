//
//  Card.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

import Foundation

struct Card: Hashable {
	let id: Int
	var question: String = ""
	let response: String
	
	mutating func setQuestion(question: String) {
		self.question = question
	}
	
	static let cards = [Card(id: 1,
							 response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100)),
						Card(id: 2,
							 response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100)),
						Card(id: 3,
							 response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100)),
						Card(id: 4,
							 response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100)),
						Card(id: 5,
							 response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100)),
						Card(id: 6,
							 response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100)),
						Card(id: 7,
							 response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100)),
						Card(id: 8,
							 response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100)),
						Card(id: 9,
							 response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100)),
						Card(id: 10,
							 response: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100))]
}
