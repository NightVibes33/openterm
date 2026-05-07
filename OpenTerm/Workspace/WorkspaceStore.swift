import Foundation
import SwiftUI

enum WorkspaceDestination: String, CaseIterable, Hashable, Identifiable {
	case home
	case terminal
	case files
	case git
	case servers
	case assistant
	case settings

	var id: String { rawValue }

	var title: String {
		switch self {
		case .home:
			return "Workspace"
		case .terminal:
			return "Terminal"
		case .files:
			return "Files"
		case .git:
			return "Git"
		case .servers:
			return "Servers"
		case .assistant:
			return "AI"
		case .settings:
			return "Settings"
		}
	}

	var systemImage: String {
		switch self {
		case .home:
			return "square.grid.2x2"
		case .terminal:
			return "terminal"
		case .files:
			return "folder"
		case .git:
			return "point.topleft.down.curvedto.point.bottomright.up"
		case .servers:
			return "server.rack"
		case .assistant:
			return "sparkles"
		case .settings:
			return "slider.horizontal.3"
		}
	}
}

struct WorkspaceSession: Identifiable {
	let id = UUID()
	let title: String
	let subtitle: String
	let detail: String
	let symbol: String
	let tint: Color
}

struct WorkspaceSnippet: Identifiable {
	let id = UUID()
	let title: String
	let body: String
	let category: String
}

struct WorkspaceFeature: Identifiable {
	let id = UUID()
	let title: String
	let detail: String
	let symbol: String
	let tint: Color
}

struct SSHProfileSummary: Identifiable {
	let id = UUID()
	let label: String
	let host: String
	let username: String
	let authKind: String
	let lastSeen: String
	let port: Int
}

struct GitWorkspaceSummary: Identifiable {
	let id = UUID()
	let name: String
	let branch: String
	let status: String
	let aheadBehind: String
}

struct ServerSnapshotSummary: Identifiable {
	let id = UUID()
	let name: String
	let cpu: String
	let memory: String
	let disk: String
	let network: String
	let alertState: String
	let tint: Color
}

struct LocalWorkspaceFile: Identifiable {
	let id = UUID()
	let name: String
	let relativePath: String
	let sizeDescription: String
	let modifiedDescription: String
	let isDirectory: Bool
}

struct PremiumPlanSummary: Identifiable {
	let id = UUID()
	let name: String
	let price: String
	let highlight: String
	let features: [String]
	let tint: Color
}

final class WorkspaceStore: ObservableObject {

	static let shared = WorkspaceStore()

	@Published var recentSessions: [WorkspaceSession] = [
		WorkspaceSession(title: "Prod API", subtitle: "SSH / ubuntu@api-1", detail: "Healthy / 21 ms", symbol: "server.rack", tint: Color(red: 0.31, green: 0.72, blue: 0.57)),
		WorkspaceSession(title: "Local Repo", subtitle: "Git / feature/ios-workspace", detail: "3 modified files", symbol: "point.topleft.down.curvedto.point.bottomright.up", tint: Color(red: 0.29, green: 0.57, blue: 0.95)),
		WorkspaceSession(title: "Docker Lab", subtitle: "Container / compose/dev", detail: "2 services online", symbol: "shippingbox", tint: Color(red: 0.96, green: 0.60, blue: 0.24)),
	]

	@Published var snippets: [WorkspaceSnippet] = [
		WorkspaceSnippet(title: "Zero-downtime deploy", body: "git pull && docker compose pull && docker compose up -d", category: "Deploy"),
		WorkspaceSnippet(title: "Top offenders", body: "ps aux --sort=-%mem | head -n 15", category: "Ops"),
		WorkspaceSnippet(title: "Find big files", body: "du -ah . | sort -rh | head -n 20", category: "Storage"),
		WorkspaceSnippet(title: "Tail recent errors", body: "journalctl -u nginx -n 200 --no-pager", category: "Logs"),
	]

	@Published var aiTools: [WorkspaceFeature] = [
		WorkspaceFeature(title: "Explain Error", detail: "Paste output and get a plain-English diagnosis.", symbol: "stethoscope", tint: Color(red: 0.91, green: 0.35, blue: 0.43)),
		WorkspaceFeature(title: "Generate Command", detail: "Turn a goal into a safe, shell-ready command.", symbol: "wand.and.stars", tint: Color(red: 0.55, green: 0.47, blue: 0.96)),
		WorkspaceFeature(title: "Fix Shell Script", detail: "Repair broken bash and zsh scripts inline.", symbol: "wrench.and.screwdriver", tint: Color(red: 0.29, green: 0.57, blue: 0.95)),
		WorkspaceFeature(title: "SSH Troubleshooting", detail: "Walk through auth, keys, ports, and host issues.", symbol: "network.badge.shield.half.filled", tint: Color(red: 0.31, green: 0.72, blue: 0.57)),
		WorkspaceFeature(title: "Regex Generator", detail: "Build and explain regular expressions from plain English.", symbol: "textformat.abc.dottedunderline", tint: Color(red: 0.98, green: 0.67, blue: 0.24)),
	]

