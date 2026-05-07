import SwiftUI
import UIKit

struct DeveloperWorkspaceRootView: View {

	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@StateObject private var store = WorkspaceStore.shared
	@State private var selection: WorkspaceDestination = .home

	var body: some View {
		Group {
			if horizontalSizeClass == .regular {
				regularLayout
			} else {
				compactLayout
			}
		}
		.tint(store.workspaceAccentColor)
		.onAppear {
			store.refreshLocalFiles()
			store.refreshGitWorkspaces()
		}
		.onReceive(NotificationCenter.default.publisher(for: .workspaceDidRequestTerminalFocus)) { _ in
			selection = .terminal
		}
		.onReceive(NotificationCenter.default.publisher(for: .workspaceDidRequestSettingsFocus)) { _ in
			selection = .more
		}
	}

	private var compactLayout: some View {
		TabView(selection: $selection) {
			ForEach([WorkspaceDestination.home, .files, .terminal, .servers, .more]) { destination in
				detailView(for: destination)
					.tag(destination)
					.tabItem { Label(destination.title, systemImage: destination.systemImage) }
			}
		}
		.background(WorkspaceBackdrop().ignoresSafeArea())
	}

	private var regularLayout: some View {
		NavigationSplitView {
			List {
				ForEach(WorkspaceDestination.allCases) { destination in
					Button {
						selection = destination
					} label: {
						Label(destination.title, systemImage: destination.systemImage)
					}
				}
			}
			.navigationTitle("OpenTerm")
			.scrollContentBackground(.hidden)
			.background(WorkspaceBackdrop().ignoresSafeArea())
		} detail: {
			detailView(for: selection)
				.background(WorkspaceBackdrop().ignoresSafeArea())
		}
	}

	@ViewBuilder
	private func detailView(for destination: WorkspaceDestination) -> some View {
		switch destination {
		case .home:
			NavigationStack { WorkspaceHomeView(store: store, selection: $selection) }
		case .terminal:
			LegacyTerminalContainerView()
		case .files:
			NavigationStack { FilesWorkspaceView(store: store) }
		case .git:
			NavigationStack { GitWorkspaceView(store: store, selection: $selection) }
		case .servers:
			NavigationStack { ServersWorkspaceView(store: store, selection: $selection) }
		case .assistant:
			NavigationStack { WorkspaceAssistantView(store: store) }
		case .settings:
			NavigationStack { SettingsWorkspaceView(store: store) }
		case .more:
			NavigationStack { MoreWorkspaceView(store: store, selection: $selection) }
		}
	}
}

private enum AppColor {
	static var blue: Color { Color(UserDefaultsController.shared.workspaceAccentColor) }
	static let green = Color(red: 0.31, green: 0.72, blue: 0.57)
	static let amber = Color(red: 0.98, green: 0.67, blue: 0.24)
	static let coral = Color(red: 0.91, green: 0.35, blue: 0.43)
	static let violet = Color(red: 0.55, green: 0.47, blue: 0.96)
	static let ink = Color(red: 0.08, green: 0.10, blue: 0.15)
}

private struct WorkspaceHomeView: View {

	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination

	var body: some View {
		WorkspaceScroll(title: "OpenTerm") {
			HeroPanel(store: store, selection: $selection)
			QuickActionGrid(store: store, selection: $selection)
			SectionHeader(title: "Live Workspace", subtitle: "Recent SSH, Git, monitor, and terminal activity.")
			AdaptiveGrid {
				ForEach(store.recentSessions) { session in
					SessionCard(session: session)
				}
			}
			SectionHeader(title: "Built In", subtitle: "Useful now, designed to grow into a complete mobile developer workspace.")
			AdaptiveGrid {
				ForEach(store.featuredCapabilities) { feature in
					WorkspaceFeatureCard(feature: feature)
				}
			}
		}
		.toolbar {
			ToolbarItemGroup(placement: .topBarTrailing) {
				Button { selection = .assistant } label: { Image(systemName: "sparkles") }
				Button { selection = .terminal } label: { Image(systemName: "terminal") }
			}
		}
	}
}

private struct QuickActionGrid: View {
	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			SectionHeader(title: "Quick Actions", subtitle: "One-tap entry points into the real workspace flows.")
			AdaptiveGrid {
				ActionTile(title: "New Terminal", subtitle: "Open the shell", symbol: "terminal", tint: AppColor.blue) { selection = .terminal }
				ActionTile(title: "Refresh Monitors", subtitle: "Poll SSH health", symbol: "waveform.path.ecg", tint: AppColor.green) { store.refreshMonitorSnapshots() }
				ActionTile(title: "Git Status", subtitle: "Scan repos", symbol: "point.topleft.down.curvedto.point.bottomright.up", tint: AppColor.violet) {
					store.refreshGitWorkspaces()
					selection = .git
				}
				ActionTile(title: "Ask AI", subtitle: "Command help", symbol: "sparkles", tint: AppColor.amber) { selection = .assistant }
			}
		}
	}
}

private struct FilesWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore
	@State private var newFileName = ""
	@State private var showingNewFile = false

	var body: some View {
		WorkspaceScroll(title: "Files") {
			WorkspaceSummaryBanner(title: "Local Files", detail: "Browse the app documents folder, open UTF-8 files, save edits, and run reusable shell snippets.", tint: AppColor.amber)

			VStack(alignment: .leading, spacing: 12) {
				SectionHeader(title: "Documents", subtitle: "Folders are shown for navigation context; text files open in the editor.")
				ForEach(store.localFiles) { file in
					FileRow(file: file) {
						if !file.isDirectory {
							store.openFile(relativePath: file.relativePath)
						}
					}
				}
			}

			VStack(alignment: .leading, spacing: 12) {
				SectionHeader(title: "Snippets", subtitle: "Saved commands can run straight in the active terminal tab.")
				ForEach(store.snippets) { snippet in
					SnippetRow(snippet: snippet) {
						store.runSnippetInTerminal(snippet)
					}
				}
			}
		}
		.toolbar {
			ToolbarItemGroup(placement: .topBarTrailing) {
				Button { showingNewFile = true } label: { Image(systemName: "doc.badge.plus") }
				Button { store.refreshLocalFiles() } label: { Image(systemName: "arrow.clockwise") }
			}
		}
		.sheet(item: $store.activeEditor) { document in
			WorkspaceEditorSheet(document: document, store: store)
		}
		.alert("New File", isPresented: $showingNewFile) {
			TextField("script.sh", text: $newFileName)
			Button("Create") {
				store.createFile(named: newFileName, initialContent: "#!/bin/sh\n")
				newFileName = ""
			}
			Button("Cancel", role: .cancel) { newFileName = "" }
		}
	}
}

