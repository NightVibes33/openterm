import Foundation
import SwiftUI
import UIKit
import CryptoKit
import Security

enum WorkspaceDestination: String, CaseIterable, Hashable, Identifiable {
	case home
	case terminal
	case files
	case git
	case servers
	case assistant
	case settings
	case more

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
		case .more:
			return "More"
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
		case .more:
			return "ellipsis.circle"
		}
	}
}

enum SSHAuthKind: String, CaseIterable, Codable, Identifiable {
	case agent
	case password
	case key
	case certificate

	var id: String { rawValue }

	var title: String {
		switch self {
		case .agent:
			return "SSH Agent"
		case .password:
			return "Password"
		case .key:
			return "Private Key"
		case .certificate:
			return "Certificate"
		}
	}
}

enum MonitorAlertLevel: String, Codable {
	case healthy
	case watch
	case alert
	case unavailable

	var title: String {
		switch self {
		case .healthy:
			return "Healthy"
		case .watch:
			return "Watch"
		case .alert:
			return "Alert"
		case .unavailable:
			return "Unavailable"
		}
	}

	var tint: Color {
		switch self {
		case .healthy:
			return Color(red: 0.31, green: 0.72, blue: 0.57)
		case .watch:
			return Color(red: 0.98, green: 0.67, blue: 0.24)
		case .alert:
			return Color(red: 0.91, green: 0.35, blue: 0.43)
		case .unavailable:
			return Color(red: 0.65, green: 0.67, blue: 0.72)
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

struct WorkspaceSnippet: Identifiable, Codable, Hashable {
	var id: UUID
	var title: String
	var body: String
	var category: String

	init(id: UUID = UUID(), title: String, body: String, category: String) {
		self.id = id
		self.title = title
		self.body = body
		self.category = category
	}
}

struct WorkspaceFeature: Identifiable {
	let id = UUID()
	let title: String
	let detail: String
	let symbol: String
	let tint: Color
}

struct SSHProfileSummary: Identifiable, Codable, Hashable {
	var id: UUID
	var label: String
	var host: String
	var username: String
	var authKind: SSHAuthKind
	var lastSeen: Date?
	var port: Int
	var privateKeyPath: String
	var startupPath: String
	var notes: String

	init(
		id: UUID = UUID(),
		label: String,
		host: String,
		username: String,
		authKind: SSHAuthKind,
		lastSeen: Date? = nil,
		port: Int = 22,
		privateKeyPath: String = "",
		startupPath: String = "",
		notes: String = ""
	) {
		self.id = id
		self.label = label
		self.host = host
		self.username = username
		self.authKind = authKind
		self.lastSeen = lastSeen
		self.port = port
		self.privateKeyPath = privateKeyPath
		self.startupPath = startupPath
		self.notes = notes
	}
}

struct SSHVaultItem: Identifiable, Codable, Hashable {
	var id: UUID
	var label: String
	var keyPath: String
	var fingerprint: String
	var createdAt: Date
	var lastUsedAt: Date?

	init(id: UUID = UUID(), label: String, keyPath: String, fingerprint: String = "Not scanned yet", createdAt: Date = Date(), lastUsedAt: Date? = nil) {
		self.id = id
		self.label = label
		self.keyPath = keyPath
		self.fingerprint = fingerprint
		self.createdAt = createdAt
		self.lastUsedAt = lastUsedAt
	}
}

struct GitWorkspaceSummary: Identifiable, Hashable {
	var id: String { path }
	let name: String
	let path: String
	let branch: String
	let status: String
	let aheadBehind: String
}

struct ServerMonitorSummary: Identifiable, Codable, Hashable {
	var id: UUID
	var sshProfileID: UUID
	var label: String
	var path: String
	var cpuThreshold: Int
	var memoryThreshold: Int
	var diskThreshold: Int
	var refreshInterval: Int
	var isEnabled: Bool

	init(
		id: UUID = UUID(),
		sshProfileID: UUID,
		label: String,
		path: String = "/",
		cpuThreshold: Int = 85,
		memoryThreshold: Int = 85,
		diskThreshold: Int = 90,
		refreshInterval: Int = 60,
		isEnabled: Bool = true
	) {
		self.id = id
		self.sshProfileID = sshProfileID
		self.label = label
		self.path = path
		self.cpuThreshold = cpuThreshold
		self.memoryThreshold = memoryThreshold
		self.diskThreshold = diskThreshold
		self.refreshInterval = refreshInterval
		self.isEnabled = isEnabled
	}
}

struct ServerSnapshotSummary: Identifiable, Codable, Hashable {
	var id: UUID
	var name: String
	var cpuPercent: Int?
	var memoryPercent: Int?
	var diskPercent: Int?
	var latency: String
	var alertLevel: MonitorAlertLevel
	var detail: String
	var lastChecked: Date?

	init(
		id: UUID,
		name: String,
		cpuPercent: Int? = nil,
		memoryPercent: Int? = nil,
		diskPercent: Int? = nil,
		latency: String = "--",
		alertLevel: MonitorAlertLevel = .unavailable,
		detail: String = "No snapshot yet",
		lastChecked: Date? = nil
	) {
		self.id = id
		self.name = name
		self.cpuPercent = cpuPercent
		self.memoryPercent = memoryPercent
		self.diskPercent = diskPercent
		self.latency = latency
		self.alertLevel = alertLevel
		self.detail = detail
		self.lastChecked = lastChecked
	}
}

struct ServerAlertEvent: Identifiable, Codable, Hashable {
	var id: UUID
	var monitorID: UUID
	var title: String
	var detail: String
	var level: MonitorAlertLevel
	var createdAt: Date
	var isAcknowledged: Bool

	init(id: UUID = UUID(), monitorID: UUID, title: String, detail: String, level: MonitorAlertLevel, createdAt: Date = Date(), isAcknowledged: Bool = false) {
		self.id = id
		self.monitorID = monitorID
		self.title = title
		self.detail = detail
		self.level = level
		self.createdAt = createdAt
		self.isAcknowledged = isAcknowledged
	}
}

struct LocalWorkspaceFile: Identifiable, Hashable {
	var id: String { relativePath }
	let name: String
	let relativePath: String
	let sizeDescription: String
	let modifiedDescription: String
	let isDirectory: Bool
}

struct WorkspaceShareItem: Identifiable {
	let id = UUID()
	let url: URL
}

struct AIProviderConfiguration: Codable, Equatable {
	var endpoint: String
	var model: String
	var apiKey: String
	var systemPrompt: String
	var routingMode: String?

	var usesHostedProxy: Bool {
		routingMode == "hosted_proxy"
	}

	static let `default` = AIProviderConfiguration(
		endpoint: "",
		model: "gpt-4.1-mini",
		apiKey: "",
		systemPrompt: "You are OpenTerm AI, a concise mobile developer assistant focused on shell, SSH, Linux, and code tasks.",
		routingMode: nil
	)
}

struct BackendConfiguration: Codable, Equatable {
	var supabaseURL: String
	var accessToken: String
	var deviceLabel: String
	var anonKey: String?
	var userID: String?
	var deviceID: String?
	var vaultSyncSecret: String?

	static let `default` = BackendConfiguration(
		supabaseURL: "",
		accessToken: "",
		deviceLabel: UIDevice.current.name,
		anonKey: nil,
		userID: nil,
		deviceID: UIDevice.current.identifierForVendor?.uuidString,
		vaultSyncSecret: nil
	)

	var normalizedSupabaseURL: String {
		supabaseURL.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
	}

	var aiProxyEndpoint: String {
		let trimmed = normalizedSupabaseURL
		guard !trimmed.isEmpty else { return "" }
		return "\(trimmed)/functions/v1/ai-proxy"
	}

	var vaultRPCBaseURL: String {
		let trimmed = normalizedSupabaseURL
		guard !trimmed.isEmpty else { return "" }
		return "\(trimmed)/rest/v1/rpc"
	}
}

struct AssistantMessage: Identifiable, Hashable {
	let id = UUID()
	let role: String
	let content: String
	let createdAt: Date
}

struct AIUsageRecord: Codable, Hashable {
	var id: UUID
	var prompt: String
	var model: String
	var promptTokens: Int
	var completionTokens: Int
	var createdAt: Date

	init(id: UUID = UUID(), prompt: String, model: String, promptTokens: Int = 0, completionTokens: Int = 0, createdAt: Date = Date()) {
		self.id = id
		self.prompt = prompt
		self.model = model
		self.promptTokens = promptTokens
		self.completionTokens = completionTokens
		self.createdAt = createdAt
	}
}

struct WorkspaceEditorDocument: Identifiable, Equatable {
	var id: String { relativePath }
	let title: String
	let relativePath: String
	let initialContent: String
}

struct WorkspaceBackupManifest: Encodable {
	let exportedAt: Date
	let sshProfiles: [SSHProfileSummary]
	let sshVaultItems: [SSHVaultItem]
	let snippets: [WorkspaceSnippet]
	let serverMonitors: [ServerMonitorSummary]
	let aiModel: String
	let aiRoutingMode: String?
	let backendURLConfigured: Bool
	let appVersion: String
}

private struct WorkspaceCommandResult {
	let stdout: String
	let stderr: String
	let status: Int
}

private enum WorkspaceSecretStore {
	private static let service = "com.nightvibes33.openterm.workspace"

	static func read(_ key: String) -> String {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: key,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]
		var result: CFTypeRef?
		guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
			let data = result as? Data,
			let value = String(data: data, encoding: .utf8) else {
			return ""
		}
		return value
	}

	static func write(_ value: String, for key: String) {
		let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: key
		]
		if trimmed.isEmpty {
			SecItemDelete(query as CFDictionary)
			return
		}
		let attributes: [String: Any] = [
			kSecValueData as String: Data(trimmed.utf8),
			kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
		]
		let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
		if status == errSecItemNotFound {
			var addQuery = query
			addQuery.merge(attributes) { _, new in new }
			SecItemAdd(addQuery as CFDictionary, nil)
		}
	}
}

private final class WorkspaceCommandCapture: NSObject, CommandExecutorDelegate {
	private let executor = CommandExecutor()
	private var stdout = Data()
	private var stderr = Data()
	private var completion: ((WorkspaceCommandResult) -> Void)?

	override init() {
		super.init()
		executor.delegate = self
	}

