//
//  UIColor+AssetCatalog.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 06/01/2018.
//  Copyright Â© 2018 Silver Fox. All rights reserved.
//

import UIKit

extension UIColor {

	static var defaultMainTintColor: UIColor {
		return UIColor(named: "Main Tint Color") ?? UIColor.systemBlue
	}

	static var panelBackgroundColor: UIColor {
		return UIColor(named: "Panel Background Color") ?? UIColor.systemBackground
	}

	static var modernTerminalBackgroundColor: UIColor {
		UIColor { traitCollection in
			traitCollection.userInterfaceStyle == .dark
				? UIColor(red: 0.025, green: 0.031, blue: 0.055, alpha: 1)
				: UIColor(red: 0.965, green: 0.972, blue: 0.985, alpha: 1)
		}
	}

	static var modernTerminalTextColor: UIColor {
		UIColor { traitCollection in
			traitCollection.userInterfaceStyle == .dark
				? UIColor(red: 0.87, green: 0.93, blue: 0.98, alpha: 1)
				: UIColor(red: 0.08, green: 0.10, blue: 0.14, alpha: 1)
		}
	}

}