private struct GitWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination
	@State private var cloneURL = ""
	@State private var cloneFolder = ""
	@State private var commitMessage = "Update from OpenTerm"

	var body: some View {
		WorkspaceScroll(title: "Git") {
			WorkspaceSummaryBanner(title: "Terminal Git", detail: "Repositories are detected locally. Clone, pull, commit, and push are queued into the terminal because this fork does not bundle a native Git engine yet.", tint: AppColor.violet)

			VStack(alignment: .leading, spacing: 12) {
				SectionHeader(title: "Clone", subtitle: "Runs git clone inside the terminal session.")
				TextField("https://github.com/org/repo.git", text: $cloneURL)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
					.textFieldStyle(.roundedBorder)
				TextField("Optional folder", text: $cloneFolder)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
					.textFieldStyle(.roundedBorder)
				PrimaryWorkspaceButton(title: "Clone Repository", symbol: "square.and.arrow.down", tint: AppColor.violet) {
					store.queueGitClone(remoteURL: cloneURL, folderName: cloneFolder)
					selection = .terminal
				}
			}
			.padding(18)
			.background(WorkspaceCardBackground(tint: AppColor.violet))

			ForEach(store.gitWorkspaces) { repo in
				GitRepoCard(repo: repo, commitMessage: $commitMessage) { command in
					store.queueGitCommand(command, in: repo.path)
					selection = .terminal
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button { store.refreshGitWorkspaces() } label: { Image(systemName: "arrow.clockwise") }
			}
		}
	}
}

private struct ServersWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination
	@State private var editingProfile: SSHProfileDraft?
	@State private var editingMonitor: ServerMonitorDraft?
	@State private var importingVaultKey = false

	var body: some View {
		WorkspaceScroll(title: "Servers") {
			WorkspaceSummaryBanner(title: "SSH + Monitoring", detail: "Profiles persist locally, quick connect runs real ssh commands, and monitors poll Linux hosts over noninteractive SSH.", tint: AppColor.green)

			SectionHeader(title: "SSH Profiles", subtitle: "Manage hosts, ports, auth type, key path, and startup folder.")
			ForEach(store.sshProfiles) { profile in
				SSHProfileCard(profile: profile, lastSeen: store.formatLastSeen(profile.lastSeen)) {
					store.connect(to: profile)
					selection = .terminal
				} edit: {
					editingProfile = SSHProfileDraft(profile: profile)
				} delete: {
					store.deleteSSHProfile(profile)
				}
			}

			SectionHeader(title: "SSH Key Vault", subtitle: "Local protected key storage. Cloud E2E sync is still a later backend step.")
			ForEach(store.sshVaultItems) { item in
				SSHVaultItemCard(item: item, profiles: store.sshProfiles) { profile in
					store.attachVaultItem(item, to: profile)
				} delete: {
					store.deleteSSHVaultItem(item)
				}
			}

			SectionHeader(title: "Server Monitors", subtitle: "CPU, memory, disk, and load snapshots from saved SSH profiles.")
			if store.isRefreshingMonitors {
				ProgressView("Refreshing")
					.tint(.white)
					.foregroundStyle(.white)
			}
			AdaptiveGrid {
				ForEach(store.serverSnapshots) { snapshot in
					ServerSnapshotCard(snapshot: snapshot)
				}
			}
		}
		.toolbar {
			ToolbarItemGroup(placement: .topBarTrailing) {
				Button { editingProfile = SSHProfileDraft(profile: nil) } label: { Image(systemName: "server.rack") }
				Button { importingVaultKey = true } label: { Image(systemName: "key") }
				Button {
					if let profile = store.sshProfiles.first {
						editingMonitor = ServerMonitorDraft(profileID: profile.id)
					}
				} label: { Image(systemName: "waveform.path.ecg") }
				Button { store.refreshMonitorSnapshots() } label: { Image(systemName: "arrow.clockwise") }
			}
		}
		.onAppear { store.startMonitorAutoRefresh() }
		.onDisappear { store.stopMonitorAutoRefresh() }
		.sheet(item: $editingProfile) { draft in
			SSHProfileEditorSheet(draft: draft) { profile in
				store.upsertSSHProfile(profile)
			}
		}
		.sheet(item: $editingMonitor) { draft in
			ServerMonitorEditorSheet(draft: draft, profiles: store.sshProfiles) { monitor in
				store.upsertServerMonitor(monitor)
				store.refreshMonitorSnapshots()
			}
		}
		.sheet(isPresented: $importingVaultKey) {
			SSHVaultImportSheet { label, key in
				store.importSSHKeyToVault(label: label, privateKey: key)
			}
		}
	}
}

private struct WorkspaceAssistantView: View {

	@ObservedObject var store: WorkspaceStore

