import SwiftUI
import TabView
import UIKit

struct LegacyTerminalContainerView: UIViewControllerRepresentable {

	func makeUIViewController(context: Context) -> UIViewController {
		TabViewContainerViewController<TerminalTabViewController>(theme: TabViewThemeDark())
	}

	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		TerminalTabViewController.consumePendingCommandIfNeeded()
	}
}
