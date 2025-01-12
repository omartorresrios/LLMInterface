//
//  Chat.swift
//  AINavigation
//
//  Created by Omar Torres on 11/22/24.
//

struct Chat: Hashable {
	let id: String
	var prompt: String = ""
	var output: String
	var status: ChatStatus
		
	enum ChatStatus {
		case pending
		case completed
	}
	
	mutating func setPrompt(_ prompt: String) {
		self.prompt = prompt
	}
	
	static let cards = [Chat(id: "1",
							 output: "So if on advanced addition absolute received replying throwing he. Delighted consisted newspaper of unfeeling as neglected so. Tell size come hard mrs and four fond are. Of in commanded earnestly resources it. At quitting in strictly up wandered of relation answered felicity. Side need at in what dear ever upon if. Same down want joy neat ask pain help she. Alone three stuff use law walls fat asked. Near do that he help. Adieus except say barton put feebly favour him. Entreaties unpleasant sufficient few pianoforte discovered uncommonly ask. Morning cousins amongst in mr weather do neither. Warmth object matter course active law spring six. Pursuit showing tedious unknown winding see had man add. And park eyes too more him. Simple excuse active had son wholly coming number add. Though all excuse ladies rather regard assure yet. If feelings so prospect no as raptures quitting.", status: .pending),
						Chat(id: "2",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
							 String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "3",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "4",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "5",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
		   String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "6",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "7",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "8",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "9",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "10",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "11",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "12",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "13",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "14",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "15",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "16",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "17",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "18",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "19",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "20",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "21",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "22",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "23",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "24",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending),
						Chat(id: "25",
							 output: "SwiftUI is a modern way to declare user interfaces for iOS, macOS, watchOS, and tvOS. " +
						String(repeating: "This is a long response. ", count: 100), status: .pending)]
}