	var body: some View {
		WorkspaceScroll(title: "AI") {
			WorkspaceSummaryBanner(title: "AI Command Center", detail: store.assistantStatus, tint: AppColor.violet)

			VStack(alignment: .leading, spacing: 12) {
				TextField("Explain this error, generate a command, fix this script", text: $store.assistantDraft, axis: .vertical)
					.textFieldStyle(.roundedBorder)
					.lineLimit(3...6)
				PrimaryWorkspaceButton(title: store.isSendingAssistantPrompt ? "Sending" : "Send Prompt", symbol: "paperplane.fill", tint: AppColor.violet) {
					store.submitAssistantPrompt()
				}
				.disabled(store.isSendingAssistantPrompt)
			}
			.padding(18)
			.background(WorkspaceCardBackground(tint: AppColor.violet))

			ForEach(store.assistantMessages) { message in
				AssistantBubble(message: message) {
					store.insertAssistantMessageInTerminal(message)
				}
			}

			SectionHeader(title: "Tools", subtitle: "Prompt shortcuts for terminal, SSH, Docker, Git, regex, and code help.")
			AdaptiveGrid {
				ForEach(store.aiTools) { tool in
					AssistantToolCard(feature: tool) {
						store.prepareAssistantPrompt(for: tool)
					}
				}
			}
		}
	}
}

private struct MoreWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination

	var body: some View {
		WorkspaceScroll(title: "More") {
			WorkspaceSummaryBanner(title: "Command Center", detail: "AI, Git, Settings, themes, terminal appearance, and workspace maintenance live here instead of Apple's automatic overflow screen.", tint: store.workspaceAccentColor)

			AdaptiveGrid {
				ActionTile(title: "AI Assistant", subtitle: "Explain errors and generate commands", symbol: "sparkles", tint: AppColor.violet) { selection = .assistant }
				ActionTile(title: "Git Workspace", subtitle: "Clone, pull, commit, and push", symbol: "point.topleft.down.curvedto.point.bottomright.up", tint: AppColor.blue) { selection = .git }
				ActionTile(title: "Settings", subtitle: "Theme, terminal, AI, and defaults", symbol: "slider.horizontal.3", tint: store.workspaceAccentColor) { selection = .settings }
				ActionTile(title: "Refresh", subtitle: "Files, repos, and monitors", symbol: "arrow.clockwise", tint: AppColor.green) {
					store.refreshLocalFiles()
					store.refreshGitWorkspaces()
					store.refreshMonitorSnapshots()
				}
			}

			SettingsWorkspaceView(store: store)
		}
	}
}

private struct SettingsWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore
	@State private var endpoint = ""
	@State private var model = ""
	@State private var apiKey = ""
	@State private var systemPrompt = ""
	@State private var useHostedProxy = false
	@State private var appAccent = Color(UserDefaultsController.shared.workspaceAccentColor)
	@State private var terminalText = Color(UserDefaultsController.shared.terminalTextColor)
	@State private var terminalBackground = Color(UserDefaultsController.shared.terminalBackgroundColor)
	@State private var terminalFontSize = Double(UserDefaultsController.shared.terminalFontSize)
	@State private var useDarkKeyboard = UserDefaultsController.shared.useDarkKeyboard
	@State private var caretStyle = UserDefaultsController.shared.caretStyle

	var body: some View {
		VStack(alignment: .leading, spacing: 22) {
			WorkspaceSummaryBanner(title: "Settings", detail: store.freeModeSummary, tint: store.workspaceAccentColor)

			ThemeSettingsCard(store: store, appAccent: $appAccent, terminalText: $terminalText, terminalBackground: $terminalBackground)

			VStack(alignment: .leading, spacing: 14) {
				SectionHeader(title: "Terminal", subtitle: "These controls update the actual shell, not a preview.")
				Slider(value: $terminalFontSize, in: 10...28, step: 1) {
					Text("Font size")
				} minimumValueLabel: {
					Text("10")
						.foregroundStyle(.white.opacity(0.6))
				} maximumValueLabel: {
					Text("28")
						.foregroundStyle(.white.opacity(0.6))
				}
				.onChange(of: terminalFontSize) { newValue in
					store.updateTerminalFontSize(newValue)
				}
				Text("Font size: \(Int(terminalFontSize)) pt")
					.font(.system(.footnote, design: .rounded, weight: .semibold))
					.foregroundStyle(.white.opacity(0.72))

				Picker("Cursor", selection: $caretStyle) {
					Text("Bar").tag(CaretStyle.verticalBar)
					Text("Block").tag(CaretStyle.block)
					Text("Line").tag(CaretStyle.underline)
				}
				.pickerStyle(.segmented)
				.onChange(of: caretStyle) { newValue in
					store.updateCaretStyle(newValue)
				}

				Toggle("Dark keyboard", isOn: $useDarkKeyboard)
					.tint(store.workspaceAccentColor)
					.foregroundStyle(.white)
					.onChange(of: useDarkKeyboard) { newValue in
						store.updateUseDarkKeyboard(newValue)
					}
			}
			.padding(18)
			.background(WorkspaceCardBackground(tint: store.workspaceAccentColor))

			VStack(alignment: .leading, spacing: 12) {
				SectionHeader(title: "AI Provider", subtitle: "OpenAI-compatible chat endpoint. Keys stay local in this preview build.")
				TextField("Endpoint URL", text: $endpoint)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
					.textFieldStyle(.roundedBorder)
				TextField("Model", text: $model)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
					.textFieldStyle(.roundedBorder)
				SecureField("API key", text: $apiKey)
					.textFieldStyle(.roundedBorder)
				TextField("System prompt", text: $systemPrompt, axis: .vertical)
					.textFieldStyle(.roundedBorder)
					.lineLimit(3...6)
				Toggle("Use hosted AI proxy", isOn: $useHostedProxy)
					.tint(store.workspaceAccentColor)
					.foregroundStyle(.white)
				Text(useHostedProxy ? "Endpoint should be your Supabase ai-proxy function URL. API key should be the user's Supabase bearer token." : "Endpoint should be an OpenAI-compatible chat completions URL. API key is sent as a bearer token.")
					.font(.system(.footnote, design: .rounded))
					.foregroundStyle(.white.opacity(0.62))
				PrimaryWorkspaceButton(title: "Save AI Settings", symbol: "checkmark.seal", tint: store.workspaceAccentColor) {
					store.updateAIConfiguration(endpoint: endpoint, model: model, apiKey: apiKey, systemPrompt: systemPrompt, useHostedProxy: useHostedProxy)
				}
			}
			.padding(18)
			.background(WorkspaceCardBackground(tint: AppColor.violet))

			VStack(alignment: .leading, spacing: 12) {
				SectionHeader(title: "Backup", subtitle: "Export workspace metadata without raw private-key contents.")
				Text(store.lastBackupPath)
					.font(.system(.footnote, design: .monospaced))
					.foregroundStyle(.white.opacity(0.66))
				PrimaryWorkspaceButton(title: "Export Backup", symbol: "square.and.arrow.up", tint: AppColor.green) {
					store.exportWorkspaceBackup()
				}
			}
			.padding(18)
			.background(WorkspaceCardBackground(tint: AppColor.green))

			AdaptiveGrid {
				MetricCard(title: "Theme", value: store.activeThemeName, symbol: "paintpalette", tint: store.workspaceAccentColor)
				MetricCard(title: "AI Requests", value: "\(store.aiUsageHistory.count)", symbol: "chart.bar", tint: AppColor.violet)
				MetricCard(title: "SSH Profiles", value: "\(store.sshProfiles.count)", symbol: "server.rack", tint: AppColor.green)
				MetricCard(title: "Git Repos", value: "\(store.gitWorkspaces.count)", symbol: "point.topleft.down.curvedto.point.bottomright.up", tint: AppColor.blue)
			}
		}
		.onAppear {
			endpoint = store.aiConfiguration.endpoint
			model = store.aiConfiguration.model
			apiKey = store.aiConfiguration.apiKey
			systemPrompt = store.aiConfiguration.systemPrompt
			useHostedProxy = store.aiConfiguration.usesHostedProxy
			appAccent = store.workspaceAccentColor
			terminalText = Color(UserDefaultsController.shared.terminalTextColor)
			terminalBackground = Color(UserDefaultsController.shared.terminalBackgroundColor)
			terminalFontSize = Double(UserDefaultsController.shared.terminalFontSize)
			useDarkKeyboard = UserDefaultsController.shared.useDarkKeyboard
			caretStyle = UserDefaultsController.shared.caretStyle
		}
	}
}