	@Published var premiumFeatures: [WorkspaceFeature] = [
		WorkspaceFeature(title: "Unlimited AI", detail: "Remove assistant request caps and unlock longer context.", symbol: "sparkles", tint: Color(red: 0.98, green: 0.67, blue: 0.24)),
		WorkspaceFeature(title: "SSH Vault Sync", detail: "Encrypted profile metadata and vault references across devices.", symbol: "key.horizontal", tint: Color(red: 0.29, green: 0.57, blue: 0.95)),
		WorkspaceFeature(title: "Monitoring Alerts", detail: "CPU, memory, disk, and uptime alerts for remote servers.", symbol: "waveform.path.ecg", tint: Color(red: 0.91, green: 0.35, blue: 0.43)),
		WorkspaceFeature(title: "GitHub Repo Assistant", detail: "AI-assisted repo summaries, diffs, and release prep.", symbol: "chevron.left.forwardslash.chevron.right", tint: Color(red: 0.55, green: 0.47, blue: 0.96)),
	]

	@Published var sshProfiles: [SSHProfileSummary] = [
		SSHProfileSummary(label: "Prod API", host: "api-1.example.com", username: "ubuntu", authKind: "Vault key", lastSeen: "5 min ago", port: 22),
		SSHProfileSummary(label: "Home Lab", host: "192.168.1.44", username: "dev", authKind: "Ed25519", lastSeen: "Yesterday", port: 22),
		SSHProfileSummary(label: "DB Bastion", host: "bastion.internal", username: "ops", authKind: "Certificate", lastSeen: "2 days ago", port: 2222),
	]

	@Published var gitWorkspaces: [GitWorkspaceSummary] = [
		GitWorkspaceSummary(name: "OpenTerm", branch: "feature/workspace-redesign", status: "3 modified / 1 staged", aheadBehind: "ahead 2"),
		GitWorkspaceSummary(name: "infra-scripts", branch: "main", status: "clean", aheadBehind: "in sync"),
	]

	@Published var serverSnapshots: [ServerSnapshotSummary] = [
		ServerSnapshotSummary(name: "Prod API", cpu: "41%", memory: "62%", disk: "58%", network: "21 ms", alertState: "Healthy", tint: Color(red: 0.31, green: 0.72, blue: 0.57)),
		ServerSnapshotSummary(name: "Redis Node", cpu: "72%", memory: "81%", disk: "44%", network: "34 ms", alertState: "Watch", tint: Color(red: 0.98, green: 0.67, blue: 0.24)),
		ServerSnapshotSummary(name: "Backups", cpu: "28%", memory: "37%", disk: "91%", network: "18 ms", alertState: "Disk alert", tint: Color(red: 0.91, green: 0.35, blue: 0.43)),
	]

	@Published var localFiles: [LocalWorkspaceFile] = []
	@Published var premiumPlans: [PremiumPlanSummary] = [
		PremiumPlanSummary(name: "Pro", price: "$9/mo", highlight: "For solo developers", features: ["Unlimited AI requests", "Theme packs", "Session restore", "Advanced Git tools"], tint: Color(red: 0.29, green: 0.57, blue: 0.95)),
		PremiumPlanSummary(name: "Infra", price: "$19/mo", highlight: "For operators and homelabs", features: ["SSH vault sync", "Monitoring history", "Alerts", "Encrypted exports"], tint: Color(red: 0.31, green: 0.72, blue: 0.57)),
		PremiumPlanSummary(name: "Team", price: "$39/mo", highlight: "For shared workflows later", features: ["Shared snippets", "Team workspaces", "Audit visibility", "Repo assistant seats"], tint: Color(red: 0.55, green: 0.47, blue: 0.96)),
	]

	@Published var activeThemeName: String = "Glass Slate"
	@Published var billingSourceDescription: String = "StoreKit 2 for App Store builds / Stripe Checkout for web account billing"

	private let byteCountFormatter = ByteCountFormatter()
	private let dateFormatter: RelativeDateTimeFormatter = {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .short
		return formatter
	}()

	init() {
		byteCountFormatter.allowedUnits = [.useKB, .useMB]
		byteCountFormatter.countStyle = .file
		refreshLocalFiles()
	}

	func refreshLocalFiles() {
		let rootURL = DocumentManager.shared.activeDocumentsFolderURL
		let fileManager = FileManager.default

		guard let enumerator = fileManager.enumerator(at: rootURL, includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey, .fileSizeKey], options: [.skipsHiddenFiles]) else {
			localFiles = []
			return
		}

		var files = [LocalWorkspaceFile]()

		for case let fileURL as URL in enumerator {
			guard files.count < 24 else {
				break
			}

			let values = try? fileURL.resourceValues(forKeys: [.isDirectoryKey, .contentModificationDateKey, .fileSizeKey])
			let isDirectory = values?.isDirectory ?? false
			let modified = values?.contentModificationDate ?? Date.distantPast
			let sizeDescription: String

			if isDirectory {
				sizeDescription = "Folder"
			} else {
				let fileSize = Int64(values?.fileSize ?? 0)
				sizeDescription = byteCountFormatter.string(fromByteCount: fileSize)
			}

			let relativePath = fileURL.path.replacingOccurrences(of: rootURL.path + "/", with: "")
			files.append(
				LocalWorkspaceFile(
					name: fileURL.lastPathComponent,
					relativePath: relativePath,
					sizeDescription: sizeDescription,
					modifiedDescription: dateFormatter.localizedString(for: modified, relativeTo: Date()),
					isDirectory: isDirectory
				)
			)
		}

		localFiles = files.sorted {
			if $0.isDirectory == $1.isDirectory {
				return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
			}

			return $0.isDirectory && !$1.isDirectory
		}
	}
}
