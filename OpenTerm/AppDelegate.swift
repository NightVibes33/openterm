//
//  AppDelegate.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 07/12/2017.
//  Copyright Â© 2017 Silver Fox. All rights reserved.
//

import UIKit
import TabView
import CoreSpotlight
import UniformTypeIdentifiers
import ios_system
import SwiftUI

#if canImport(SimulatorStatusMagic)
	import SimulatorStatusMagic
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = UIHostingController(rootView: DeveloperWorkspaceRootView())
		window?.tintColor = .defaultMainTintColor
		window?.makeKeyAndVisible()

		do {
			try FileManager.default.downloadAllFromCloud(at: DocumentManager.shared.scriptsURL)
		} catch {
			print(error)
		}

		#if canImport(SimulatorStatusMagic)
			SDStatusBarManager.sharedInstance().enableOverrides()
		#endif

		indexCommands()

		return true
	}

	func indexCommands() {
		CSSearchableIndex.default().deleteAllSearchableItems { _ in
			let systemCommands = (commandsAsArray() as? [String] ?? []).sorted()
			let commands = systemCommands + CommandManager.shared.scriptCommands

			for command in commands {
				let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
				attributeSet.title = command
				attributeSet.contentDescription = CommandManager.shared.description(for: command)

				let item = CSSearchableItem(uniqueIdentifier: "\(command)", domainIdentifier: "com.nightvibes33.openterm", attributeSet: attributeSet)
				CSSearchableIndex.default().indexSearchableItems([item]) { error in
					if let error = error {
						print("Indexing error: \(error.localizedDescription)")
					} else {
						print("Search item successfully indexed!")
					}
				}
			}
		}
	}

	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
		if userActivity.activityType == CSSearchableItemActionType {
			guard let command = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
				return false
			}

			TerminalTabViewController.focusOrQueue(command: command)
			NotificationCenter.default.post(name: .workspaceDidRequestTerminalFocus, object: nil)
		}

		return true
	}

	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		if xCallbackUrlOpen(url) {
			return true
		}

		return false
	}
}