	func run(command: String, workingDirectory: URL? = nil, completion: @escaping (WorkspaceCommandResult) -> Void) {
		stdout = Data()
		stderr = Data()
		self.completion = completion
		if let workingDirectory = workingDirectory {
			executor.currentWorkingDirectory = workingDirectory
		}
		executor.dispatch(command)
	}

	func commandExecutor(_ commandExecutor: CommandExecutor, receivedStdout stdout: Data) {
		self.stdout.append(stdout)
	}

	func commandExecutor(_ commandExecutor: CommandExecutor, receivedStderr stderr: Data) {
		self.stderr.append(stderr)
	}

	func commandExecutor(_ commandExecutor: CommandExecutor, didChangeWorkingDirectory to: URL) {}
	func commandExecutor(_ commandExecutor: CommandExecutor, waitForInput callback: @escaping (String) -> Void) {}
	func commandExecutor(_ commandExecutor: CommandExecutor, executeSubCommand subCommand: String, callback: @escaping (Int) -> Void) {}
	func commandExecutor(_ commandExecutor: CommandExecutor, executeSubCommand subCommand: String, capturingOutput callback: @escaping (String) -> Void) {}

	func commandExecutor(_ commandExecutor: CommandExecutor, stateDidChange newState: CommandExecutor.State) {
		guard case .idle = newState, let completion = completion else {
			return
		}

		self.completion = nil
		let status = Int(commandExecutor.context[.status] ?? "1") ?? 1
		let eot = Parser.Code.endOfTransmission.rawValue
		let stdoutString = String(data: stdout, encoding: .utf8)?.replacingOccurrences(of: eot, with: "").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		let stderrString = String(data: stderr, encoding: .utf8)?.replacingOccurrences(of: eot, with: "").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

		DispatchQueue.main.async {
			completion(WorkspaceCommandResult(stdout: stdoutString, stderr: stderrString, status: status))
		}
	}
}

final class WorkspaceStore: ObservableObject {

	static let shared = WorkspaceStore()

	@Published var recentSessions: [WorkspaceSession] = []
	@Published var snippets: [WorkspaceSnippet] = []
	@Published var aiTools: [WorkspaceFeature] = []
	@Published var featuredCapabilities: [WorkspaceFeature] = []
	@Published var sshProfiles: [SSHProfileSummary] = []
	@Published var sshVaultItems: [SSHVaultItem] = []
	@Published var gitWorkspaces: [GitWorkspaceSummary] = []
	@Published var serverMonitors: [ServerMonitorSummary] = []
	@Published var serverSnapshots: [ServerSnapshotSummary] = []
	@Published var serverAlerts: [ServerAlertEvent] = []
	@Published var localFiles: [LocalWorkspaceFile] = []
	@Published var currentFolderRelativePath: String = ""
	@Published var activeEditor: WorkspaceEditorDocument?
	@Published var assistantMessages: [AssistantMessage] = []
	@Published var assistantDraft: String = "Turn my goal into commands"
	@Published var assistantStatus: String = "Configure an AI endpoint in Settings to enable live answers."
	@Published var isSendingAssistantPrompt: Bool = false
	@Published var aiConfiguration: AIProviderConfiguration = .default
	@Published var backendConfiguration: BackendConfiguration = .default
	@Published var aiUsageHistory: [AIUsageRecord] = []
	@Published var isRefreshingMonitors: Bool = false
	@Published var statusMessage: String = "Workspace idle"
	@Published var activeThemeName: String = "Glass Slate"
	@Published var workspaceAccentColor: Color = Color(UserDefaultsController.shared.workspaceAccentColor)
	@Published var lastBackupPath: String = "No backup exported yet"
	@Published var vaultSyncStatus: String = "Vault sync not configured"
	@Published var isSyncingVault: Bool = false
	@Published var remoteConfigStatus: String = "Remote config not loaded"
	@Published var freeModeSummary: String = "Free while the core SSH, Git, AI, editor, and monitoring workflows are stabilized."

	private let fileManager = FileManager.default
	private let byteCountFormatter = ByteCountFormatter()
	private let dateFormatter: RelativeDateTimeFormatter = {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .short
		return formatter
	}()
	private let commandCapture = WorkspaceCommandCapture()
	private var monitorTimer: Timer?
	private var vaultSyncTimer: Timer?

	private init() {
		byteCountFormatter.allowedUnits = [.useKB, .useMB]
		byteCountFormatter.countStyle = .file
		seedStaticFeatures()
		ensureWorkspaceSupportDirectory()
		loadPersistedState()
		refreshLocalFiles()
		refreshGitWorkspaces()
		rebuildRecentSessions()
		NotificationCenter.default.addObserver(forName: .appearanceDidChange, object: nil, queue: .main) { [weak self] _ in
			self?.workspaceAccentColor = Color(UserDefaultsController.shared.workspaceAccentColor)
		}
		startVaultBackgroundRefreshIfConfigured()
	}

	private var workspaceSupportURL: URL {
		DocumentManager.shared.activeDocumentsFolderURL.appendingPathComponent(".openterm-workspace", isDirectory: true)
	}

	private func seedStaticFeatures() {
		aiTools = [
			WorkspaceFeature(title: "Explain Error", detail: "Paste output and get a plain-English diagnosis.", symbol: "stethoscope", tint: Color(red: 0.91, green: 0.35, blue: 0.43)),
			WorkspaceFeature(title: "Generate Command", detail: "Turn a goal into a safe, shell-ready command.", symbol: "wand.and.stars", tint: Color(red: 0.55, green: 0.47, blue: 0.96)),
			WorkspaceFeature(title: "Fix Shell Script", detail: "Repair broken bash and zsh scripts inline.", symbol: "wrench.and.screwdriver", tint: Color(red: 0.29, green: 0.57, blue: 0.95)),
			WorkspaceFeature(title: "SSH Troubleshooting", detail: "Walk through auth, keys, ports, and host issues.", symbol: "network.badge.shield.half.filled", tint: Color(red: 0.31, green: 0.72, blue: 0.57)),
			WorkspaceFeature(title: "Remote Dev Setup", detail: "Generate safe VPS setup commands for Git, Python, Node, and shell tools.", symbol: "shippingbox.and.arrow.backward", tint: Color(red: 0.18, green: 0.74, blue: 0.78)),
			WorkspaceFeature(title: "Docker Helper", detail: "Create Docker, Compose, and reverse-proxy command plans.", symbol: "cube.transparent", tint: Color(red: 0.29, green: 0.57, blue: 0.95)),
			WorkspaceFeature(title: "Git Conflict Helper", detail: "Explain conflicts and generate a cautious merge/rebase plan.", symbol: "point.topleft.down.curvedto.point.bottomright.up", tint: Color(red: 0.55, green: 0.47, blue: 0.96)),
			WorkspaceFeature(title: "Regex Generator", detail: "Build and explain regular expressions from plain English.", symbol: "textformat.abc.dottedunderline", tint: Color(red: 0.98, green: 0.67, blue: 0.24))
		]

		featuredCapabilities = [
			WorkspaceFeature(title: "Saved SSH Profiles", detail: "Persist hosts, ports, auth modes, and startup paths locally.", symbol: "server.rack", tint: Color(red: 0.31, green: 0.72, blue: 0.57)),
			WorkspaceFeature(title: "Monitor Refresh", detail: "Pull Linux server snapshots over SSH and surface threshold warnings.", symbol: "waveform.path.ecg", tint: Color(red: 0.98, green: 0.67, blue: 0.24)),
			WorkspaceFeature(title: "Local Code Editor", detail: "Open, edit, and save text files directly from the documents workspace.", symbol: "doc.text.magnifyingglass", tint: Color(red: 0.29, green: 0.57, blue: 0.95)),
			WorkspaceFeature(title: "Terminal Actions", detail: "Run SSH, Git, and snippet workflows straight into the active terminal tab.", symbol: "terminal", tint: Color(red: 0.55, green: 0.47, blue: 0.96))
		]
	}

	private func ensureWorkspaceSupportDirectory() {
		if !fileManager.fileExists(atPath: workspaceSupportURL.path) {
			try? fileManager.createDirectory(at: workspaceSupportURL, withIntermediateDirectories: true, attributes: nil)
		}
	}

	private func stateURL(for component: String) -> URL {
		workspaceSupportURL.appendingPathComponent(component)
	}

	private func loadPersistedState() {
		sshProfiles = load([SSHProfileSummary].self, from: stateURL(for: "ssh-profiles.json")) ?? defaultSSHProfiles()
		sshVaultItems = load([SSHVaultItem].self, from: stateURL(for: "ssh-vault.json")) ?? []
		snippets = load([WorkspaceSnippet].self, from: stateURL(for: "snippets.json")) ?? defaultSnippets()
		serverMonitors = load([ServerMonitorSummary].self, from: stateURL(for: "server-monitors.json")) ?? defaultServerMonitors(from: sshProfiles)
		serverSnapshots = load([ServerSnapshotSummary].self, from: stateURL(for: "server-snapshots.json")) ?? []
		serverAlerts = load([ServerAlertEvent].self, from: stateURL(for: "server-alerts.json")) ?? []
		aiConfiguration = loadAIConfiguration()
		backendConfiguration = loadBackendConfiguration()
		aiUsageHistory = load([AIUsageRecord].self, from: stateURL(for: "ai-usage-history.json")) ?? []
		assistantMessages = []
		assistantStatus = isAIConfigured ? "AI endpoint configured. Prompts will use your saved routing settings." : "AI is not configured yet. Add a provider endpoint or Supabase proxy in Settings."
	}

	private func load<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
		guard let data = try? Data(contentsOf: url) else {
			return nil
		}
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return try? decoder.decode(T.self, from: data)
	}

	private func save<T: Encodable>(_ value: T, to url: URL) {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		encoder.dateEncodingStrategy = .iso8601
		guard let data = try? encoder.encode(value) else {
			return
		}
		try? data.write(to: url, options: .atomic)
	}

	private func defaultSSHProfiles() -> [SSHProfileSummary] {
		[]
	}

	private func defaultSnippets() -> [WorkspaceSnippet] {
		[]
	}

	private func defaultServerMonitors(from profiles: [SSHProfileSummary]) -> [ServerMonitorSummary] {
		[]
	}