private struct ThemeSettingsCard: View {
	@ObservedObject var store: WorkspaceStore
	@Binding var appAccent: Color
	@Binding var terminalText: Color
	@Binding var terminalBackground: Color

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			SectionHeader(title: "Live Color System", subtitle: "This is the real app theme control. Drag the color wheels and the workspace updates immediately.")
			ColorPicker("App accent", selection: $appAccent, supportsOpacity: false)
				.foregroundStyle(.white)
				.onChange(of: appAccent) { newValue in
					store.updateWorkspaceAccent(newValue)
				}
			ColorPicker("Terminal text", selection: $terminalText, supportsOpacity: false)
				.foregroundStyle(.white)
				.onChange(of: terminalText) { newValue in
					store.updateTerminalTextColor(newValue)
				}
			ColorPicker("Terminal background", selection: $terminalBackground, supportsOpacity: false)
				.foregroundStyle(.white)
				.onChange(of: terminalBackground) { newValue in
					store.updateTerminalBackgroundColor(newValue)
				}
		}
		.padding(18)
		.background(WorkspaceCardBackground(tint: store.workspaceAccentColor))
	}
}

private struct WorkspaceScroll<Content: View>: View {
	let title: String
	@ViewBuilder let content: Content

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 22) {
				content
			}
			.padding(20)
			.padding(.bottom, 34)
		}
		.background(WorkspaceBackdrop().ignoresSafeArea())
		.navigationTitle(title)
	}
}

private struct HeroPanel: View {
	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination

	var body: some View {
		VStack(alignment: .leading, spacing: 18) {
			Text("OpenTerm")
				.font(.system(.largeTitle, design: .rounded, weight: .bold))
				.foregroundStyle(.white)
			Text("A fast iPhone and iPad developer workspace for terminal sessions, SSH, files, Git, server checks, and command-aware AI.")
				.font(.system(.body, design: .rounded))
				.foregroundStyle(.white.opacity(0.78))
			HStack(spacing: 12) {
				PrimaryWorkspaceButton(title: "Terminal", symbol: "terminal", tint: store.workspaceAccentColor) { selection = .terminal }
				PrimaryWorkspaceButton(title: "Servers", symbol: "server.rack", tint: AppColor.green) { selection = .servers }
			}
			HStack(spacing: 12) {
				WorkspaceStatPill(title: "iOS", value: "18+")
				WorkspaceStatPill(title: "SDK", value: "26.4")
				WorkspaceStatPill(title: "Mode", value: "Free")
			}
		}
		.padding(24)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(WorkspaceCardBackground(tint: AppColor.blue))
	}
}

private struct SectionHeader: View {
	let title: String
	let subtitle: String

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(title)
				.font(.system(.title3, design: .rounded, weight: .semibold))
				.foregroundStyle(.white)
			Text(subtitle)
				.font(.system(.subheadline, design: .rounded))
				.foregroundStyle(.white.opacity(0.72))
		}
	}
}

private struct AdaptiveGrid<Content: View>: View {
	@ViewBuilder let content: Content

	var body: some View {
		LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
			content
		}
	}
}

private struct ActionTile: View {
	let title: String
	let subtitle: String
	let symbol: String
	let tint: Color
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			VStack(alignment: .leading, spacing: 10) {
				Image(systemName: symbol)
					.font(.system(size: 20, weight: .semibold))
					.foregroundStyle(tint)
				Text(title)
					.font(.system(.headline, design: .rounded, weight: .semibold))
					.foregroundStyle(.white)
				Text(subtitle)
					.font(.system(.subheadline, design: .rounded))
					.foregroundStyle(.white.opacity(0.70))
			}
			.padding(18)
			.frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
			.background(WorkspaceCardBackground(tint: tint))
		}
		.buttonStyle(.plain)
	}
}

