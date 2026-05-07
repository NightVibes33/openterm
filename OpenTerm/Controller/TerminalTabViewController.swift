//
//  TerminalTabViewController.swift
//  OpenTerm
//
//  Created by Ian McDowell on 2/3/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import TabView

class TerminalTabViewController: TabViewController {

	static weak var activeController: TerminalTabViewController?
	private static var pendingCommand: String?

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
		fatalError("init(coder:) has not been implemented")
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
		let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController")
		let nav = UINavigationController(rootViewController: settingsVC)
		nav.navigationBar.barStyle = .black
		nav.modalPresentationStyle = .formSheet
		self.present(nav, animated: true, completion: nil)
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

	static func focusOrQueue(command: String) {
		pendingCommand = command
		consumePendingCommandIfNeeded()
	}

	static func consumePendingCommandIfNeeded() {
		guard
			let command = pendingCommand,
			let controller = activeController
		else {
			return
		}

		pendingCommand = nil
		controller.focus(command: command)
	}

	private func focus(command: String) {
		guard let viewController = visibleViewController as? TerminalViewController else {
			return
		}

		viewController.terminalView.currentCommand = command

		if viewController.presentedViewController == nil {
			viewController.terminalView.becomeFirstResponder()
		}
	}

}