	private func saveSSHProfiles() {
		save(sshProfiles, to: stateURL(for: "ssh-profiles.json"))
	}

	private func saveSSHVaultItems() {
		save(sshVaultItems, to: stateURL(for: "ssh-vault.json"))
	}

	private var sshVaultDirectoryURL: URL {
		workspaceSupportURL.appendingPathComponent("ssh-vault", isDirectory: true)
	}

	private func saveSnippets() {
		save(snippets, to: stateURL(for: "snippets.json"))
	}

	private func saveServerMonitors() {
		save(serverMonitors, to: stateURL(for: "server-monitors.json"))
	}

	private func saveServerSnapshots() {
		save(serverSnapshots, to: stateURL(for: "server-snapshots.json"))
	}

	private func saveServerAlerts() {
		save(serverAlerts, to: stateURL(for: "server-alerts.json"))
	}

	private func loadAIConfiguration() -> AIProviderConfiguration {
		var config = load(AIProviderConfiguration.self, from: stateURL(for: "ai-configuration.json")) ?? .default
		let legacyAPIKey = config.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
		let keychainAPIKey = WorkspaceSecretStore.read("ai.apiKey")
		if keychainAPIKey.isEmpty, !legacyAPIKey.isEmpty {
			WorkspaceSecretStore.write(legacyAPIKey, for: "ai.apiKey")
		}
		config.apiKey = keychainAPIKey.isEmpty ? legacyAPIKey : keychainAPIKey
		return config
	}

	private func loadBackendConfiguration() -> BackendConfiguration {
		var config = load(BackendConfiguration.self, from: stateURL(for: "backend-configuration.json")) ?? .default
		let legacyAccessToken = config.accessToken.trimmingCharacters(in: .whitespacesAndNewlines)
		let legacyAnonKey = (config.anonKey ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		let legacyVaultSecret = (config.vaultSyncSecret ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

		let keychainAccessToken = WorkspaceSecretStore.read("backend.accessToken")
		let keychainAnonKey = WorkspaceSecretStore.read("backend.anonKey")
		let keychainVaultSecret = WorkspaceSecretStore.read("backend.vaultSyncSecret")

		if keychainAccessToken.isEmpty, !legacyAccessToken.isEmpty {
			WorkspaceSecretStore.write(legacyAccessToken, for: "backend.accessToken")
		}
		if keychainAnonKey.isEmpty, !legacyAnonKey.isEmpty {
			WorkspaceSecretStore.write(legacyAnonKey, for: "backend.anonKey")
		}
		if keychainVaultSecret.isEmpty, !legacyVaultSecret.isEmpty {
			WorkspaceSecretStore.write(legacyVaultSecret, for: "backend.vaultSyncSecret")
		}

		config.accessToken = keychainAccessToken.isEmpty ? legacyAccessToken : keychainAccessToken
		config.anonKey = keychainAnonKey.isEmpty ? legacyAnonKey : keychainAnonKey
		config.vaultSyncSecret = keychainVaultSecret.isEmpty ? legacyVaultSecret : keychainVaultSecret
		return config
	}

	private func saveAIConfiguration() {
		WorkspaceSecretStore.write(aiConfiguration.apiKey, for: "ai.apiKey")
		var persisted = aiConfiguration
		persisted.apiKey = ""
		save(persisted, to: stateURL(for: "ai-configuration.json"))
	}

	private func saveBackendConfiguration() {
		WorkspaceSecretStore.write(backendConfiguration.accessToken, for: "backend.accessToken")
		WorkspaceSecretStore.write(backendConfiguration.anonKey ?? "", for: "backend.anonKey")
		WorkspaceSecretStore.write(backendConfiguration.vaultSyncSecret ?? "", for: "backend.vaultSyncSecret")
		var persisted = backendConfiguration
		persisted.accessToken = ""
		persisted.anonKey = nil
		persisted.vaultSyncSecret = nil
		save(persisted, to: stateURL(for: "backend-configuration.json"))
	}

	private func saveAIUsageHistory() {
		save(aiUsageHistory, to: stateURL(for: "ai-usage-history.json"))
	}

	func exportWorkspaceBackup() {
		let manifest = WorkspaceBackupManifest(
			exportedAt: Date(),
			sshProfiles: sshProfiles,
			sshVaultItems: sshVaultItems,
			snippets: snippets,
			serverMonitors: serverMonitors,
			aiModel: aiConfiguration.model,
			aiRoutingMode: aiConfiguration.routingMode,
			backendURLConfigured: !backendConfiguration.supabaseURL.isEmpty,
			appVersion: Bundle.main.version
		)
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		encoder.dateEncodingStrategy = .iso8601

		do {
			let data = try encoder.encode(manifest)
			let backupURL = DocumentManager.shared.activeDocumentsFolderURL.appendingPathComponent("openterm-workspace-backup.json")
			try data.write(to: backupURL, options: .atomic)
			lastBackupPath = backupURL.lastPathComponent
			statusMessage = "Exported workspace backup"
		} catch {
			statusMessage = "Could not export backup: \(error.localizedDescription)"
		}
	}

	var currentFolderDisplayPath: String {
		currentFolderRelativePath.isEmpty ? "Documents" : "Documents/\(currentFolderRelativePath)"
	}

	var canNavigateUpInFiles: Bool {
		!currentFolderRelativePath.isEmpty
	}

	private var documentsRootURL: URL {
		DocumentManager.shared.activeDocumentsFolderURL.standardizedFileURL
	}

	private var currentFolderURL: URL {
		guard !currentFolderRelativePath.isEmpty else { return documentsRootURL }
		return documentsRootURL.appendingPathComponent(currentFolderRelativePath, isDirectory: true).standardizedFileURL
	}

	func refreshLocalFiles() {
		do {
			let folderURL = currentFolderURL
			let urls = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey, .fileSizeKey], options: [])
			localFiles = urls.compactMap(localWorkspaceFile(for:)).sorted {
				if $0.isDirectory == $1.isDirectory {
					return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
				}
				return $0.isDirectory && !$1.isDirectory
			}
			statusMessage = "Browsing \(currentFolderDisplayPath)"
		} catch {
			localFiles = []
			statusMessage = "Could not read folder: \(error.localizedDescription)"
		}
	}

	private func localWorkspaceFile(for fileURL: URL) -> LocalWorkspaceFile? {
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
		let relativePath = relativePath(for: fileURL)
		return LocalWorkspaceFile(name: fileURL.lastPathComponent, relativePath: relativePath, sizeDescription: sizeDescription, modifiedDescription: dateFormatter.localizedString(for: modified, relativeTo: Date()), isDirectory: isDirectory)
	}

	private func relativePath(for url: URL) -> String {
		let rootPath = documentsRootURL.path
		let path = url.standardizedFileURL.path
		guard path.hasPrefix(rootPath) else { return url.lastPathComponent }
		let relative = path.dropFirst(rootPath.count).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
		return String(relative)
	}

	func navigateToFolder(relativePath: String) {
		let targetURL = documentsRootURL.appendingPathComponent(relativePath, isDirectory: true).standardizedFileURL
		guard targetURL.path.hasPrefix(documentsRootURL.path), (try? targetURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else {
			statusMessage = "Folder is not available"
			return
		}
		currentFolderRelativePath = relativePath
		refreshLocalFiles()
	}

	func navigateUpInFiles() {
		guard canNavigateUpInFiles else { return }
		let parent = (currentFolderRelativePath as NSString).deletingLastPathComponent
		currentFolderRelativePath = parent == "." ? "" : parent
		refreshLocalFiles()
	}

	func urlForLocalFile(relativePath: String) -> URL {
		documentsRootURL.appendingPathComponent(relativePath).standardizedFileURL
	}

	func importFiles(from urls: [URL]) {
		var imported = 0
		for url in urls {
			let didAccess = url.startAccessingSecurityScopedResource()
			defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
			let destination = uniqueDestinationURL(for: url.lastPathComponent, in: currentFolderURL)
			do {
				if fileManager.fileExists(atPath: destination.path) {
					try fileManager.removeItem(at: destination)
				}
				try fileManager.copyItem(at: url, to: destination)
				imported += 1
			} catch {
				statusMessage = "Could not import \(url.lastPathComponent): \(error.localizedDescription)"
			}
		}
		refreshLocalFiles()
		if imported > 0 { statusMessage = "Imported \(imported) file(s)" }
	}

	private func uniqueDestinationURL(for fileName: String, in folderURL: URL) -> URL {
		let cleanName = fileName.isEmpty ? "Imported File" : fileName
		let base = (cleanName as NSString).deletingPathExtension
		let ext = (cleanName as NSString).pathExtension
		var candidate = folderURL.appendingPathComponent(cleanName)
		var index = 2
		while fileManager.fileExists(atPath: candidate.path) {
			let suffix = ext.isEmpty ? " \(index)" : " \(index).\(ext)"
			candidate = folderURL.appendingPathComponent(base + suffix)
			index += 1
		}
		return candidate
	}

	func refreshGitWorkspaces() {
		let root = DocumentManager.shared.activeDocumentsFolderURL
		var repositories = [URL]()
		scanRepositories(in: root, depth: 3, found: &repositories)

		gitWorkspaces = repositories.map { repoURL in
			GitWorkspaceSummary(
				name: repoURL.lastPathComponent,
				path: repoURL.path,
				branch: branchName(forRepositoryAt: repoURL),
				status: "Terminal-driven actions available",
				aheadBehind: "Repo detected locally"
			)
		}.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
	}

	private func scanRepositories(in directory: URL, depth: Int, found: inout [URL]) {
		guard depth >= 0 else { return }
		guard let children = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsPackageDescendants]) else {
			return
		}