private struct PrimaryWorkspaceButton: View {
	let title: String
	let symbol: String
	let tint: Color
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Label(title, systemImage: symbol)
				.font(.system(.headline, design: .rounded, weight: .semibold))
				.frame(maxWidth: .infinity)
		}
		.buttonStyle(.borderedProminent)
		.tint(tint)
	}
}

private struct WorkspaceSummaryBanner: View {
	let title: String
	let detail: String
	let tint: Color

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(title)
				.font(.system(.title2, design: .rounded, weight: .bold))
				.foregroundStyle(.white)
			Text(detail)
				.font(.system(.body, design: .rounded))
				.foregroundStyle(.white.opacity(0.74))
		}
		.padding(20)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(WorkspaceCardBackground(tint: tint))
	}
}

private struct SessionCard: View {
	let session: WorkspaceSession

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Image(systemName: session.symbol)
				.font(.system(size: 20, weight: .semibold))
				.foregroundStyle(session.tint)
			Text(session.title)
				.font(.system(.headline, design: .rounded, weight: .semibold))
				.foregroundStyle(.white)
			Text(session.subtitle)
				.font(.system(.subheadline, design: .rounded))
				.foregroundStyle(.white.opacity(0.72))
			Text(session.detail)
				.font(.system(.footnote, design: .rounded))
				.foregroundStyle(.white.opacity(0.62))
		}
		.padding(18)
		.frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
		.background(WorkspaceCardBackground(tint: session.tint))
	}
}

private struct WorkspaceFeatureCard: View {
	let feature: WorkspaceFeature

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Image(systemName: feature.symbol)
				.font(.system(size: 18, weight: .semibold))
				.foregroundStyle(feature.tint)
				.frame(width: 40, height: 40)
				.background(feature.tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
			Text(feature.title)
				.font(.system(.headline, design: .rounded, weight: .semibold))
				.foregroundStyle(.white)
			Text(feature.detail)
				.font(.system(.subheadline, design: .rounded))
				.foregroundStyle(.white.opacity(0.74))
		}
		.padding(18)
		.frame(maxWidth: .infinity, minHeight: 158, alignment: .topLeading)
		.background(WorkspaceCardBackground(tint: feature.tint))
	}
}

private struct FileRow: View {
	let file: LocalWorkspaceFile
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			HStack(spacing: 12) {
				Image(systemName: file.isDirectory ? "folder.fill" : "doc.text")
					.foregroundStyle(file.isDirectory ? AppColor.blue : .white.opacity(0.78))
				VStack(alignment: .leading, spacing: 4) {
					Text(file.name)
						.font(.system(.headline, design: .rounded, weight: .semibold))
						.foregroundStyle(.white)
					Text(file.relativePath)
						.font(.system(.footnote, design: .monospaced))
						.foregroundStyle(.white.opacity(0.62))
					Text("\(file.sizeDescription) / \(file.modifiedDescription)")
						.font(.system(.footnote, design: .rounded))
						.foregroundStyle(.white.opacity(0.56))
				}
				Spacer()
			}
			.padding(16)
			.background(WorkspaceCardBackground(tint: file.isDirectory ? AppColor.blue : AppColor.amber))
		}
		.buttonStyle(.plain)
	}
}

private struct SnippetRow: View {
	let snippet: WorkspaceSnippet
	let run: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Text(snippet.title)
					.font(.system(.headline, design: .rounded, weight: .semibold))
					.foregroundStyle(.white)
				Spacer()
				Text(snippet.category)
					.font(.system(.caption, design: .rounded, weight: .semibold))
					.foregroundStyle(AppColor.amber)
			}
			Text(snippet.body)
				.font(.system(.footnote, design: .monospaced))
				.foregroundStyle(.white.opacity(0.70))
			PrimaryWorkspaceButton(title: "Run", symbol: "play.fill", tint: AppColor.amber, action: run)
		}
		.padding(16)
		.background(WorkspaceCardBackground(tint: AppColor.amber))
	}
}

private struct GitRepoCard: View {
	let repo: GitWorkspaceSummary
	@Binding var commitMessage: String
	let run: (String) -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(repo.name)
				.font(.system(.title3, design: .rounded, weight: .semibold))
				.foregroundStyle(.white)
			Text(repo.path)
				.font(.system(.footnote, design: .monospaced))
				.foregroundStyle(.white.opacity(0.58))
			HStack(spacing: 10) {
				MetricPill(title: "Branch", value: repo.branch)
				MetricPill(title: "State", value: repo.status)
			}
			TextField("Commit message", text: $commitMessage)
				.textFieldStyle(.roundedBorder)
			LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
				PrimaryWorkspaceButton(title: "Status", symbol: "list.bullet", tint: AppColor.blue) { run("git status") }
				PrimaryWorkspaceButton(title: "Pull", symbol: "arrow.down.circle", tint: AppColor.green) { run("git pull") }
				PrimaryWorkspaceButton(title: "Commit", symbol: "checkmark.circle", tint: AppColor.amber) { run("git add -A && git commit -m '\(commitMessage.replacingOccurrences(of: "'", with: "'\\''"))'") }
				PrimaryWorkspaceButton(title: "Push", symbol: "arrow.up.circle", tint: AppColor.violet) { run("git push") }
			}
		}
		.padding(18)
		.background(WorkspaceCardBackground(tint: AppColor.violet))
	}
}

