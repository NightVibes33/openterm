//
//  TerminalTabViewController.swift
//  OpenTerm
//
//  Created by Ian McDowell on 2/3/18.
//  Copyright Â© 2018 Silver Fox. All rights reserved.
//

import UIKit
import TabView

class TerminalTabViewController: TabViewController {

	static weak var activeController: TerminalTabViewController?
	private struct PendingTerminalAction {
		let command: String
		let execute: Bool
	}
	private static var pendingAction: PendingTerminalAction?

	required init(theme: TabViewTheme) {
		super.init(theme: theme)

		self.viewControllers = [
			TerminalViewController()
		]

		self.navigationItem.leftBarButtonItems = [
			UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(showSettings))
		]
		self.navigationItem.rightBarButtonItems = [
			UIBarButtonItem(image: #imageLiteral(resourceName: "Add"), style: .plain, target: self, action: #selector(addTab))
		]
	}

	required init?(coder aDecoder: NSCoder) {
		return nil
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		TerminalTabViewController.activeController = self
		TerminalTabViewController.consumePendingCommandIfNeeded()
	}

	@objc private func showSettings() {
		NotificationCenter.default.post(name: .workspaceDidRequestSettingsFocus, object: nil)
	}

	@objc private func addTab() {
		self.activateTab(TerminalViewController())
	}

	@objc private func closeCurrentTab() {
		if let visibleViewController = self.visibleViewController {
			self.closeTab(visibleViewController)
		}
	}

	override var keyCommands: [UIKeyCommand]? {
		return [
			UIKeyCommand(input: "T", modifierFlags: .command, action: #selector(addTab), discoverabilityTitle: "New tab"),
			UIKeyCommand(input: "W", modifierFlags: .command, action: #selector(closeCurrentTab), discoverabilityTitle: "Close tab")
		]
	}
	
	override func closeTab(_ tab: UIViewController) {
		super.closeTab(tab)
		
		if let terminalVC = tab as? TerminalViewController {
			terminalVC.terminalView.executor.closeSession()
		}
		
	}

	static func focusOrQueue(command: String, execute: Bool = false) {
		pendingAction = PendingTerminalAction(command: command, execute: execute)
		consumePendingCommandIfNeeded()
	}

	static func consumePendingCommandIfNeeded() {
		guard
			let action = pendingAction,
			let controller = activeController
		else {
			return
		}

		pendingAction = nil
		controller.focus(command: action.command, execute: action.execute)
	}

	private func focus(command: String, execute: Bool) {
		guard let viewController = visibleViewController as? TerminalViewController else {
			return
		}

		if execute {
			viewController.execute(command: command)
		} else {
			viewController.terminalView.currentCommand = command
		}

		if viewController.presentedViewController == nil {
			viewController.terminalView.becomeFirstResponder()
		}
	}

}
