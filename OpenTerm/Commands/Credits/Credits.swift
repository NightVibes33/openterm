//
//  Credits.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 31/03/2018.
//  Copyright Â© 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system
import TabView

private func activeTerminalTabContainer() -> TabViewContainerViewController<TerminalTabViewController>? {
	let windowScenes = UIApplication.shared.connectedScenes
		.compactMap { $0 as? UIWindowScene }
		.sorted { lhs, rhs in
			lhs.activationState == .foregroundActive && rhs.activationState != .foregroundActive
		}
	let rootViewController = windowScenes
		.flatMap(\.windows)
		.first(where: \.isKeyWindow)?
		.rootViewController
	return rootViewController as? TabViewContainerViewController<TerminalTabViewController>
}

@_cdecl("credits")
public func credits(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {
	
	let logoFileName: String

	// Command execution is off-main-thread, so terminal lookup stays guarded.
	
		guard let tabViewContainer = activeTerminalTabContainer() else {
			return 1
		}
		
		guard let activeVC = tabViewContainer.primaryTabViewController.visibleViewController as? TerminalViewController else {
			return 1
		}
		
		let terminalView = activeVC.terminalView
		
		let bigLogoWidth = 48

		if terminalView.columnWidth < bigLogoWidth {
			
			logoFileName = "Logo-small"
			
		} else {
			
			logoFileName = "Logo"
			
		}
		
//	} else {
//
//		logoFileName = "Logo"
//
//	}
	
	var output = "\n"
	
	guard let logoPath = Bundle.main.path(forResource: logoFileName, ofType: "txt") else {
		fputs("Could not get logo path", thread_stderr)
		return 1
	}
	
	guard let logo = try? String(contentsOfFile: logoPath) else {
		fputs("Could not get logo", thread_stderr)
		return 1
	}
	
	output += logo
		
	let version = Bundle.main.version
	let build = Bundle.main.build

	output += "\nv\(version), build \(build)\n"
	
	let decoder = JSONDecoder()
	
	guard let url = Bundle.main.url(forResource: "authors", withExtension: "json") else {
		fputs("Could not get authors", thread_stderr)
		return 1
	}

	guard let authors = try? decoder.decode([Author].self, from: Data(contentsOf: url)) else {
		fputs("Could not parse authors", thread_stderr)
		return 1
	}
	
	let authorsString = "Created by:\n" + authors.map({ $0.name }).joined(separator: "\n")
	
	output += "\n\(authorsString)\n\n"

	fputs(output, thread_stdout)

	return 0
}