		for child in children {
			if child.lastPathComponent == ".git" {
				found.append(directory)
				return
			}

			guard let isDirectory = try? child.resourceValues(forKeys: [.isDirectoryKey]).isDirectory, isDirectory == true else {
				continue
			}

			if child.lastPathComponent.hasPrefix(".") {
				continue
			}

			scanRepositories(in: child, depth: depth - 1, found: &found)
		}
	}

	private func branchName(forRepositoryAt repositoryURL: URL) -> String {
		let headURL = repositoryURL.appendingPathComponent(".git/HEAD")
		guard let headContents = try? String(contentsOf: headURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines), !headContents.isEmpty else {
			return "unknown"
		}

		if headContents.hasPrefix("ref:") {
			return headContents.components(separatedBy: "/").last ?? headContents
		}

		return String(headContents.prefix(7))
	}

	func formatLastSeen(_ date: Date?) -> String {
		guard let date else {
			return "Never"
		}
		return dateFormatter.localizedString(for: date, relativeTo: Date())
	}

	func importSSHKeyToVault(label: String, privateKey: String) {
		let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
		let trimmedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedLabel.isEmpty, !trimmedKey.isEmpty else {
			statusMessage = "Enter a key label and private key"
			return
		}

		do {
			try fileManager.createDirectory(at: sshVaultDirectoryURL, withIntermediateDirectories: true, attributes: nil)
			let id = UUID()
			let keyURL = sshVaultDirectoryURL.appendingPathComponent("\(id.uuidString).key")
			let data = Data((trimmedKey + "\n").utf8)
			try data.write(to: keyURL, options: .atomic)
			try fileManager.setAttributes([.posixPermissions: 0o600, .protectionKey: FileProtectionType.complete], ofItemAtPath: keyURL.path)
			let item = SSHVaultItem(id: id, label: trimmedLabel, keyPath: keyURL.path, fingerprint: localFingerprint(for: trimmedKey))
			sshVaultItems.insert(item, at: 0)
			saveSSHVaultItems()
			statusMessage = "Imported SSH key into local vault"
		} catch {
			statusMessage = "Could not import SSH key: \(error.localizedDescription)"
		}
	}

	func deleteSSHVaultItem(_ item: SSHVaultItem) {
		try? fileManager.removeItem(atPath: item.keyPath)
		sshVaultItems.removeAll { $0.id == item.id }
		saveSSHVaultItems()
		statusMessage = "Deleted SSH key from local vault"
	}

	func attachVaultItem(_ item: SSHVaultItem, to profile: SSHProfileSummary) {
		var updated = profile
		updated.authKind = .key
		updated.privateKeyPath = item.keyPath
		upsertSSHProfile(updated)
		if let index = sshVaultItems.firstIndex(where: { $0.id == item.id }) {
			sshVaultItems[index].lastUsedAt = Date()
			saveSSHVaultItems()
		}
		statusMessage = "Attached vault key to \(profile.label)"
	}

	func pushSSHVaultToCloud() {
		let config = backendConfiguration
		guard let syncContext = vaultSyncContext(from: config) else { return }
		guard !sshVaultItems.isEmpty else {
			vaultSyncStatus = "No local vault keys to sync"
			return
		}

		isSyncingVault = true
		vaultSyncStatus = "Encrypting \(sshVaultItems.count) vault item(s)â¦"
		let group = DispatchGroup()
		var completed = 0
		var failed = 0

		for item in sshVaultItems {
			guard let keyData = try? Data(contentsOf: URL(fileURLWithPath: item.keyPath)), let encrypted = encryptVaultPayload(keyData, secret: syncContext.secret) else {
				failed += 1
				continue
			}
			let requestBody = VaultSyncUpsertRequest(
				id: item.id.uuidString,
				userID: syncContext.userID,
				deviceID: syncContext.deviceID,
				itemKind: "ssh_private_key",
				label: item.label,
				publicFingerprint: item.fingerprint,
				encryptedPayloadBase64: encrypted.payloadBase64,
				payloadNonce: encrypted.nonceBase64,
				keyVersion: 1,
				syncVersion: Int(Date().timeIntervalSince1970),
				isDeleted: false,
				lastUsedAt: item.lastUsedAt
			)
			group.enter()
			sendVaultRPC(function: "upsert_vault_sync_item", body: requestBody, context: syncContext) { success in
				DispatchQueue.main.async {
					if success { completed += 1 } else { failed += 1 }
					group.leave()
				}
			}
		}

		group.notify(queue: .main) {
			self.isSyncingVault = false
			self.vaultSyncStatus = failed == 0 ? "Synced \(completed) encrypted vault item(s)" : "Synced \(completed), failed \(failed)"
			self.statusMessage = self.vaultSyncStatus
		}
	}

	func pullSSHVaultFromCloud() {
		let config = backendConfiguration
		guard let syncContext = vaultSyncContext(from: config) else { return }
		guard let url = URL(string: "\(syncContext.rpcBaseURL)/list_vault_sync_items") else { return }
		isSyncingVault = true
		vaultSyncStatus = "Fetching encrypted vault itemsâ¦"

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		applySupabaseHeaders(to: &request, context: syncContext)
		request.httpBody = Data("{}".utf8)

		URLSession.shared.dataTask(with: request) { data, response, _ in
			DispatchQueue.main.async {
				self.isSyncingVault = false
				guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode), let data else {
					self.vaultSyncStatus = "Vault pull failed"
					self.statusMessage = self.vaultSyncStatus
					return
				}
				let decoder = JSONDecoder()
				decoder.dateDecodingStrategy = .iso8601
				guard let records = try? decoder.decode([VaultSyncRemoteItem].self, from: data) else {
					self.vaultSyncStatus = "Vault pull failed: bad response"
					return
				}
				self.importVaultSyncRecords(records, secret: syncContext.secret)
			}
		}.resume()
	}

	private func importVaultSyncRecords(_ records: [VaultSyncRemoteItem], secret: String) {
		var imported = 0
		try? fileManager.createDirectory(at: sshVaultDirectoryURL, withIntermediateDirectories: true, attributes: nil)
		for record in records where record.itemKind == "ssh_private_key" {
			guard let payload = Data(base64Encoded: record.encryptedPayloadBase64), let keyData = decryptVaultPayload(payload, secret: secret) else { continue }
			let id = UUID(uuidString: record.id) ?? UUID()
			let keyURL = sshVaultDirectoryURL.appendingPathComponent("\(id.uuidString).key")
			do {
				try keyData.write(to: keyURL, options: .atomic)
				try fileManager.setAttributes([.posixPermissions: 0o600, .protectionKey: FileProtectionType.complete], ofItemAtPath: keyURL.path)
				let item = SSHVaultItem(id: id, label: record.label, keyPath: keyURL.path, fingerprint: record.publicFingerprint ?? "Synced key", createdAt: record.createdAt ?? Date(), lastUsedAt: record.lastUsedAt)
				if let index = sshVaultItems.firstIndex(where: { $0.id == id }) {
					let localDate = sshVaultItems[index].lastUsedAt ?? sshVaultItems[index].createdAt
					let remoteDate = record.updatedAt ?? record.createdAt ?? Date.distantPast
					guard remoteDate >= localDate else { continue }
					sshVaultItems[index] = item
				} else {
					sshVaultItems.insert(item, at: 0)
				}
				imported += 1
			} catch {
				continue
			}
		}
		saveSSHVaultItems()
		vaultSyncStatus = "Imported \(imported) encrypted vault item(s)"
		statusMessage = vaultSyncStatus
	}

	func repairSSHVaultMetadata() {
		let before = sshVaultItems.count
		sshVaultItems.removeAll { !fileManager.fileExists(atPath: $0.keyPath) }
		saveSSHVaultItems()
		vaultSyncStatus = "Repaired vault metadata: removed \(before - sshVaultItems.count) missing item(s)"
		statusMessage = vaultSyncStatus
	}

	private func startVaultBackgroundRefreshIfConfigured() {
		vaultSyncTimer?.invalidate()
		guard vaultSyncContext(from: backendConfiguration, updateStatus: false) != nil else { return }
		vaultSyncTimer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
			self?.pullSSHVaultFromCloud()
		}
	}

	private func localFingerprint(for key: String) -> String {
		let bytes = Array(Data(key.utf8))
		let folded = bytes.enumerated().reduce(0) { partial, item in
			partial ^ ((Int(item.element) &+ item.offset) << (item.offset % 8))
		}
		return String(format: "local-%08x", folded)
	}

	func upsertSSHProfile(_ profile: SSHProfileSummary) {
		let cleaned = SSHProfileSummary(
			id: profile.id,
			label: profile.label.trimmingCharacters(in: .whitespacesAndNewlines),
			host: profile.host.trimmingCharacters(in: .whitespacesAndNewlines),
			username: profile.username.trimmingCharacters(in: .whitespacesAndNewlines),
			authKind: profile.authKind,
			lastSeen: profile.lastSeen,
			port: profile.port,
			privateKeyPath: profile.privateKeyPath.trimmingCharacters(in: .whitespacesAndNewlines),
			startupPath: profile.startupPath.trimmingCharacters(in: .whitespacesAndNewlines),
			notes: profile.notes.trimmingCharacters(in: .whitespacesAndNewlines)
		)
		guard !cleaned.label.isEmpty, !cleaned.host.isEmpty, !cleaned.username.isEmpty else {
			statusMessage = "SSH profile needs label, host, and username"
			return
		}
		if let index = sshProfiles.firstIndex(where: { $0.id == cleaned.id }) {
			sshProfiles[index] = cleaned
		} else {
			sshProfiles.append(cleaned)
		}
		sshProfiles.sort { $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending }
		saveSSHProfiles()
		statusMessage = "Saved SSH profile: \(cleaned.label)"
		rebuildRecentSessions()
	}

	func deleteSSHProfile(_ profile: SSHProfileSummary) {
		sshProfiles.removeAll { $0.id == profile.id }
		serverMonitors.removeAll { $0.sshProfileID == profile.id }
		serverSnapshots.removeAll { snapshot in
			!serverMonitors.contains(where: { $0.id == snapshot.id })
		}
		saveSSHProfiles()
		saveServerMonitors()
		saveServerSnapshots()
		rebuildRecentSessions()
	}

	func upsertSnippet(_ snippet: WorkspaceSnippet) {
		let cleaned = WorkspaceSnippet(
			id: snippet.id,
			title: snippet.title.trimmingCharacters(in: .whitespacesAndNewlines),
			body: snippet.body.trimmingCharacters(in: .whitespacesAndNewlines),
			category: snippet.category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Custom" : snippet.category.trimmingCharacters(in: .whitespacesAndNewlines)
		)
		guard !cleaned.title.isEmpty, !cleaned.body.isEmpty else {
			statusMessage = "Snippet needs a title and command"
			return
		}
		if let index = snippets.firstIndex(where: { $0.id == cleaned.id }) {
			snippets[index] = cleaned
		} else {
			snippets.insert(cleaned, at: 0)
		}
		saveSnippets()
		statusMessage = "Saved snippet: \(cleaned.title)"
	}

	func deleteSnippet(_ snippet: WorkspaceSnippet) {
		snippets.removeAll { $0.id == snippet.id }
		saveSnippets()
	}

	func upsertServerMonitor(_ monitor: ServerMonitorSummary) {
		guard sshProfiles.contains(where: { $0.id == monitor.sshProfileID }) else {
			statusMessage = "Select a real SSH profile before saving a monitor"
			return
		}
		let cleaned = ServerMonitorSummary(
			id: monitor.id,
			sshProfileID: monitor.sshProfileID,
			label: monitor.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Server" : monitor.label.trimmingCharacters(in: .whitespacesAndNewlines),
			path: monitor.path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "/" : monitor.path.trimmingCharacters(in: .whitespacesAndNewlines),
			cpuThreshold: monitor.cpuThreshold,
			memoryThreshold: monitor.memoryThreshold,
			diskThreshold: monitor.diskThreshold,
			refreshInterval: monitor.refreshInterval,
			isEnabled: monitor.isEnabled
		)
		if let index = serverMonitors.firstIndex(where: { $0.id == cleaned.id }) {
			serverMonitors[index] = cleaned
		} else {
			serverMonitors.append(cleaned)
		}
		saveServerMonitors()
		serverSnapshots.removeAll { snapshot in
			!serverMonitors.contains(where: { $0.id == snapshot.id })
		}
		saveServerSnapshots()
		statusMessage = "Saved monitor: \(cleaned.label)"
	}

	func deleteServerMonitor(_ monitor: ServerMonitorSummary) {
		serverMonitors.removeAll { $0.id == monitor.id }
		serverSnapshots.removeAll { $0.id == monitor.id }
		serverAlerts.removeAll { $0.monitorID == monitor.id }
		saveServerMonitors()
		saveServerSnapshots()
		saveServerAlerts()
	}

	func acknowledgeServerAlert(_ alert: ServerAlertEvent) {
		guard let index = serverAlerts.firstIndex(where: { $0.id == alert.id }) else { return }
		serverAlerts[index].isAcknowledged = true
		saveServerAlerts()
	}

	private func removeStaleServerSnapshots() {
		serverSnapshots.removeAll { snapshot in
			!serverMonitors.contains(where: { $0.id == snapshot.id })
		}
	}

	var isAIConfigured: Bool {
		let resolvedEndpoint = aiConfiguration.usesHostedProxy && aiConfiguration.endpoint.isEmpty ? backendConfiguration.aiProxyEndpoint : aiConfiguration.endpoint
		guard !resolvedEndpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, URL(string: resolvedEndpoint) != nil else {
			return false
		}
		if aiConfiguration.usesHostedProxy {
			return !backendConfiguration.accessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		return !aiConfiguration.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}

	func openSettings() {
		NotificationCenter.default.post(name: .workspaceDidRequestSettingsFocus, object: nil)
	}

	var isVaultSyncConfigured: Bool {
		vaultSyncContext(from: backendConfiguration, updateStatus: false) != nil
	}

	func updateAIConfiguration(endpoint: String, model: String, apiKey: String, systemPrompt: String, useHostedProxy: Bool) {
		aiConfiguration = AIProviderConfiguration(
			endpoint: endpoint.trimmingCharacters(in: .whitespacesAndNewlines),
			model: model.trimmingCharacters(in: .whitespacesAndNewlines),
			apiKey: apiKey.trimmingCharacters(in: .whitespacesAndNewlines),
			systemPrompt: systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines),
			routingMode: useHostedProxy ? "hosted_proxy" : nil
		)
		saveAIConfiguration()
		let route = aiConfiguration.usesHostedProxy ? "hosted proxy" : "direct provider"
		assistantStatus = aiConfiguration.endpoint.isEmpty ? "Configure an AI endpoint in Settings to enable live answers." : "AI endpoint saved. Prompts will use \(aiConfiguration.model) through \(route)."
	}

	func updateBackendConfiguration(supabaseURL: String, accessToken: String, deviceLabel: String, anonKey: String, userID: String, deviceID: String, vaultSyncSecret: String) {
		backendConfiguration = BackendConfiguration(
			supabaseURL: supabaseURL.trimmingCharacters(in: .whitespacesAndNewlines),
			accessToken: accessToken.trimmingCharacters(in: .whitespacesAndNewlines),
			deviceLabel: deviceLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? UIDevice.current.name : deviceLabel.trimmingCharacters(in: .whitespacesAndNewlines),
			anonKey: anonKey.trimmingCharacters(in: .whitespacesAndNewlines),
			userID: userID.trimmingCharacters(in: .whitespacesAndNewlines),
			deviceID: deviceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? UIDevice.current.identifierForVendor?.uuidString : deviceID.trimmingCharacters(in: .whitespacesAndNewlines),
			vaultSyncSecret: vaultSyncSecret
		)
		saveBackendConfiguration()
		startVaultBackgroundRefreshIfConfigured()
		statusMessage = "Backend settings saved"
	}


	func refreshRemoteConfiguration() {
		let config = backendConfiguration
		let baseURL = config.normalizedSupabaseURL
		let anonKey = (config.anonKey ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		let accessToken = config.accessToken.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !baseURL.isEmpty, !anonKey.isEmpty else {
			remoteConfigStatus = "Add Supabase URL and anon key first"
			statusMessage = remoteConfigStatus
			return
		}
		guard let url = URL(string: "\(baseURL)/rest/v1/remote_config?select=key,value,is_enabled&is_enabled=eq.true") else { return }
		var request = URLRequest(url: url)
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue(anonKey, forHTTPHeaderField: "apikey")
		if !accessToken.isEmpty {
			request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		}
		URLSession.shared.dataTask(with: request) { data, response, error in
			DispatchQueue.main.async {
				if let error {
					self.remoteConfigStatus = "Remote config failed: \(error.localizedDescription)"
					return
				}
				let status = (response as? HTTPURLResponse)?.statusCode ?? 0
				guard (200..<300).contains(status), let data else {
					self.remoteConfigStatus = "Remote config failed with HTTP \(status)"
					return
				}
				let count = (try? JSONSerialization.jsonObject(with: data) as? [[String: Any]])?.count ?? 0
				self.remoteConfigStatus = "Loaded \(count) remote config item(s)"
				self.statusMessage = self.remoteConfigStatus
			}
		}.resume()
	}

	func updateWorkspaceAccent(_ color: Color) {
		workspaceAccentColor = color
		UserDefaultsController.shared.workspaceAccentColor = UIColor(color)
		NotificationCenter.default.post(name: .appearanceDidChange, object: nil)
	}

	func updateTerminalTextColor(_ color: Color) {
		UserDefaultsController.shared.terminalTextColor = UIColor(color)
		NotificationCenter.default.post(name: .appearanceDidChange, object: nil)
	}

	func updateTerminalBackgroundColor(_ color: Color) {
		UserDefaultsController.shared.terminalBackgroundColor = UIColor(color)
		NotificationCenter.default.post(name: .appearanceDidChange, object: nil)
	}

	func updateTerminalFontSize(_ size: Double) {
		UserDefaultsController.shared.terminalFontSize = Int(size.rounded())
		NotificationCenter.default.post(name: .appearanceDidChange, object: nil)
	}

	func updateUseDarkKeyboard(_ enabled: Bool) {
		UserDefaultsController.shared.useDarkKeyboard = enabled
		NotificationCenter.default.post(name: .appearanceDidChange, object: nil)
	}

	func updateCaretStyle(_ style: CaretStyle) {
		UserDefaultsController.shared.caretStyle = style
		NotificationCenter.default.post(name: .caretStyleDidChange, object: nil)
	}

	func openTerminal(command: String, executeNow: Bool) {
		TerminalTabViewController.focusOrQueue(command: command, execute: executeNow)
		NotificationCenter.default.post(name: .workspaceDidRequestTerminalFocus, object: nil)
	}

	func runSnippetInTerminal(_ snippet: WorkspaceSnippet) {
		openTerminal(command: snippet.body, executeNow: true)
		statusMessage = "Running snippet: \(snippet.title)"
	}

	func connect(to profile: SSHProfileSummary) {
		openTerminal(command: sshCommand(for: profile), executeNow: true)
		touchProfile(profile.id)
		statusMessage = "Opening SSH session for \(profile.label)"
	}

	func queueRemoteDevStack(on profile: SSHProfileSummary, flavor: String) {
		let script = remoteDevStackScript(for: flavor)
		openTerminal(command: sshCommand(for: profile, remoteCommand: script, batchMode: false), executeNow: true)
		touchProfile(profile.id)
		statusMessage = "Queued \(flavor) dev stack setup for \(profile.label)"
	}

	func queueRemoteToolAudit(on profile: SSHProfileSummary) {
		let script = #"printf 'OpenTerm remote tool audit\n'; uname -a 2>/dev/null; printf '\nPackage managers:\n'; for tool in apt apt-get apk dnf yum brew pkg; do command -v $tool >/dev/null 2>&1 && echo "$tool: $(command -v $tool)"; done; printf '\nDeveloper tools:\n'; for tool in git python3 pip3 node npm htop nano vim tmux docker; do if command -v $tool >/dev/null 2>&1; then printf '%s: ' $tool; $tool --version 2>&1 | head -n 1; else echo "$tool: missing"; fi; done"#
		openTerminal(command: sshCommand(for: profile, remoteCommand: script, batchMode: false), executeNow: true)
		touchProfile(profile.id)
		statusMessage = "Queued remote tool audit for \(profile.label)"
	}

	private func remoteDevStackScript(for flavor: String) -> String {
		let verify = "printf '\\nInstalled versions:\\n' ; git --version 2>/dev/null ; python3 --version 2>/dev/null ; node --version 2>/dev/null ; npm --version 2>/dev/null ; tmux -V 2>/dev/null"
		switch flavor {
		case "Debian/Ubuntu":
			return "set -e; sudo apt update; sudo apt install -y git python3 python3-pip nodejs npm htop nano vim tmux; \(verify)"
		case "Alpine":
			return "set -e; sudo apk add --no-cache git python3 py3-pip nodejs npm htop nano vim tmux; \(verify)"
		case "Fedora/RHEL":
			return "set -e; if command -v dnf >/dev/null 2>&1; then sudo dnf install -y git python3 python3-pip nodejs npm htop nano vim tmux; else sudo yum install -y git python3 python3-pip nodejs npm htop nano vim tmux; fi; \(verify)"
		default:
			return "set -e; if command -v apt-get >/dev/null 2>&1; then sudo apt update && sudo apt install -y git python3 python3-pip nodejs npm htop nano vim tmux; elif command -v apk >/dev/null 2>&1; then sudo apk add --no-cache git python3 py3-pip nodejs npm htop nano vim tmux; elif command -v dnf >/dev/null 2>&1; then sudo dnf install -y git python3 python3-pip nodejs npm htop nano vim tmux; elif command -v yum >/dev/null 2>&1; then sudo yum install -y git python3 python3-pip nodejs npm htop nano vim tmux; else echo 'No supported package manager found. Install git python3 pip node npm htop nano vim tmux manually.'; exit 1; fi; \(verify)"
		}
	}

	private func touchProfile(_ id: UUID) {
		guard let index = sshProfiles.firstIndex(where: { $0.id == id }) else {
			return
		}
		sshProfiles[index].lastSeen = Date()
		saveSSHProfiles()
		rebuildRecentSessions()
	}

	func sshCommand(for profile: SSHProfileSummary, remoteCommand: String? = nil, batchMode: Bool = false) -> String {
		var parts = ["ssh"]
		if batchMode {
			parts.append(contentsOf: ["-o", "BatchMode=yes", "-o", "StrictHostKeyChecking=accept-new"])
		}
		if profile.port != 22 {
			parts.append(contentsOf: ["-p", String(profile.port)])
		}
		if (profile.authKind == .key || profile.authKind == .certificate), !profile.privateKeyPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			parts.append(contentsOf: ["-i", shellQuote(profile.privateKeyPath)])
		}

		parts.append("\(profile.username)@\(profile.host)")

		var finalRemoteCommand = remoteCommand
		if finalRemoteCommand == nil, !profile.startupPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			let path = shellQuote(profile.startupPath)
			finalRemoteCommand = "cd \(path) && exec ${SHELL:-/bin/sh} -l"
		}

		if let finalRemoteCommand, !finalRemoteCommand.isEmpty {
			parts.append("-t")
			parts.append(shellQuote(finalRemoteCommand))
		}

		return parts.joined(separator: " ")
	}

	private func shellQuote(_ string: String) -> String {
		"'" + string.replacingOccurrences(of: "'", with: "'\"'\"'") + "'"
	}

	func refreshMonitorSnapshots() {
		guard !isRefreshingMonitors else {
			return
		}
		isRefreshingMonitors = true
		statusMessage = "Refreshing server snapshots"
		removeStaleServerSnapshots()

		let enabledMonitors = serverMonitors.filter { $0.isEnabled }
		guard !enabledMonitors.isEmpty else {
			isRefreshingMonitors = false
			statusMessage = "No enabled monitors configured"
			return
		}

		var pendingCount = enabledMonitors.count
		for monitor in enabledMonitors {
			refreshMonitor(monitor) {
				pendingCount -= 1
				if pendingCount == 0 {
					self.isRefreshingMonitors = false
					self.saveServerSnapshots()
					self.statusMessage = "Server snapshots updated"
					self.rebuildRecentSessions()
				}
			}
		}
	}

	private func refreshMonitor(_ monitor: ServerMonitorSummary, completion: @escaping () -> Void) {
		guard let profile = sshProfiles.first(where: { $0.id == monitor.sshProfileID }) else {
			updateSnapshot(for: monitor, snapshot: ServerSnapshotSummary(id: monitor.id, name: monitor.label, alertLevel: .unavailable, detail: "Missing SSH profile", lastChecked: Date()))
			completion()
			return
		}

		guard profile.authKind != .password else {
			updateSnapshot(for: monitor, snapshot: ServerSnapshotSummary(id: monitor.id, name: monitor.label, alertLevel: .unavailable, detail: "Password auth is interactive only. Open the terminal to connect manually.", lastChecked: Date()))
			completion()
			return
		}

		let remoteScript = "CPU=$(top -bn1 2>/dev/null | awk '/Cpu|CPU/ {for (i=1;i<=NF;i++) if ($i ~ /id,/) idle=$(i-1)} END {if (idle==\"\") print 0; else printf \"%d\", 100-idle}') ; MEM=$(awk '/MemTotal/ {total=$2} /MemAvailable/ {available=$2} END {if (total>0) printf \"%d\", ((total-available)*100)/total; else print 0}' /proc/meminfo 2>/dev/null) ; DISK=$(df -P \(shellQuote(monitor.path)) 2>/dev/null | awk 'NR==2 {gsub(/%/, \"\", $5); print $5}') ; LOAD=$(uptime 2>/dev/null | sed 's/.*load averages*[: ]*//') ; echo \"CPU:${CPU:-0}|MEM:${MEM:-0}|DISK:${DISK:-0}|LOAD:${LOAD:-n/a}\""
		let command = sshCommand(for: profile, remoteCommand: remoteScript, batchMode: true)

		commandCapture.run(command: command) { result in
			let snapshot = self.snapshot(from: result, monitor: monitor)
			self.updateSnapshot(for: monitor, snapshot: snapshot)
			completion()
		}
	}

	private func snapshot(from result: WorkspaceCommandResult, monitor: ServerMonitorSummary) -> ServerSnapshotSummary {
		guard result.status == 0, !result.stdout.isEmpty else {
			let detail = result.stderr.isEmpty ? "SSH command failed" : result.stderr
			return ServerSnapshotSummary(id: monitor.id, name: monitor.label, alertLevel: .unavailable, detail: detail, lastChecked: Date())
		}

		let segments = result.stdout.components(separatedBy: "|")
		var values = [String: String]()
		for segment in segments {
			let pair = segment.components(separatedBy: ":")
			guard pair.count >= 2 else { continue }
			values[pair[0]] = pair.dropFirst().joined(separator: ":")
		}

		let cpu = Int(values["CPU"] ?? "")
		let memory = Int(values["MEM"] ?? "")
		let disk = Int(values["DISK"] ?? "")
		let load = values["LOAD"] ?? "n/a"
		let level = alertLevel(cpu: cpu, memory: memory, disk: disk, monitor: monitor)
		let detail = "Load \(load) / thresholds C\(monitor.cpuThreshold) M\(monitor.memoryThreshold) D\(monitor.diskThreshold)"

		return ServerSnapshotSummary(id: monitor.id, name: monitor.label, cpuPercent: cpu, memoryPercent: memory, diskPercent: disk, latency: "SSH", alertLevel: level, detail: detail, lastChecked: Date())
	}

	private func alertLevel(cpu: Int?, memory: Int?, disk: Int?, monitor: ServerMonitorSummary) -> MonitorAlertLevel {
		let isAlert = (cpu ?? 0) >= monitor.cpuThreshold || (memory ?? 0) >= monitor.memoryThreshold || (disk ?? 0) >= monitor.diskThreshold
		if isAlert {
			return .alert
		}

		let isWatch = (cpu ?? 0) >= monitor.cpuThreshold - 10 || (memory ?? 0) >= monitor.memoryThreshold - 10 || (disk ?? 0) >= monitor.diskThreshold - 10
		if isWatch {
			return .watch
		}

		return .healthy
	}

	private func updateSnapshot(for monitor: ServerMonitorSummary, snapshot: ServerSnapshotSummary) {
		let previousLevel = serverSnapshots.first(where: { $0.id == monitor.id })?.alertLevel
		if let index = serverSnapshots.firstIndex(where: { $0.id == monitor.id }) {
			serverSnapshots[index] = snapshot
		} else {
			serverSnapshots.append(snapshot)
		}
		recordServerAlertIfNeeded(monitor: monitor, snapshot: snapshot, previousLevel: previousLevel)
	}

	private func recordServerAlertIfNeeded(monitor: ServerMonitorSummary, snapshot: ServerSnapshotSummary, previousLevel: MonitorAlertLevel?) {
		guard snapshot.alertLevel == .watch || snapshot.alertLevel == .alert || snapshot.alertLevel == .unavailable else { return }
		guard previousLevel != snapshot.alertLevel else { return }
		let alert = ServerAlertEvent(monitorID: monitor.id, title: "\(monitor.label) \(snapshot.alertLevel.title)", detail: snapshot.detail, level: snapshot.alertLevel)
		serverAlerts.insert(alert, at: 0)
		serverAlerts = Array(serverAlerts.prefix(50))
		saveServerAlerts()
	}

	func startMonitorAutoRefresh() {
		guard monitorTimer == nil else {
			return
		}
		monitorTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
			self?.refreshMonitorSnapshots()
		}
	}

	func stopMonitorAutoRefresh() {
		monitorTimer?.invalidate()
		monitorTimer = nil
	}

	func openFile(relativePath: String) {
		let fileURL = urlForLocalFile(relativePath: relativePath)
		guard fileURL.path.hasPrefix(documentsRootURL.path) else {
			statusMessage = "File is outside the workspace"
			return
		}
		guard let data = try? Data(contentsOf: fileURL) else {
			statusMessage = "Could not load file"
			return
		}
		guard let text = String(data: data, encoding: .utf8) else {
			statusMessage = "Only UTF-8 text files are supported right now"
			return
		}

		activeEditor = WorkspaceEditorDocument(title: fileURL.lastPathComponent, relativePath: relativePath, initialContent: text)
		statusMessage = "Editing \(fileURL.lastPathComponent)"
	}

	func createFile(named name: String, initialContent: String = "") {
		let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedName.isEmpty, !trimmedName.contains("/") else {
			statusMessage = "Enter a file name for the current folder"
			return
		}

		let newURL = currentFolderURL.appendingPathComponent(trimmedName)
		guard !fileManager.fileExists(atPath: newURL.path) else {
			statusMessage = "A file with that name already exists"
			return
		}

		guard let data = initialContent.data(using: .utf8) else {
			statusMessage = "Could not encode file contents"
			return
		}

		do {
			try data.write(to: newURL, options: .atomic)
			refreshLocalFiles()
			openFile(relativePath: relativePath(for: newURL))
		} catch {
			statusMessage = "Could not create file: \(error.localizedDescription)"
		}
	}

	func createFolder(named name: String) {
		let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedName.isEmpty, !trimmedName.contains("/") else {
			statusMessage = "Enter a folder name for the current folder"
			return
		}
		let folderURL = currentFolderURL.appendingPathComponent(trimmedName, isDirectory: true)
		do {
			try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
			refreshLocalFiles()
			statusMessage = "Created folder \(trimmedName)"
		} catch {
			statusMessage = "Could not create folder: \(error.localizedDescription)"
		}
	}

	func renameLocalFile(_ file: LocalWorkspaceFile, to newName: String) {
		let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedName.isEmpty, !trimmedName.contains("/") else {
			statusMessage = "Enter a valid name for this item"
			return
		}

		let sourceURL = urlForLocalFile(relativePath: file.relativePath)
		guard sourceURL.path.hasPrefix(documentsRootURL.path) else {
			statusMessage = "Item is outside the workspace"
			return
		}

		let destinationURL = sourceURL.deletingLastPathComponent().appendingPathComponent(trimmedName, isDirectory: file.isDirectory)
		guard !fileManager.fileExists(atPath: destinationURL.path) else {
			statusMessage = "An item with that name already exists"
			return
		}

		do {
			try fileManager.moveItem(at: sourceURL, to: destinationURL)
			refreshLocalFiles()
			refreshGitWorkspaces()
			statusMessage = "Renamed to \(trimmedName)"
		} catch {
			statusMessage = "Could not rename \(file.name): \(error.localizedDescription)"
		}
	}

	func exportLocalItem(_ file: LocalWorkspaceFile) -> URL? {
		let sourceURL = urlForLocalFile(relativePath: file.relativePath)
		guard sourceURL.path.hasPrefix(documentsRootURL.path) else {
			statusMessage = "Item is outside the workspace"
			return nil
		}

		if !file.isDirectory {
			statusMessage = "Ready to export \(file.name)"
			return sourceURL
		}

		let safeName = file.name.replacingOccurrences(of: "/", with: "-")
		let archiveURL = fileManager.temporaryDirectory.appendingPathComponent("\(safeName)-OpenTerm.tar")
		do {
			if fileManager.fileExists(atPath: archiveURL.path) {
				try fileManager.removeItem(at: archiveURL)
			}
			let archiveData = try tarArchiveData(for: sourceURL, rootName: safeName)
			try archiveData.write(to: archiveURL, options: .atomic)
			statusMessage = "Created export archive for \(file.name)"
			return archiveURL
		} catch {
			statusMessage = "Could not export \(file.name): \(error.localizedDescription)"
			return nil
		}
	}

	private func tarArchiveData(for folderURL: URL, rootName: String) throws -> Data {
		var archive = Data()
		try appendTarEntry(url: folderURL, entryName: rootName, to: &archive)
		archive.append(Data(repeating: 0, count: 1024))
		return archive
	}

	private func appendTarEntry(url: URL, entryName: String, to archive: inout Data) throws {
		let values = try url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey])
		let isDirectory = values.isDirectory ?? false
		let normalizedName = isDirectory && !entryName.hasSuffix("/") ? entryName + "/" : entryName
		let fileSize = isDirectory ? 0 : Int64(values.fileSize ?? 0)
		let modifiedAt = Int64(values.contentModificationDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970)
		archive.append(tarHeader(name: normalizedName, size: fileSize, modifiedAt: modifiedAt, isDirectory: isDirectory))

		if isDirectory {
			let children = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey], options: [.skipsHiddenFiles])
			for child in children.sorted(by: { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }) {
				try appendTarEntry(url: child, entryName: normalizedName + child.lastPathComponent, to: &archive)
			}
		} else {
			let data = try Data(contentsOf: url)
			archive.append(data)
			let padding = (512 - (data.count % 512)) % 512
			if padding > 0 { archive.append(Data(repeating: 0, count: padding)) }
		}
	}

	private func tarHeader(name: String, size: Int64, modifiedAt: Int64, isDirectory: Bool) -> Data {
		var header = [UInt8](repeating: 0, count: 512)
		writeTarString(name, into: &header, offset: 0, length: 100)
		writeTarOctal(0o644, into: &header, offset: 100, length: 8)
		writeTarOctal(0, into: &header, offset: 108, length: 8)
		writeTarOctal(0, into: &header, offset: 116, length: 8)
		writeTarOctal(size, into: &header, offset: 124, length: 12)
		writeTarOctal(modifiedAt, into: &header, offset: 136, length: 12)
		for index in 148..<156 { header[index] = 32 }
		header[156] = isDirectory ? 55 : 48
		writeTarString("ustar", into: &header, offset: 257, length: 6)
		writeTarString("00", into: &header, offset: 263, length: 2)
		let checksum = header.reduce(0) { $0 + Int($1) }
		writeTarOctal(Int64(checksum), into: &header, offset: 148, length: 8)
		return Data(header)
	}

	private func writeTarString(_ value: String, into header: inout [UInt8], offset: Int, length: Int) {
		let bytes = Array(value.utf8.prefix(length))
		for (index, byte) in bytes.enumerated() { header[offset + index] = byte }
	}

	private func writeTarOctal(_ value: Int64, into header: inout [UInt8], offset: Int, length: Int) {
		let string = String(value, radix: 8)
		let padded = String(repeating: "0", count: max(0, length - string.count - 1)) + string
		writeTarString(padded, into: &header, offset: offset, length: length - 1)
	}

	func deleteLocalFile(_ file: LocalWorkspaceFile) {
		let url = urlForLocalFile(relativePath: file.relativePath)
		guard url.path.hasPrefix(documentsRootURL.path) else { return }
		do {
			try fileManager.removeItem(at: url)
			refreshLocalFiles()
			statusMessage = "Deleted \(file.name)"
		} catch {
			statusMessage = "Could not delete \(file.name): \(error.localizedDescription)"
		}
	}

	func saveEditorDocument(relativePath: String, content: String) {
		let fileURL = urlForLocalFile(relativePath: relativePath)
		guard fileURL.path.hasPrefix(documentsRootURL.path) else {
			statusMessage = "File is outside the workspace"
			return
		}
		guard let data = content.data(using: .utf8) else {
			statusMessage = "Could not encode file contents"
			return
		}

		do {
			try data.write(to: fileURL, options: .atomic)
			refreshLocalFiles()
			statusMessage = "Saved \(fileURL.lastPathComponent)"
		} catch {
			statusMessage = "Could not save file: \(error.localizedDescription)"
		}
	}

	func closeEditor() {
		activeEditor = nil
	}


	func prepareAssistantPrompt(for tool: WorkspaceFeature) {
		switch tool.title {
		case "Explain Error":
			assistantDraft = "Explain this terminal error and give me the safest next command to try:\n\n"
		case "Generate Command":
			assistantDraft = "Turn this goal into a safe shell command. Explain any destructive risk first:\n\nGoal: "
		case "Fix Shell Script":
			assistantDraft = "Fix this shell script, explain what was broken, and return the corrected script:\n\n```sh\n\n```"
		case "SSH Troubleshooting":
			assistantDraft = "Troubleshoot this SSH issue. Ask for missing details only if required:\n\nHost:\nUser:\nPort:\nError:\n"
		case "Remote Dev Setup":
			assistantDraft = "Build a safe remote Linux setup plan for this VPS. Detect the package manager first, avoid destructive changes, and include verification commands.\n\nGoal: install Git, Python 3 + pip, Node.js + npm, htop, nano, vim, and tmux.\n\nServer OS or clues:\n"
		case "Docker Helper":
			assistantDraft = "Turn this Docker/server goal into safe commands and files. Explain ports, volumes, secrets, and rollback steps before the commands.\n\nGoal: "
		case "Git Conflict Helper":
			assistantDraft = "Help resolve this Git issue. Explain what happened, list safe inspection commands first, then provide a cautious fix plan.\n\nGit output:\n"
		case "Regex Generator":
			assistantDraft = "Generate a regex for this pattern, include test examples, and explain the groups:\n\nPattern goal: "
		default:
			assistantDraft = "Help me with this developer task: "
		}
		assistantStatus = "Loaded \(tool.title) prompt"
	}

	func insertAssistantMessageInTerminal(_ message: AssistantMessage) {
		guard message.role == "assistant" else {
			return
		}
		openTerminal(command: message.content, executeNow: false)
		statusMessage = "Inserted AI response into terminal"
	}


	func submitAssistantPrompt() {
		let prompt = assistantDraft.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !prompt.isEmpty else {
			assistantStatus = "Enter a prompt first."
			return
		}

		let resolvedEndpoint = aiConfiguration.usesHostedProxy && aiConfiguration.endpoint.isEmpty ? backendConfiguration.aiProxyEndpoint : aiConfiguration.endpoint
		guard isAIConfigured, let url = URL(string: resolvedEndpoint), !resolvedEndpoint.isEmpty else {
			assistantStatus = aiConfiguration.usesHostedProxy ? "Add Supabase URL and access token in Settings before using hosted AI." : "Add an AI endpoint and API key in Settings before using live AI."
			return
		}

		assistantMessages.append(AssistantMessage(role: "user", content: prompt, createdAt: Date()))
		assistantDraft = ""
		assistantStatus = "Requesting \(aiConfiguration.model)â¦"
		isSendingAssistantPrompt = true

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let bearerToken = aiConfiguration.apiKey.isEmpty ? backendConfiguration.accessToken : aiConfiguration.apiKey
		if !bearerToken.isEmpty {
			request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
		}

		let messages = [
			AIChatRequest.Message(role: "system", content: aiConfiguration.systemPrompt),
			AIChatRequest.Message(role: "user", content: prompt)
		]
		if aiConfiguration.usesHostedProxy {
			let body = AIProxyRequest(featureCode: "assistant", model: aiConfiguration.model, messages: messages, estimatedTokens: estimateTokenCount(for: messages), deviceID: backendConfiguration.deviceLabel)
			request.httpBody = try? JSONEncoder().encode(body)
		} else {
			let body = AIChatRequest(model: aiConfiguration.model, messages: messages)
			request.httpBody = try? JSONEncoder().encode(body)
		}

		URLSession.shared.dataTask(with: request) { data, response, error in
			DispatchQueue.main.async {
				self.isSendingAssistantPrompt = false

				if let error {
					self.assistantStatus = "AI request failed: \(error.localizedDescription)"
					self.assistantMessages.append(AssistantMessage(role: "assistant", content: self.assistantStatus, createdAt: Date()))
					return
				}

				guard let httpResponse = response as? HTTPURLResponse else {
					self.assistantStatus = "AI request failed: missing HTTP response"
					return
				}

				guard let data else {
					self.assistantStatus = "AI request failed: empty response"
					return
				}

				guard (200..<300).contains(httpResponse.statusCode) else {
					let bodyText = String(data: data, encoding: .utf8) ?? "Unknown error"
					self.assistantStatus = "AI request failed: \(bodyText)"
					self.assistantMessages.append(AssistantMessage(role: "assistant", content: self.assistantStatus, createdAt: Date()))
					return
				}

				if let decoded = try? JSONDecoder().decode(AIChatResponse.self, from: data), let content = decoded.primaryContent {
					self.assistantMessages.append(AssistantMessage(role: "assistant", content: content, createdAt: Date()))
					self.assistantStatus = "Response received from \(self.aiConfiguration.model)"
					self.aiUsageHistory.insert(AIUsageRecord(prompt: prompt, model: self.aiConfiguration.model, promptTokens: decoded.usage?.promptTokens ?? 0, completionTokens: decoded.usage?.completionTokens ?? 0), at: 0)
					self.saveAIUsageHistory()
				} else {
					let fallback = String(data: data, encoding: .utf8) ?? "AI response could not be decoded"
					self.assistantMessages.append(AssistantMessage(role: "assistant", content: fallback, createdAt: Date()))
					self.assistantStatus = "Received a non-standard AI response"
				}
			}
		}.resume()
	}

	private func rebuildRecentSessions() {
		var sessions = [WorkspaceSession]()

		for profile in sshProfiles.filter({ $0.lastSeen != nil }).prefix(2) {
			sessions.append(WorkspaceSession(title: profile.label, subtitle: "SSH / \(profile.username)@\(profile.host)", detail: "\(profile.authKind.title) / \(formatLastSeen(profile.lastSeen))", symbol: "server.rack", tint: Color(red: 0.31, green: 0.72, blue: 0.57)))
		}

		for repo in gitWorkspaces.prefix(2) {
			sessions.append(WorkspaceSession(title: repo.name, subtitle: "Git / \(repo.branch)", detail: repo.status, symbol: "point.topleft.down.curvedto.point.bottomright.up", tint: Color(red: 0.29, green: 0.57, blue: 0.95)))
		}

		if let snapshot = serverSnapshots.sorted(by: { ($0.lastChecked ?? .distantPast) > ($1.lastChecked ?? .distantPast) }).first {
			sessions.append(WorkspaceSession(title: snapshot.name, subtitle: "Monitor / \(snapshot.alertLevel.title)", detail: snapshot.detail, symbol: "waveform.path.ecg", tint: snapshot.alertLevel.tint))
		}

		recentSessions = Array(sessions.prefix(4))
	}

	func queueGitClone(remoteURL: String, folderName: String) {
		let trimmedRemote = remoteURL.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedRemote.isEmpty else {
			statusMessage = "Enter a repository URL"
			return
		}

		var command = "git clone \(shellQuote(trimmedRemote))"
		let trimmedFolder = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
		if !trimmedFolder.isEmpty {
			command += " \(shellQuote(trimmedFolder))"
		}
		openTerminal(command: gitPreflightCommand(command), executeNow: true)
		statusMessage = "Queued git clone in terminal after git availability check"
	}

	func queueGitCommand(_ command: String, in repositoryPath: String) {
		openTerminal(command: "cd \(shellQuote(repositoryPath)) && \(gitPreflightCommand(command))", executeNow: true)
		statusMessage = "Queued git command in terminal after git availability check"
	}

	private func gitPreflightCommand(_ command: String) -> String {
		"command -v git >/dev/null 2>&1 || { echo 'OpenTerm: git is not installed in this terminal environment. Use SSH remote dev setup or install/enable git first.'; exit 127; }; \(command)"
	}

	private func vaultSyncContext(from config: BackendConfiguration, updateStatus: Bool = true) -> VaultSyncContext? {
		let rpcBaseURL = config.vaultRPCBaseURL
		let anonKey = (config.anonKey ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		let accessToken = config.accessToken.trimmingCharacters(in: .whitespacesAndNewlines)
		let userID = (config.userID ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		let deviceID = (config.deviceID ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		let secret = (config.vaultSyncSecret ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		guard !rpcBaseURL.isEmpty, !anonKey.isEmpty, !accessToken.isEmpty, !userID.isEmpty, !secret.isEmpty else {
			if updateStatus {
				vaultSyncStatus = "Add Supabase URL, anon key, access token, user id, and vault sync secret first"
				statusMessage = vaultSyncStatus
			}
			return nil
		}
		return VaultSyncContext(rpcBaseURL: rpcBaseURL, anonKey: anonKey, accessToken: accessToken, userID: userID, deviceID: deviceID.isEmpty ? nil : deviceID, secret: secret)
	}

	private func applySupabaseHeaders(to request: inout URLRequest, context: VaultSyncContext) {
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue(context.anonKey, forHTTPHeaderField: "apikey")
		request.setValue("Bearer \(context.accessToken)", forHTTPHeaderField: "Authorization")
	}

	private func sendVaultRPC<T: Encodable>(function: String, body: T, context: VaultSyncContext, completion: @escaping (Bool) -> Void) {
		guard let url = URL(string: "\(context.rpcBaseURL)/\(function)") else {
			completion(false)
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		applySupabaseHeaders(to: &request, context: context)
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		request.httpBody = try? encoder.encode(body)
		URLSession.shared.dataTask(with: request) { _, response, error in
			let status = (response as? HTTPURLResponse)?.statusCode ?? 0
			completion(error == nil && (200..<300).contains(status))
		}.resume()
	}

	private func vaultSymmetricKey(from secret: String) -> SymmetricKey {
		let digest = SHA256.hash(data: Data(secret.utf8))
		return SymmetricKey(data: Data(digest))
	}

	private func encryptVaultPayload(_ data: Data, secret: String) -> VaultEncryptionResult? {
		guard let sealed = try? AES.GCM.seal(data, using: vaultSymmetricKey(from: secret)), let combined = sealed.combined else {
			return nil
		}
		let nonce = sealed.nonce.withUnsafeBytes { Data($0).base64EncodedString() }
		return VaultEncryptionResult(payloadBase64: combined.base64EncodedString(), nonceBase64: nonce)
	}

	private func decryptVaultPayload(_ data: Data, secret: String) -> Data? {
		guard let box = try? AES.GCM.SealedBox(combined: data) else { return nil }
		return try? AES.GCM.open(box, using: vaultSymmetricKey(from: secret))
	}
}

private struct VaultSyncContext {
	let rpcBaseURL: String
	let anonKey: String
	let accessToken: String
	let userID: String
	let deviceID: String?
	let secret: String
}

private struct VaultEncryptionResult {
	let payloadBase64: String
	let nonceBase64: String
}

private struct VaultSyncUpsertRequest: Encodable {
	let id: String
	let userID: String
	let deviceID: String?
	let itemKind: String
	let label: String
	let publicFingerprint: String
	let encryptedPayloadBase64: String
	let payloadNonce: String
	let keyVersion: Int
	let syncVersion: Int
	let isDeleted: Bool
	let lastUsedAt: Date?

	private enum CodingKeys: String, CodingKey {
		case id = "p_id"
		case userID = "p_user_id"
		case deviceID = "p_device_id"
		case itemKind = "p_item_kind"
		case label = "p_label"
		case publicFingerprint = "p_public_fingerprint"
		case encryptedPayloadBase64 = "p_encrypted_payload_base64"
		case payloadNonce = "p_payload_nonce"
		case keyVersion = "p_key_version"
		case syncVersion = "p_sync_version"
		case isDeleted = "p_is_deleted"
		case lastUsedAt = "p_last_used_at"
	}
}

private struct VaultSyncRemoteItem: Decodable {
	let id: String
	let itemKind: String
	let label: String
	let publicFingerprint: String?
	let encryptedPayloadBase64: String
	let payloadNonce: String
	let createdAt: Date?
	let lastUsedAt: Date?
	let updatedAt: Date?

	private enum CodingKeys: String, CodingKey {
		case id
		case itemKind = "item_kind"
		case label
		case publicFingerprint = "public_fingerprint"
		case encryptedPayloadBase64 = "encrypted_payload_base64"
		case payloadNonce = "payload_nonce"
		case createdAt = "created_at"
		case lastUsedAt = "last_used_at"
		case updatedAt = "updated_at"
	}
}

private struct AIChatRequest: Encodable {
	struct Message: Encodable {
		let role: String
		let content: String
	}

	let model: String
	let messages: [Message]
}

private func estimateTokenCount(for messages: [AIChatRequest.Message]) -> Int {
	let characterCount = messages.reduce(0) { partial, message in
		partial + message.role.count + message.content.count
	}
	return max(1, Int(ceil(Double(characterCount) / 4.0)))
}

private struct AIProxyRequest: Encodable {
	let featureCode: String
	let model: String
	let messages: [AIChatRequest.Message]
	let estimatedTokens: Int
	let deviceID: String?

	private enum CodingKeys: String, CodingKey {
		case featureCode = "feature_code"
		case model
		case messages
		case estimatedTokens = "estimated_tokens"
		case deviceID = "device_id"
	}
}

private struct AIChatResponse: Decodable {
	struct Choice: Decodable {
		struct Message: Decodable {
			let content: String?
		}

		let message: Message?
		let text: String?
	}

	struct Usage: Decodable {
		let promptTokens: Int?
		let completionTokens: Int?

		private enum CodingKeys: String, CodingKey {
			case promptTokens = "prompt_tokens"
			case completionTokens = "completion_tokens"
		}
	}

	let choices: [Choice]?
	let usage: Usage?

	var primaryContent: String? {
		choices?.compactMap { $0.message?.content ?? $0.text }.first
	}
}