private struct SSHProfileCard: View {
	let profile: SSHProfileSummary
	let lastSeen: String
	let connect: () -> Void
	let edit: () -> Void
	let delete: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack(alignment: .top) {
				VStack(alignment: .leading, spacing: 5) {
					Text(profile.label)
						.font(.system(.title3, design: .rounded, weight: .semibold))
						.foregroundStyle(.white)
					Text("\(profile.username)@\(profile.host):\(profile.port)")
						.font(.system(.subheadline, design: .monospaced))
						.foregroundStyle(.white.opacity(0.72))
					Text("\(profile.authKind.title) / Last used \(lastSeen)")
						.font(.system(.footnote, design: .rounded))
						.foregroundStyle(.white.opacity(0.62))
				}
				Spacer()
				Button(role: .destructive, action: delete) { Image(systemName: "trash") }
			}
			HStack(spacing: 10) {
				PrimaryWorkspaceButton(title: "Connect", symbol: "bolt.horizontal.circle", tint: AppColor.green, action: connect)
				PrimaryWorkspaceButton(title: "Edit", symbol: "slider.horizontal.3", tint: AppColor.blue, action: edit)
			}
		}
		.padding(18)
		.background(WorkspaceCardBackground(tint: AppColor.green))
	}
}

private struct SSHVaultItemCard: View {
	let item: SSHVaultItem
	let profiles: [SSHProfileSummary]
	let attach: (SSHProfileSummary) -> Void
	let delete: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack(alignment: .top) {
				VStack(alignment: .leading, spacing: 5) {
					Text(item.label)
						.font(.system(.headline, design: .rounded, weight: .semibold))
						.foregroundStyle(.white)
					Text(item.fingerprint)
						.font(.system(.footnote, design: .monospaced))
						.foregroundStyle(.white.opacity(0.62))
				}
				Spacer()
				Button(role: .destructive, action: delete) { Image(systemName: "trash") }
			}
			if profiles.isEmpty {
				Text("Create an SSH profile before attaching this key.")
					.font(.system(.footnote, design: .rounded))
					.foregroundStyle(.white.opacity(0.64))
			} else {
				Menu {
					ForEach(profiles) { profile in
						Button(profile.label) { attach(profile) }
					}
				} label: {
					Label("Attach to Profile", systemImage: "link")
						.font(.system(.headline, design: .rounded, weight: .semibold))
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
				.tint(AppColor.green)
			}
		}
		.padding(18)
		.background(WorkspaceCardBackground(tint: AppColor.green))
	}
}

private struct SSHVaultImportSheet: View {
	@Environment(\.dismiss) private var dismiss
	@State private var label = ""
	@State private var privateKey = ""
	let importKey: (String, String) -> Void

	var body: some View {
		NavigationStack {
			Form {
				TextField("Key label", text: $label)
				TextField("Paste private key", text: $privateKey, axis: .vertical)
					.lineLimit(8...18)
				Text("Keys are stored locally with iOS file protection. Cloud E2E vault sync is not enabled yet.")
					.font(.footnote)
					.foregroundStyle(.secondary)
			}
			.navigationTitle("Import SSH Key")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
				ToolbarItem(placement: .confirmationAction) {
					Button("Import") {
						importKey(label, privateKey)
						dismiss()
					}
				}
			}
		}
	}
}

private struct ServerSnapshotCard: View {
	let snapshot: ServerSnapshotSummary

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Text(snapshot.name)
					.font(.system(.headline, design: .rounded, weight: .semibold))
					.foregroundStyle(.white)
				Spacer()
				Text(snapshot.alertLevel.title)
					.font(.system(.caption, design: .rounded, weight: .bold))
					.foregroundStyle(snapshot.alertLevel.tint)
			}
			HStack(spacing: 8) {
				MetricPill(title: "CPU", value: percent(snapshot.cpuPercent))
				MetricPill(title: "RAM", value: percent(snapshot.memoryPercent))
				MetricPill(title: "Disk", value: percent(snapshot.diskPercent))
			}
			Text(snapshot.detail)
				.font(.system(.footnote, design: .rounded))
				.foregroundStyle(.white.opacity(0.66))
		}
		.padding(18)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(WorkspaceCardBackground(tint: snapshot.alertLevel.tint))
	}

	private func percent(_ value: Int?) -> String {
		guard let value else { return "--" }
		return "\(value)%"
	}
}

private struct AssistantBubble: View {
	let message: AssistantMessage
	let insertInTerminal: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Text(message.role.uppercased())
					.font(.system(.caption, design: .rounded, weight: .bold))
					.foregroundStyle(message.role == "assistant" ? AppColor.violet : AppColor.green)
				Spacer()
				if message.role == "assistant" {
					Button(action: insertInTerminal) {
						Label("Terminal", systemImage: "terminal")
							.font(.system(.caption, design: .rounded, weight: .semibold))
					}
					.buttonStyle(.bordered)
				}
			}
			Text(message.content)
				.font(.system(.body, design: message.content.contains("$") ? .monospaced : .rounded))
				.foregroundStyle(.white.opacity(0.82))
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(WorkspaceCardBackground(tint: message.role == "assistant" ? AppColor.violet : AppColor.green))
	}
}

private struct AssistantToolCard: View {
	let feature: WorkspaceFeature
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			WorkspaceFeatureCard(feature: feature)
		}
		.buttonStyle(.plain)
	}
}

private struct MetricCard: View {
	let title: String
	let value: String
	let symbol: String
	let tint: Color

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Image(systemName: symbol)
				.foregroundStyle(tint)
			Text(value)
				.font(.system(.title2, design: .rounded, weight: .bold))
				.foregroundStyle(.white)
			Text(title)
				.font(.system(.subheadline, design: .rounded))
				.foregroundStyle(.white.opacity(0.64))
		}
		.padding(18)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(WorkspaceCardBackground(tint: tint))
	}
}

private struct MetricPill: View {
	let title: String
	let value: String

	var body: some View {
		VStack(alignment: .leading, spacing: 3) {
			Text(title.uppercased())
				.font(.system(size: 10, weight: .bold, design: .rounded))
				.foregroundStyle(.white.opacity(0.48))
			Text(value)
				.font(.system(.caption, design: .rounded, weight: .semibold))
				.foregroundStyle(.white)
		}
		.padding(.horizontal, 10)
		.padding(.vertical, 8)
		.background(Color.white.opacity(0.08), in: Capsule())
	}
}

private struct WorkspaceStatPill: View {
	let title: String
	let value: String

