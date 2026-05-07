//
//  Notification+Names.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 20/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

extension Notification.Name {
	
	static let appearanceDidChange = Notification.Name("appearanceDidChange")
	static let historyDidChange = Notification.Name("HistoryManagerHistoryDidChangeNotification")
	static let caretStyleDidChange = Notification.Name("caretStyleDidChange")
	static let workspaceDidRequestTerminalFocus = Notification.Name("workspaceDidRequestTerminalFocus")
}
