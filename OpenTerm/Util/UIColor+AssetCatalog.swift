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

}