	var body: some View {
		MetricPill(title: title, value: value)
	}
}

private struct WorkspaceEditorSheet: View {
	let document: WorkspaceEditorDocument
	@ObservedObject var store: WorkspaceStore
	@State private var text: String
	@State private var searchQuery = ""

	init(document: WorkspaceEditorDocument, store: WorkspaceStore) {
		self.document = document
		self.store = store
		_text = State(initialValue: document.initialContent)
	}

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				VStack(alignment: .leading, spacing: 12) {
					HStack(spacing: 10) {
						MetricPill(title: "Language", value: languageName)
						MetricPill(title: "Lines", value: "\(text.components(separatedBy: .newlines).count)")
						MetricPill(title: "Matches", value: "\(matchCount)")
						Spacer()
					}

					TextField("Search in \(document.title)", text: $searchQuery)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
						.textFieldStyle(.roundedBorder)
				}
				.padding(.horizontal, 16)
				.padding(.vertical, 12)
				.background(AppColor.ink.opacity(0.96))

				HighlightedCodeEditor(text: $text, language: languageName, searchQuery: searchQuery)
			}
			.background(AppColor.ink.ignoresSafeArea())
			.navigationTitle(document.title)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Close") { store.closeEditor() }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") { store.saveEditorDocument(relativePath: document.relativePath, content: text) }
				}
			}
		}
	}

	private var matchCount: Int {
		let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !query.isEmpty else { return 0 }
		return text.lowercased().components(separatedBy: query.lowercased()).count - 1
	}

	private var languageName: String {
		let ext = (document.title as NSString).pathExtension.lowercased()
		switch ext {
		case "sh", "bash", "zsh": return "Shell"
		case "swift": return "Swift"
		case "js", "mjs", "cjs": return "JavaScript"
		case "json": return "JSON"
		case "md", "markdown": return "Markdown"
		case "py": return "Python"
		case "yml", "yaml": return "YAML"
		default: return "Text"
		}
	}
}

private struct HighlightedCodeEditor: UIViewRepresentable {
	@Binding var text: String
	let language: String
	let searchQuery: String

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	func makeUIView(context: Context) -> UITextView {
		let textView = UITextView()
		textView.delegate = context.coordinator
		textView.backgroundColor = UIColor(red: 0.06, green: 0.08, blue: 0.11, alpha: 1)
		textView.keyboardAppearance = .dark
		textView.autocorrectionType = .no
		textView.autocapitalizationType = .none
		textView.smartDashesType = .no
		textView.smartQuotesType = .no
		textView.textContainerInset = UIEdgeInsets(top: 18, left: 16, bottom: 28, right: 16)
		textView.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
		textView.alwaysBounceVertical = true
		context.coordinator.applyHighlighting(to: textView, text: text, language: language, searchQuery: searchQuery)
		return textView
	}

	func updateUIView(_ textView: UITextView, context: Context) {
		guard textView.text != text || context.coordinator.language != language || context.coordinator.searchQuery != searchQuery else {
			return
		}
		context.coordinator.applyHighlighting(to: textView, text: text, language: language, searchQuery: searchQuery)
	}

	final class Coordinator: NSObject, UITextViewDelegate {
		private let parent: HighlightedCodeEditor
		var language: String
		var searchQuery: String
		private var isApplyingHighlighting = false

		init(_ parent: HighlightedCodeEditor) {
			self.parent = parent
			self.language = parent.language
			self.searchQuery = parent.searchQuery
		}

		func textViewDidChange(_ textView: UITextView) {
			parent.text = textView.text
			applyHighlighting(to: textView, text: textView.text, language: parent.language, searchQuery: parent.searchQuery)
		}

		func applyHighlighting(to textView: UITextView, text: String, language: String, searchQuery: String) {
			guard !isApplyingHighlighting else { return }
			isApplyingHighlighting = true
			self.language = language
			self.searchQuery = searchQuery

			let selectedRange = textView.selectedRange
			let attributed = NSMutableAttributedString(string: text)
			let fullRange = NSRange(location: 0, length: attributed.length)
			let baseFont = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
			attributed.addAttributes([
				.font: baseFont,
				.foregroundColor: UIColor(white: 0.86, alpha: 1)
			], range: fullRange)

			apply(pattern: "\\b(func|let|var|if|else|for|while|return|struct|class|enum|case|switch|import|private|public|final|guard|throw|throws|try|catch|do|in)\\b", color: UIColor(red: 0.46, green: 0.70, blue: 1.0, alpha: 1), to: attributed)
			apply(pattern: "\\b(true|false|null|nil|self|super)\\b", color: UIColor(red: 0.96, green: 0.58, blue: 0.70, alpha: 1), to: attributed)
			apply(pattern: "\"(?:\\\\.|[^\"\\\\])*\"|'(?:\\\\.|[^'\\\\])*'", color: UIColor(red: 0.62, green: 0.86, blue: 0.64, alpha: 1), to: attributed)
			apply(pattern: "(?m)#.*$|//.*$", color: UIColor(white: 0.52, alpha: 1), to: attributed)
			apply(pattern: "\\b[0-9]+(?:\\.[0-9]+)?\\b", color: UIColor(red: 0.98, green: 0.72, blue: 0.42, alpha: 1), to: attributed)
			apply(pattern: "(?m)^\\s*[-*#]+.*$", color: UIColor(red: 0.76, green: 0.66, blue: 1.0, alpha: 1), to: attributed)
			applySearchHighlight(searchQuery, to: attributed)

			textView.attributedText = attributed
			let location = min(selectedRange.location, attributed.length)
			textView.selectedRange = NSRange(location: location, length: min(selectedRange.length, max(0, attributed.length - location)))
			isApplyingHighlighting = false
		}

