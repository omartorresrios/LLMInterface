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
	
	mutating func setPrompt(_ prompt: String) {
		self.prompt = prompt
	}
	
	static let cards = [Chat(id: 1,
							 output: "So if on advanced addition absolute received replying throwing he. Delighted consisted newspaper of unfeeling as neglected so. Tell size come hard mrs and four fond are. Of in commanded earnestly resources it. At quitting in strictly up wandered of relation answered felicity. Side need at in what dear ever upon if. Same down want joy neat ask pain help she. Alone three stuff use law walls fat asked. Near do that he help. Adieus except say barton put feebly favour him. Entreaties unpleasant sufficient few pianoforte discovered uncommonly ask. Morning cousins amongst in mr weather do neither. Warmth object matter course active law spring six. Pursuit showing tedious unknown winding see had man add. And park eyes too more him. Simple excuse active had son wholly coming number add. Though all excuse ladies rather regard assure yet. If feelings so prospect no as raptures quitting."),
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
