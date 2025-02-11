//
//  Helpers.swift
//  AINavigation
//
//  Created by Omar Torres on 1/25/25.
//

import SwiftUI

enum ViewSide: String {
	case left
	case right
}

struct WidthKey: EnvironmentKey {
	static let defaultValue: [ViewSide: CGFloat] = [:]
}

struct ChatsWidthKey: EnvironmentKey {
	static let defaultValue: CGFloat = 0.0
}

extension EnvironmentValues {
	var customWidths: [ViewSide: CGFloat] {
		get { self[WidthKey.self] }
		set { self[WidthKey.self] = newValue }
	}
	
	var chatsWidth: CGFloat {
		get { self[ChatsWidthKey.self] }
		set { self[ChatsWidthKey.self] = newValue }
	}
}

let textColorLight = Color.black
let textColorDark = Color.white
let buttonColor = Color(hex: "6A87C2")!
let buttonBorderColor = Color.gray
let buttonDefaultColor = Color(hex: "6A6A6A")!
let normalFont = Font.custom("HelveticaNeue", size: 15)
let promptFont = Font.custom("HelveticaNeue", size: 18)
let outputFont = NSFont(name: "HelveticaNeue", size: 15)
let buttonTextFont = Font.custom("HelveticaNeue", size: 13)
let headerTextFont = NSFont(name: "HelveticaNeue-Bold", size: 24)
let subHeaderTextFont = NSFont(name: "HelveticaNeue-Medium", size: 20)
let boldTextFont = NSFont(name: "HelveticaNeue-Bold", size: 15)
let threadPromptFont = Font.custom("HelveticaNeue", size: 20)
let conversationItemBackgroundColor = Color(hex: "DFDBC1")!
let chatsSidebarBackgroundColor = Color(hex: "E9E9E9")!
let chatsViewBackgroundColor = Color(hex: "E2E2E2")!