		private func applySearchHighlight(_ query: String, to attributed: NSMutableAttributedString) {
			let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
			guard !trimmed.isEmpty else { return }
			let nsString = attributed.string as NSString
			var searchRange = NSRange(location: 0, length: nsString.length)
			while true {
				let found = nsString.range(of: trimmed, options: [.caseInsensitive], range: searchRange)
				guard found.location != NSNotFound else { break }
				attributed.addAttributes([
					.backgroundColor: UIColor(red: 1.0, green: 0.82, blue: 0.24, alpha: 0.32),
					.foregroundColor: UIColor.white
				], range: found)
				let nextLocation = found.location + max(found.length, 1)
				guard nextLocation < nsString.length else { break }
				searchRange = NSRange(location: nextLocation, length: nsString.length - nextLocation)
			}
		}

		private func apply(pattern: String, color: UIColor, to attributed: NSMutableAttributedString) {
			guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
				return
			}
			let range = NSRange(location: 0, length: attributed.length)
			regex.enumerateMatches(in: attributed.string, options: [], range: range) { match, _, _ in
				guard let match else { return }
				attributed.addAttribute(.foregroundColor, value: color, range: match.range)
			}
		}
	}
}

private struct SSHProfileDraft: Identifiable {
	var id: UUID
	var label: String
	var host: String
	var username: String
	var authKind: SSHAuthKind
	var port: Int
	var privateKeyPath: String
	var startupPath: String
	var notes: String
	var lastSeen: Date?

	init(profile: SSHProfileSummary?) {
		id = profile?.id ?? UUID()
		label = profile?.label ?? ""
		host = profile?.host ?? ""
		username = profile?.username ?? "root"
		authKind = profile?.authKind ?? .agent
		port = profile?.port ?? 22
		privateKeyPath = profile?.privateKeyPath ?? ""
		startupPath = profile?.startupPath ?? ""
		notes = profile?.notes ?? ""
		lastSeen = profile?.lastSeen
	}

	var profile: SSHProfileSummary {
		SSHProfileSummary(id: id, label: label, host: host, username: username, authKind: authKind, lastSeen: lastSeen, port: port, privateKeyPath: privateKeyPath, startupPath: startupPath, notes: notes)
	}
}

private struct SSHProfileEditorSheet: View {
	@Environment(\.dismiss) private var dismiss
	@State private var draft: SSHProfileDraft
	let save: (SSHProfileSummary) -> Void

	init(draft: SSHProfileDraft, save: @escaping (SSHProfileSummary) -> Void) {
		_draft = State(initialValue: draft)
		self.save = save
	}

	var body: some View {
		NavigationStack {
			Form {
				TextField("Label", text: $draft.label)
				TextField("Host", text: $draft.host)
				TextField("Username", text: $draft.username)
				Stepper("Port \(draft.port)", value: $draft.port, in: 1...65535)
				Picker("Auth", selection: $draft.authKind) {
					ForEach(SSHAuthKind.allCases) { kind in
						Text(kind.title).tag(kind)
					}
				}
				TextField("Private key path", text: $draft.privateKeyPath)
				TextField("Startup path", text: $draft.startupPath)
				TextField("Notes", text: $draft.notes, axis: .vertical)
			}
			.navigationTitle("SSH Profile")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						save(draft.profile)
						dismiss()
					}
				}
			}
		}
	}
}

private struct ServerMonitorDraft: Identifiable {
	var id = UUID()
	var profileID: UUID
	var label = "Server"
	var path = "/"
	var cpuThreshold = 85
	var memoryThreshold = 85
	var diskThreshold = 90

	init(profileID: UUID) {
		self.profileID = profileID
	}

	var monitor: ServerMonitorSummary {
		ServerMonitorSummary(id: id, sshProfileID: profileID, label: label, path: path, cpuThreshold: cpuThreshold, memoryThreshold: memoryThreshold, diskThreshold: diskThreshold)
	}
}

private struct ServerMonitorEditorSheet: View {
	@Environment(\.dismiss) private var dismiss
	@State private var draft: ServerMonitorDraft
	let profiles: [SSHProfileSummary]
	let save: (ServerMonitorSummary) -> Void

	init(draft: ServerMonitorDraft, profiles: [SSHProfileSummary], save: @escaping (ServerMonitorSummary) -> Void) {
		_draft = State(initialValue: draft)
		self.profiles = profiles
		self.save = save
	}

	var body: some View {
		NavigationStack {
			Form {
				Picker("Profile", selection: $draft.profileID) {
					ForEach(profiles) { profile in
						Text(profile.label).tag(profile.id)
					}
				}
				TextField("Label", text: $draft.label)
				TextField("Disk path", text: $draft.path)
				Stepper("CPU alert \(draft.cpuThreshold)%", value: $draft.cpuThreshold, in: 1...100)
				Stepper("Memory alert \(draft.memoryThreshold)%", value: $draft.memoryThreshold, in: 1...100)
				Stepper("Disk alert \(draft.diskThreshold)%", value: $draft.diskThreshold, in: 1...100)
			}
			.navigationTitle("Server Monitor")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						save(draft.monitor)
						dismiss()
					}
				}
			}
		}
	}
}

private struct WorkspaceCardBackground: View {
	let tint: Color

	var body: some View {
		Group {
			if #available(iOS 26.0, *) {
				RoundedRectangle(cornerRadius: 18, style: .continuous)
					.fill(tint.opacity(0.10))
					.overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.white.opacity(0.12), lineWidth: 0.8))
					.glassEffect(.regular.tint(tint.opacity(0.18)), in: .rect(cornerRadius: 18))
			} else {
				RoundedRectangle(cornerRadius: 18, style: .continuous)
					.fill(.ultraThinMaterial)
					.overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.white.opacity(0.10), lineWidth: 0.8))
			}
		}
	}
}

private struct WorkspaceBackdrop: View {
	var body: some View {
		ZStack {
			LinearGradient(
				colors: [
					Color(red: 0.07, green: 0.09, blue: 0.13),
					Color(red: 0.12, green: 0.15, blue: 0.19),
					Color(red: 0.06, green: 0.08, blue: 0.11)
				],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
		}
	}
}
