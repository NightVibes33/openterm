import SwiftUI
import UIKit

struct DeveloperWorkspaceRootView: View {

	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@StateObject private var store = WorkspaceStore.shared
	@State private var selection: WorkspaceDestination = .home
	@AppStorage("workspace.onboarding.completed") private var hasCompletedOnboarding = false
	@State private var showsOnboarding = false

	var body: some View {
		Group {
			if horizontalSizeClass == .regular {
				regularLayout
			} else {
				compactLayout
			}
		}
		.tint(store.workspaceAccentColor)
		.sheet(isPresented: $showsOnboarding) {
			WorkspaceOnboardingView(store: store, selection: $selection, hasCompletedOnboarding: $hasCompletedOnboarding)
		}
		.onAppear {
			store.refreshLocalFiles()
			store.refreshGitWorkspaces()
			if !hasCompletedOnboarding {
				showsOnboarding = true
			}
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
			TerminalWorkspaceView(store: store, selection: $selection)
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
			SectionHeader(title: "Workspace Activity", subtitle: "Real SSH, Git, monitor, file, and terminal events after you use them.")
			if store.recentSessions.isEmpty {
				EmptyStateCard(title: "No Real Activity Yet", detail: "Add an SSH profile, import files, clone a repo, or refresh monitors to populate this section with real workspace activity.", symbol: "rectangle.stack")
			}
			AdaptiveGrid {
				ForEach(store.recentSessions) { session in
					SessionCard(session: session)
				}
			}
			SectionHeader(title: "Capability Check", subtitle: "What is configured locally, terminal-driven, or still missing.")
			VStack(spacing: 10) {
				ForEach(capabilityStatuses) { status in
					CapabilityStatusRow(status: status)
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

	private var capabilityStatuses: [CapabilityStatus] {
		[
			CapabilityStatus(title: "Terminal", detail: "Built-in ios_system command runner is available.", state: "Local", symbol: "terminal", tint: store.workspaceAccentColor),
			CapabilityStatus(title: "Files", detail: "Browse/import/edit/rename/export app documents.", state: "Local", symbol: "folder", tint: AppColor.amber),
			CapabilityStatus(title: "SSH", detail: store.sshProfiles.isEmpty ? "Add a real profile before connecting." : "\(store.sshProfiles.count) saved profile(s).", state: store.sshProfiles.isEmpty ? "Setup" : "Saved", symbol: "server.rack", tint: AppColor.green),
			CapabilityStatus(title: "Git", detail: store.gitWorkspaces.isEmpty ? "No repositories found. Commands require git in the terminal environment." : "\(store.gitWorkspaces.count) detected repo(s).", state: store.gitWorkspaces.isEmpty ? "No repos" : "Terminal", symbol: "point.topleft.down.curvedto.point.bottomright.up", tint: AppColor.blue),
			CapabilityStatus(title: "AI", detail: store.isAIConfigured ? "Provider/proxy configured." : "Endpoint/key or proxy/token missing.", state: store.isAIConfigured ? "Configured" : "Config", symbol: "sparkles", tint: AppColor.violet),
			CapabilityStatus(title: "Vault Sync", detail: store.isVaultSyncConfigured ? "Backend settings present." : "Supabase/auth/secret missing.", state: store.isVaultSyncConfigured ? "Configured" : "Config", symbol: "lock.shield", tint: AppColor.coral),
			CapabilityStatus(title: "Monitoring", detail: store.serverSnapshots.isEmpty ? "No SSH poll result yet." : "Latest SSH monitor data available.", state: store.serverSnapshots.isEmpty ? "No data" : "SSH data", symbol: "waveform.path.ecg", tint: AppColor.green)
		]
	}

}


private struct CapabilityStatus: Identifiable {
	let id = UUID()
	let title: String
	let detail: String
	let state: String
	let symbol: String
	let tint: Color
}

private struct CapabilityStatusRow: View {
	let status: CapabilityStatus

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: status.symbol)
				.font(.system(size: 18, weight: .semibold))
				.foregroundStyle(status.tint)
				.frame(width: 36, height: 36)
				.background(status.tint.opacity(0.16), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
			VStack(alignment: .leading, spacing: 3) {
				Text(status.title)
					.font(.system(.headline, design: .default, weight: .semibold))
					.foregroundStyle(.primary)
				Text(status.detail)
					.font(.system(.footnote, design: .default))
					.foregroundStyle(.secondary)
			}
			Spacer()
			Text(status.state)
				.font(.system(.caption, design: .default, weight: .bold))
				.foregroundStyle(status.tint)
				.padding(.horizontal, 10)
				.padding(.vertical, 6)
				.background(status.tint.opacity(0.14), in: Capsule())
		}
		.padding(14)
		.background(WorkspaceCardBackground(tint: status.tint))
	}
}

private struct QuickActionGrid: View {
	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			SectionHeader(title: "Quick Actions", subtitle: "Actions change based on what is actually configured on this device.")
			AdaptiveGrid {
				ActionTile(title: "New Terminal", subtitle: "Open the shell", symbol: "terminal", tint: AppColor.blue) { selection = .terminal }
				ActionTile(title: monitorActionTitle, subtitle: monitorActionSubtitle, symbol: "waveform.path.ecg", tint: AppColor.green) {
					if store.serverMonitors.isEmpty {
						store.statusMessage = store.sshProfiles.isEmpty ? "Add an SSH profile before creating a monitor" : "Create a monitor before refreshing SSH health"
						selection = .servers
					} else {
						store.refreshMonitorSnapshots()
					}
				}
				ActionTile(title: gitActionTitle, subtitle: gitActionSubtitle, symbol: "point.topleft.down.curvedto.point.bottomright.up", tint: AppColor.violet) {
					store.refreshGitWorkspaces()
					selection = .git
				}
				ActionTile(title: aiActionTitle, subtitle: aiActionSubtitle, symbol: "sparkles", tint: AppColor.amber) {
					selection = store.isAIConfigured ? .assistant : .more
					if !store.isAIConfigured {
						store.statusMessage = "Configure AI routing before sending prompts"
					}
				}
			}
		}
	}

	private var monitorActionTitle: String {
		store.serverMonitors.isEmpty ? "Set Up Monitors" : "Refresh Monitors"
	}

	private var monitorActionSubtitle: String {
		if store.serverMonitors.isEmpty {
			return store.sshProfiles.isEmpty ? "Needs SSH profile" : "Create monitor"
		}
		return "Poll SSH health"
	}

	private var gitActionTitle: String {
		store.gitWorkspaces.isEmpty ? "Find Repos" : "Open Git"
	}

	private var gitActionSubtitle: String {
		store.gitWorkspaces.isEmpty ? "Scan Documents" : "Terminal Git actions"
	}

	private var aiActionTitle: String {
		store.isAIConfigured ? "Ask AI" : "Configure AI"
	}

	private var aiActionSubtitle: String {
		store.isAIConfigured ? "Use saved routing" : "Provider required"
	}
}


private struct TerminalWorkspaceView: View {
	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination

	var body: some View {
		VStack(spacing: 0) {
			VStack(alignment: .leading, spacing: 14) {
				HStack(alignment: .top, spacing: 14) {
					VStack(alignment: .leading, spacing: 6) {
						Text("Terminal")
							.font(.system(.title2, design: .rounded, weight: .black))
							.foregroundStyle(.primary)
						Text("Real local ios_system shell with command handoff from SSH, Git, snippets, and AI tools.")
							.font(.system(.footnote, design: .default, weight: .medium))
							.foregroundStyle(.secondary)
					}
					Spacer(minLength: 0)
					MetricPill(title: "Core", value: "Local")
				}

				LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: 8)], spacing: 8) {
					FileHeaderButton(title: "Files", symbol: "folder", tint: AppColor.amber) { selection = .files }
					FileHeaderButton(title: "Servers", symbol: "server.rack", tint: AppColor.green) { selection = .servers }
					FileHeaderButton(title: "Settings", symbol: "slider.horizontal.3", tint: store.workspaceAccentColor) { selection = .more }
				}
			}
			.padding(16)
			.background(WorkspaceCardBackground(tint: store.workspaceAccentColor))
			.padding(.horizontal, 14)
			.padding(.top, 12)
			.padding(.bottom, 8)

			LegacyTerminalContainerView()
				.background(Color(UserDefaultsController.shared.terminalBackgroundColor))
		}
		.background(WorkspaceBackdrop().ignoresSafeArea())
	}
}

private struct FilesWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore
	@State private var newFileName = ""
	@State private var newFolderName = ""
	@State private var showingNewFile = false
	@State private var showingNewFolder = false
	@State private var showingImporter = false
	@State private var showingSystemBrowser = false
	@State private var shareItem: WorkspaceShareItem?
	@State private var renamingFile: LocalWorkspaceFile?
	@State private var renameName = ""
	@State private var showingRename = false
	@State private var editingSnippet: SnippetDraft?
	@State private var searchText = ""

	private var visibleFiles: [LocalWorkspaceFile] {
		let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !query.isEmpty else { return store.localFiles }
		return store.localFiles.filter {
			$0.name.localizedCaseInsensitiveContains(query) ||
			$0.relativePath.localizedCaseInsensitiveContains(query) ||
			$0.kindDescription.localizedCaseInsensitiveContains(query)
		}
	}

	var body: some View {
		WorkspaceScroll(title: "Files") {
			FileWorkspaceHeader(
				path: store.currentFolderDisplayPath,
				fileCount: store.localFiles.filter { !$0.isDirectory }.count,
				folderCount: store.localFiles.filter(\.isDirectory).count,
				canNavigateUp: store.canNavigateUpInFiles,
				goUp: { store.navigateUpInFiles() },
				importFiles: { showingImporter = true },
				newFile: { showingNewFile = true },
				newFolder: { showingNewFolder = true },
				openSystemBrowser: { showingSystemBrowser = true },
				refresh: { store.refreshLocalFiles() }
			)

			VStack(alignment: .leading, spacing: 14) {
				HStack(spacing: 12) {
					Image(systemName: "magnifyingglass")
						.foregroundStyle(.secondary)
					TextField("Search name, path, or type", text: $searchText)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
					if !searchText.isEmpty {
						Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill") }
							.buttonStyle(.plain)
							.foregroundStyle(.secondary)
					}
				}
				.padding(14)
				.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

				HStack(spacing: 10) {
					SectionHeader(title: "Workspace Browser", subtitle: "Real app Documents storage. Import from iOS Files, edit local copies, duplicate, export, or jump a terminal into a folder.")
					Spacer()
					Text("\(visibleFiles.count) shown")
						.font(.system(.caption, design: .rounded, weight: .bold))
						.foregroundStyle(.secondary)
				}

				if store.localFiles.isEmpty {
					EmptyStateCard(title: "No Files Yet", detail: "Open the iOS Files browser or import files to create editable workspace copies. OpenTerm does not fake project files.", symbol: "folder.badge.plus")
				} else if visibleFiles.isEmpty {
					EmptyStateCard(title: "No Matches", detail: "Nothing in this folder matches \"\(searchText)\".", symbol: "magnifyingglass")
				} else {
					VStack(spacing: 0) {
						ForEach(visibleFiles) { file in
							FileRow(
								file: file,
								open: { open(file) },
								rename: { beginRename(file) },
								export: { export(file) },
								duplicate: { store.duplicateLocalItem(file) },
								copyPath: { store.copyLocalPath(file) },
								openTerminal: { store.openTerminalForLocalItem(file) },
								delete: { store.deleteLocalFile(file) }
							)
							if file.id != visibleFiles.last?.id { Divider().padding(.leading, 64) }
						}
					}
					.background(WorkspaceListBackground(tint: AppColor.amber))
				}
			}

			VStack(alignment: .leading, spacing: 12) {
				HStack {
					SectionHeader(title: "Snippets", subtitle: "User-created commands that run in the active terminal tab.")
					Spacer()
					Button { editingSnippet = SnippetDraft(snippet: nil) } label: {
						Label("New", systemImage: "plus")
					}
					.buttonStyle(.bordered)
				}
				if store.snippets.isEmpty {
					EmptyStateCard(title: "No Snippets", detail: "Create your own command snippets. OpenTerm no longer seeds fake deploy or server commands.", symbol: "text.badge.plus")
				}
				ForEach(store.snippets) { snippet in
					SnippetRow(snippet: snippet) {
						store.runSnippetInTerminal(snippet)
					} edit: {
						editingSnippet = SnippetDraft(snippet: snippet)
					} delete: {
						store.deleteSnippet(snippet)
					}
				}
			}
		}
		.toolbar {
			ToolbarItemGroup(placement: .topBarTrailing) {
				Button { showingSystemBrowser = true } label: { Image(systemName: "doc.viewfinder") }
				Button { showingImporter = true } label: { Image(systemName: "square.and.arrow.down") }
				Button { showingNewFolder = true } label: { Image(systemName: "folder.badge.plus") }
				Button { showingNewFile = true } label: { Image(systemName: "doc.badge.plus") }
				Button { store.refreshLocalFiles() } label: { Image(systemName: "arrow.clockwise") }
			}
		}
		.sheet(isPresented: $showingImporter) {
			DocumentImportPicker { urls in
				store.importFiles(from: urls)
			}
		}
		.sheet(isPresented: $showingSystemBrowser) {
			NativeDocumentBrowserSheet { urls in
				store.importFiles(from: urls)
			}
		}
		.sheet(item: $shareItem) { item in
			ActivityShareSheet(url: item.url)
		}
		.sheet(item: $store.activeEditor) { document in
			WorkspaceEditorSheet(document: document, store: store)
		}
		.sheet(item: $editingSnippet) { draft in
			SnippetEditorSheet(draft: draft) { snippet in
				store.upsertSnippet(snippet)
			}
		}
		.alert("New File", isPresented: $showingNewFile) {
			TextField("script.sh", text: $newFileName)
			Button("Create") {
				store.createFile(named: newFileName, initialContent: "#!/bin/sh\n")
				newFileName = ""
			}
			Button("Cancel", role: .cancel) { newFileName = "" }
		}
		.alert("New Folder", isPresented: $showingNewFolder) {
			TextField("Project", text: $newFolderName)
			Button("Create") {
				store.createFolder(named: newFolderName)
				newFolderName = ""
			}
			Button("Cancel", role: .cancel) { newFolderName = "" }
		}
		.alert("Rename Item", isPresented: $showingRename) {
			TextField("Name", text: $renameName)
			Button("Rename") {
				if let file = renamingFile {
					store.renameLocalFile(file, to: renameName)
				}
				renameName = ""
				renamingFile = nil
			}
			Button("Cancel", role: .cancel) {
				renameName = ""
				renamingFile = nil
			}
		}
	}

	private func open(_ file: LocalWorkspaceFile) {
		if file.isDirectory {
			store.navigateToFolder(relativePath: file.relativePath)
		} else {
			store.openFile(relativePath: file.relativePath)
		}
	}

	private func beginRename(_ file: LocalWorkspaceFile) {
		renameName = file.name
		renamingFile = file
		showingRename = true
	}

	private func export(_ file: LocalWorkspaceFile) {
		if let url = store.exportLocalItem(file) {
			shareItem = WorkspaceShareItem(url: url)
		}
	}
}

private struct GitWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination
	@State private var cloneURL = ""
	@State private var cloneFolder = ""
	@State private var commitMessage = ""

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

			if store.gitWorkspaces.isEmpty {
				EmptyStateCard(title: "No Repositories Found", detail: "Clone a repo from this screen or import a folder containing a .git directory, then refresh to show real Git actions.", symbol: "point.topleft.down.curvedto.point.bottomright.up")
			}
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
			if store.sshProfiles.isEmpty {
				EmptyStateCard(title: "No SSH Profiles", detail: "Add a real VPS, homelab, or server profile. OpenTerm no longer seeds fake example hosts.", symbol: "server.rack")
			}
			ForEach(store.sshProfiles) { profile in
					SSHProfileCard(profile: profile, lastSeen: store.formatLastSeen(profile.lastSeen)) {
						store.connect(to: profile)
						selection = .terminal
					} installDevStack: { flavor in
						store.queueRemoteDevStack(on: profile, flavor: flavor)
						selection = .terminal
					} auditTools: {
						store.queueRemoteToolAudit(on: profile)
						selection = .terminal
					} edit: {
						editingProfile = SSHProfileDraft(profile: profile)
					} delete: {
						store.deleteSSHProfile(profile)
					}
				}

			SectionHeader(title: "SSH Key Vault", subtitle: "Local protected key storage. Optional Supabase encrypted sync requires backend settings.")
			if store.sshVaultItems.isEmpty {
				EmptyStateCard(title: "No Keys Imported", detail: "Import SSH keys into the protected local vault, then attach them to profiles when needed.", symbol: "key")
			}
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
					.foregroundStyle(.primary)

			}
			if store.serverSnapshots.isEmpty && !store.isRefreshingMonitors {
				EmptyStateCard(title: "No Monitor Data", detail: "Create an SSH profile, add a monitor, then refresh to poll real CPU, memory, disk, and load data over SSH.", symbol: "waveform.path.ecg")
			}
			AdaptiveGrid {
				ForEach(store.serverSnapshots) { snapshot in
					ServerSnapshotCard(snapshot: snapshot)
				}

			}

				SectionHeader(title: "Server Alerts", subtitle: "Local alert history from monitor threshold changes.")
				if store.serverAlerts.filter({ !$0.isAcknowledged }).isEmpty {
					EmptyStateCard(title: "No Active Alerts", detail: "Alerts appear only after a real monitor crosses a configured threshold.", symbol: "bell")
				}
				ForEach(store.serverAlerts.filter { !$0.isAcknowledged }.prefix(6)) { alert in
					ServerAlertCard(alert: alert) {
						store.acknowledgeServerAlert(alert)
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
					} else {
						store.statusMessage = "Add an SSH profile before creating a monitor"
						editingProfile = SSHProfileDraft(profile: nil)
					}
				} label: { Image(systemName: "waveform.path.ecg") }
				Button { store.refreshMonitorSnapshots() } label: { Image(systemName: "arrow.clockwise") }
			}
		}
		.onAppear { store.startMonitorAutoRefresh() }
		.onDisappear { store.stopMonitorAutoRefresh() }
		.sheet(item: $editingProfile) { draft in
			SSHProfileEditorSheet(draft: draft) { profile, password in
				store.upsertSSHProfile(profile, password: password)
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
			WorkspaceSummaryBanner(title: "AI Assistant", detail: store.assistantStatus, tint: AppColor.violet)

			if !store.isAIConfigured {
				VStack(alignment: .leading, spacing: 12) {
					EmptyStateCard(title: "AI Not Configured", detail: "Prompt shortcuts can prepare drafts, but configured responses require an OpenAI-compatible endpoint plus API key, or a Supabase hosted proxy plus access token.", symbol: "sparkles")
					PrimaryWorkspaceButton(title: "Configure AI", symbol: "slider.horizontal.3", tint: AppColor.violet) {
						store.openSettings()
					}
				}
			}

			VStack(alignment: .leading, spacing: 12) {
				TextField("Explain this error, generate a command, fix this script", text: $store.assistantDraft, axis: .vertical)
					.textFieldStyle(.roundedBorder)
					.lineLimit(3...6)
				PrimaryWorkspaceButton(title: store.isSendingAssistantPrompt ? "Sending" : "Send Prompt", symbol: "paperplane.fill", tint: AppColor.violet) {
					store.submitAssistantPrompt()
				}
				.disabled(store.isSendingAssistantPrompt || !store.isAIConfigured)
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
	@AppStorage("workspace.onboarding.completed") private var hasCompletedOnboarding = false
	@State private var showsOnboarding = false
	@State private var showsSettings = false

	var body: some View {
		WorkspaceScroll(title: "More") {
			WorkspaceSummaryBanner(title: "Tools & Settings", detail: "Terminal-driven Git, optional AI, appearance, backend setup, vault sync, support links, and maintenance controls live here.", tint: store.workspaceAccentColor)

			AdaptiveGrid {
				ActionTile(title: "AI Assistant", subtitle: "Requires your provider or proxy", symbol: "sparkles", tint: AppColor.violet) { selection = .assistant }
				ActionTile(title: "Git Workspace", subtitle: "Terminal-driven repo actions", symbol: "point.topleft.down.curvedto.point.bottomright.up", tint: AppColor.blue) { selection = .git }
				ActionTile(title: "Settings", subtitle: "Theme, terminal, AI, and defaults", symbol: "slider.horizontal.3", tint: store.workspaceAccentColor) { showsSettings = true }
				ActionTile(title: "Refresh", subtitle: "Files, repos, and monitors", symbol: "arrow.clockwise", tint: AppColor.green) {
					store.refreshLocalFiles()
					store.refreshGitWorkspaces()
					store.refreshMonitorSnapshots()
				}
			}

			SettingsAccessCard(store: store) {
				showsSettings = true
			}

			AboutSupportCard(tint: store.workspaceAccentColor) {
				hasCompletedOnboarding = false
				showsOnboarding = true
			}
		}
		.sheet(isPresented: $showsOnboarding) {
			WorkspaceOnboardingView(store: store, selection: $selection, hasCompletedOnboarding: $hasCompletedOnboarding)
		}
		.sheet(isPresented: $showsSettings) {
			NavigationStack {
				WorkspaceScroll(title: "Settings") {
					SettingsWorkspaceView(store: store)
				}
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Done") { showsSettings = false }
					}
				}
			}
		}
	}
}



private struct SettingsAccessCard: View {
	@ObservedObject var store: WorkspaceStore
	let openSettings: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			SectionHeader(title: "Workspace Setup", subtitle: "Settings are real controls for theme, terminal appearance, AI routing, optional backend bootstrap, vault sync, and backup export.")
			AdaptiveGrid {
				MetricCard(title: "Theme", value: store.activeThemeName, symbol: "paintpalette", tint: store.workspaceAccentColor)
				MetricCard(title: "AI", value: store.isAIConfigured ? "Configured" : "Off", symbol: "sparkles", tint: AppColor.violet)
				MetricCard(title: "Vault", value: store.isVaultSyncConfigured ? "Sync Ready" : "Local", symbol: "lock.shield", tint: AppColor.green)
			}
			PrimaryWorkspaceButton(title: "Open Settings", symbol: "slider.horizontal.3", tint: store.workspaceAccentColor, action: openSettings)
		}
		.padding(18)
		.background(WorkspaceCardBackground(tint: store.workspaceAccentColor))
	}
}

private struct WorkspaceOnboardingView: View {

	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination
	@Binding var hasCompletedOnboarding: Bool
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 22) {
					VStack(alignment: .leading, spacing: 12) {
						Text("OpenTerm")
							.font(.system(.largeTitle, design: .default, weight: .bold))
							.foregroundStyle(.primary)
						Text("A clean SSH, terminal, files, Git, server-check, and optional AI workspace for iPhone and iPad.")
							.font(.system(.body, design: .default))
							.foregroundStyle(.secondary)
					}
					.padding(24)
					.frame(maxWidth: .infinity, alignment: .leading)
					.background(WorkspaceCardBackground(tint: store.workspaceAccentColor))

					SectionHeader(title: "Start With Real Tools", subtitle: "These steps create useful workspace state instead of demo cards.")
					VStack(spacing: 12) {
						OnboardingStepCard(number: "1", title: "Open the terminal", detail: "Use the built-in shell for local commands and quick SSH handoff.", symbol: "terminal", tint: store.workspaceAccentColor)
						OnboardingStepCard(number: "2", title: "Import files", detail: "Bring in real files from iOS Files, edit UTF-8 text, rename, export, or archive folders.", symbol: "folder.badge.plus", tint: AppColor.amber)
						OnboardingStepCard(number: "3", title: "Add SSH profiles", detail: "Connect to real VPS, homelab, or Linux servers. Monitoring works best with key-based noninteractive SSH.", symbol: "server.rack", tint: AppColor.green)
						OnboardingStepCard(number: "4", title: "Configure AI only if you want it", detail: "AI stays off until you add your own provider endpoint/key or hosted proxy settings.", symbol: "sparkles", tint: AppColor.violet)
					}

					AdaptiveGrid {
						ActionTile(title: "Go Terminal", subtitle: "Start with the real shell", symbol: "terminal", tint: store.workspaceAccentColor) {
							finish(.terminal)
						}
						ActionTile(title: "Import Files", subtitle: "Open the file workspace", symbol: "folder", tint: AppColor.amber) {
							finish(.files)
						}
						ActionTile(title: "Add Server", subtitle: "Create an SSH profile", symbol: "server.rack", tint: AppColor.green) {
							finish(.servers)
						}
						ActionTile(title: "Settings", subtitle: "Theme and AI setup", symbol: "slider.horizontal.3", tint: AppColor.blue) {
							finish(.more)
						}
					}
				}
				.padding(20)
			}
			.background(WorkspaceBackdrop().ignoresSafeArea())
			.navigationTitle("Welcome")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Skip") { finish(.home) }
				}
			}
		}
	}

	private func finish(_ destination: WorkspaceDestination) {
		hasCompletedOnboarding = true
		selection = destination
		dismiss()
	}
}

private struct OnboardingStepCard: View {
	let number: String
	let title: String
	let detail: String
	let symbol: String
	let tint: Color

	var body: some View {
		HStack(alignment: .top, spacing: 14) {
			ZStack {
				Circle().fill(tint.opacity(0.18))
				Text(number)
					.font(.system(.headline, design: .default, weight: .bold))
					.foregroundStyle(tint)
			}
			.frame(width: 38, height: 38)
			VStack(alignment: .leading, spacing: 6) {
				Label(title, systemImage: symbol)
					.font(.system(.headline, design: .default, weight: .semibold))
					.foregroundStyle(.primary)
				Text(detail)
					.font(.system(.subheadline, design: .default))
					.foregroundStyle(.secondary)
			}
			Spacer(minLength: 0)
		}
		.padding(18)
		.background(WorkspaceCardBackground(tint: tint))
	}
}

private struct AboutSupportCard: View {
	let tint: Color
	let showOnboarding: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			SectionHeader(title: "About & Support", subtitle: "Project links, contact, and donations for the free OpenTerm fork.")
			Text("Built by NightVibes33 as a free, real-tool-first iOS terminal workspace. Donations support continued development, not feature unlocks.")
				.font(.system(.subheadline, design: .default))
				.foregroundStyle(.secondary)
			AdaptiveGrid {
				SupportLinkTile(title: "Donate", subtitle: "Buy Me a Coffee", symbol: "heart.fill", tint: AppColor.coral, url: "https://buymeacoffee.com/ZYN3")
				SupportLinkTile(title: "Source", subtitle: "GitHub repo", symbol: "chevron.left.forwardslash.chevron.right", tint: tint, url: "https://github.com/NightVibes33/openterm")
				SupportLinkTile(title: "Updates", subtitle: "@NightVibes33 on X", symbol: "megaphone", tint: AppColor.blue, url: "https://twitter.com/NightVibes33")
				SupportLinkTile(title: "Contact", subtitle: "Email support", symbol: "envelope", tint: AppColor.green, url: "mailto:nightvibes33@users.noreply.github.com?subject=OpenTerm%20Support")
			}
			PrimaryWorkspaceButton(title: "Show Onboarding Again", symbol: "sparkles.rectangle.stack", tint: tint, action: showOnboarding)
		}
		.padding(18)
		.background(WorkspaceCardBackground(tint: tint))
	}
}

private struct SupportLinkTile: View {
	let title: String
	let subtitle: String
	let symbol: String
	let tint: Color
	let url: String

	var body: some View {
		Button {
			guard let link = URL(string: url) else { return }
			UIApplication.shared.open(link, options: [:], completionHandler: nil)
		} label: {
			VStack(alignment: .leading, spacing: 8) {
				Image(systemName: symbol)
					.font(.system(size: 20, weight: .semibold))
					.foregroundStyle(tint)
				Text(title)
					.font(.system(.headline, design: .default, weight: .semibold))
					.foregroundStyle(.primary)
				Text(subtitle)
					.font(.system(.subheadline, design: .default))
					.foregroundStyle(.secondary)
			}
			.padding(16)
			.frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
			.background(WorkspaceCardBackground(tint: tint))
		}
		.buttonStyle(.plain)
	}
}

private struct SettingsWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore
	@State private var endpoint = ""
	@State private var model = ""
	@State private var apiKey = ""
	@State private var systemPrompt = ""
	@State private var useHostedProxy = false
	@State private var supabaseURL = ""
	@State private var backendAccessToken = ""
	@State private var backendAnonKey = ""
	@State private var backendUserID = ""
	@State private var backendDeviceID = ""
	@State private var backendDeviceLabel = ""
	@State private var vaultSyncSecret = ""
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
				SectionHeader(title: "Terminal", subtitle: "These controls update the actual shell appearance.")
				Slider(value: $terminalFontSize, in: 10...28, step: 1) {
					Text("Font size")
				} minimumValueLabel: {
					Text("10")
						.foregroundStyle(.secondary)
				} maximumValueLabel: {
					Text("28")
						.foregroundStyle(.secondary)
				}
				.onChange(of: terminalFontSize) { newValue in
					store.updateTerminalFontSize(newValue)
				}
				Text("Font size: \(Int(terminalFontSize)) pt")
					.font(.system(.footnote, design: .default, weight: .semibold))
					.foregroundStyle(.secondary)

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
					.foregroundStyle(.primary)
					.onChange(of: useDarkKeyboard) { newValue in
						store.updateUseDarkKeyboard(newValue)
					}
			}
			.padding(18)
			.background(WorkspaceCardBackground(tint: store.workspaceAccentColor))

			VStack(alignment: .leading, spacing: 12) {
				SectionHeader(title: "AI Provider", subtitle: "OpenAI-compatible chat endpoint. Secrets are stored locally in Keychain-backed storage.")
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
					.foregroundStyle(.primary)
				Text(useHostedProxy ? "Endpoint should be your Supabase ai-proxy function URL. API key should be the user's Supabase bearer token." : "Endpoint should be an OpenAI-compatible chat completions URL. API key is sent as a bearer token.")
					.font(.system(.footnote, design: .default))
					.foregroundStyle(.secondary)
				PrimaryWorkspaceButton(title: "Save AI Settings", symbol: "checkmark.seal", tint: store.workspaceAccentColor) {
					store.updateAIConfiguration(endpoint: endpoint, model: model, apiKey: apiKey, systemPrompt: systemPrompt, useHostedProxy: useHostedProxy)
				}
			}
			.padding(18)
			.background(WorkspaceCardBackground(tint: AppColor.violet))

				VStack(alignment: .leading, spacing: 12) {
					SectionHeader(title: "Optional Backend Bootstrap", subtitle: "Manual Supabase settings for hosted AI proxy and encrypted vault sync. Leave empty if you only use local terminal/SSH/files.")
					TextField("Supabase project URL", text: $supabaseURL)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
						.textFieldStyle(.roundedBorder)
					SecureField("Supabase anon key", text: $backendAnonKey)
						.textFieldStyle(.roundedBorder)
					SecureField("User access token", text: $backendAccessToken)
						.textFieldStyle(.roundedBorder)
					TextField("Authenticated user id", text: $backendUserID)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
						.textFieldStyle(.roundedBorder)
					TextField("Device id", text: $backendDeviceID)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
						.textFieldStyle(.roundedBorder)
					TextField("Device label", text: $backendDeviceLabel)
						.textFieldStyle(.roundedBorder)
					SecureField("Vault sync secret", text: $vaultSyncSecret)
						.textFieldStyle(.roundedBorder)
					Text("Vault payloads are AES-GCM encrypted on device before upload. The server only receives ciphertext, nonce, labels, and fingerprints.")
						.font(.system(.footnote, design: .default))
						.foregroundStyle(.secondary)
					PrimaryWorkspaceButton(title: "Save Backend Bootstrap", symbol: "lock.shield", tint: AppColor.green) {
						store.updateBackendConfiguration(supabaseURL: supabaseURL, accessToken: backendAccessToken, deviceLabel: backendDeviceLabel, anonKey: backendAnonKey, userID: backendUserID, deviceID: backendDeviceID, vaultSyncSecret: vaultSyncSecret)
					}
					Text(store.remoteConfigStatus)
						.font(.system(.footnote, design: .default))
						.foregroundStyle(.secondary)
					PrimaryWorkspaceButton(title: "Refresh Remote Config", symbol: "icloud.and.arrow.down", tint: AppColor.blue) {
						store.refreshRemoteConfiguration()
					}
					.disabled(supabaseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || backendAnonKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				}
				.padding(18)
				.background(WorkspaceCardBackground(tint: AppColor.green))

				VStack(alignment: .leading, spacing: 12) {
					SectionHeader(title: "Encrypted Vault Sync", subtitle: "Push or pull SSH key vault records through Supabase without plaintext private keys leaving this device.")
					if !store.isVaultSyncConfigured {
						EmptyStateCard(title: "Vault Sync Not Configured", detail: "Add Supabase URL, anon key, user access token, user id, and a vault sync secret before push/pull can work.", symbol: "icloud.slash")
					}
					Text(store.vaultSyncStatus)
						.font(.system(.footnote, design: .default, weight: .semibold))
						.foregroundStyle(.secondary)
					HStack(spacing: 12) {
						PrimaryWorkspaceButton(title: store.isSyncingVault ? "Syncingâ¦" : "Push Vault", symbol: "arrow.up.doc", tint: AppColor.green) {
							store.pushSSHVaultToCloud()
						}
						.disabled(store.isSyncingVault || !store.isVaultSyncConfigured)
						PrimaryWorkspaceButton(title: "Pull Vault", symbol: "arrow.down.doc", tint: AppColor.blue) {
							store.pullSSHVaultFromCloud()
						}
						.disabled(store.isSyncingVault || !store.isVaultSyncConfigured)
					}
						PrimaryWorkspaceButton(title: "Repair Local Vault", symbol: "cross.case", tint: AppColor.amber) {
							store.repairSSHVaultMetadata()
						}
				}
					.padding(18)
				.background(WorkspaceCardBackground(tint: AppColor.blue))
			VStack(alignment: .leading, spacing: 12) {
				SectionHeader(title: "Backup", subtitle: "Export workspace metadata without raw private-key contents.")
				Text(store.lastBackupPath)
					.font(.system(.footnote, design: .monospaced))
					.foregroundStyle(.secondary)
				PrimaryWorkspaceButton(title: "Export Backup", symbol: "square.and.arrow.up", tint: AppColor.green) {
					store.exportWorkspaceBackup()
				}
			}
			.padding(18)
			.background(WorkspaceCardBackground(tint: AppColor.green))

			AdaptiveGrid {
				MetricCard(title: "Theme", value: store.activeThemeName, symbol: "paintpalette", tint: store.workspaceAccentColor)
				MetricCard(title: "AI History", value: "\(store.aiUsageHistory.count)", symbol: "chart.bar", tint: AppColor.violet)
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
			supabaseURL = store.backendConfiguration.supabaseURL
			backendAccessToken = store.backendConfiguration.accessToken
				backendAnonKey = store.backendConfiguration.anonKey ?? ""
				backendUserID = store.backendConfiguration.userID ?? ""
				backendDeviceID = store.backendConfiguration.deviceID ?? ""
			backendDeviceLabel = store.backendConfiguration.deviceLabel
				vaultSyncSecret = store.backendConfiguration.vaultSyncSecret ?? ""
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
			SectionHeader(title: "Theme Colors", subtitle: "Change the app accent and terminal colors immediately.")
			ColorPicker("App accent", selection: $appAccent, supportsOpacity: false)
				.foregroundStyle(.primary)
				.onChange(of: appAccent) { newValue in
					store.updateWorkspaceAccent(newValue)
				}
			ColorPicker("Terminal text", selection: $terminalText, supportsOpacity: false)
				.foregroundStyle(.primary)
				.onChange(of: terminalText) { newValue in
					store.updateTerminalTextColor(newValue)
				}
			ColorPicker("Terminal background", selection: $terminalBackground, supportsOpacity: false)
				.foregroundStyle(.primary)
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
		VStack(alignment: .leading, spacing: 20) {
			HStack(alignment: .top, spacing: 16) {
				VStack(alignment: .leading, spacing: 10) {
					Text("OpenTerm")
						.font(.system(size: 42, weight: .black, design: .rounded))
						.foregroundStyle(.primary)
					Text("Terminal, SSH, files, Git handoff, server checks, and optional AI without pretending your phone is an unrestricted Linux distro.")
						.font(.system(.body, design: .rounded, weight: .medium))
						.foregroundStyle(.secondary)
				}
				Spacer(minLength: 0)
				Image(systemName: "terminal.fill")
					.font(.system(size: 28, weight: .bold))
					.foregroundStyle(store.workspaceAccentColor)
					.frame(width: 58, height: 58)
					.background(store.workspaceAccentColor.opacity(0.16), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
			}

			LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: 10)], spacing: 10) {
				PrimaryWorkspaceButton(title: "Terminal", symbol: "terminal", tint: store.workspaceAccentColor) { selection = .terminal }
				PrimaryWorkspaceButton(title: "Servers", symbol: "server.rack", tint: AppColor.green) { selection = .servers }
				PrimaryWorkspaceButton(title: "Files", symbol: "folder", tint: AppColor.amber) { selection = .files }
			}

			HStack(spacing: 10) {
				WorkspaceStatPill(title: "iOS", value: "18+")
				WorkspaceStatPill(title: "Mode", value: "Free")
				WorkspaceStatPill(title: "Data", value: "Local")
			}
		}
		.padding(24)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(WorkspaceCardBackground(tint: store.workspaceAccentColor))
	}
}

private struct SectionHeader: View {
	let title: String
	let subtitle: String

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(title)
				.font(.system(.title3, design: .default, weight: .semibold))
				.foregroundStyle(.primary)
			Text(subtitle)
				.font(.system(.subheadline, design: .default))
				.foregroundStyle(.secondary)
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
			VStack(alignment: .leading, spacing: 14) {
				HStack {
					Image(systemName: symbol)
						.font(.system(size: 19, weight: .bold))
						.foregroundStyle(tint)
						.frame(width: 42, height: 42)
						.background(tint.opacity(0.16), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
					Spacer()
					Image(systemName: "arrow.up.right")
						.font(.system(.caption, design: .rounded, weight: .bold))
						.foregroundStyle(.secondary)
				}
				VStack(alignment: .leading, spacing: 5) {
					Text(title)
						.font(.system(.headline, design: .rounded, weight: .bold))
						.foregroundStyle(.primary)
					Text(subtitle)
						.font(.system(.subheadline, design: .default))
						.foregroundStyle(.secondary)
						.lineLimit(2)
				}
			}
			.padding(18)
			.frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
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
				.font(.system(.headline, design: .default, weight: .semibold))
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
				.font(.system(.title2, design: .default, weight: .bold))
				.foregroundStyle(.primary)
			Text(detail)
				.font(.system(.body, design: .default))
				.foregroundStyle(.secondary)
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
				.font(.system(.headline, design: .default, weight: .semibold))
				.foregroundStyle(.primary)
			Text(session.subtitle)
				.font(.system(.subheadline, design: .default))
				.foregroundStyle(.secondary)
			Text(session.detail)
				.font(.system(.footnote, design: .default))
				.foregroundStyle(.secondary)
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
				.font(.system(.headline, design: .default, weight: .semibold))
				.foregroundStyle(.primary)
			Text(feature.detail)
				.font(.system(.subheadline, design: .default))
				.foregroundStyle(.secondary)
		}
		.padding(18)
		.frame(maxWidth: .infinity, minHeight: 158, alignment: .topLeading)
		.background(WorkspaceCardBackground(tint: feature.tint))
	}
}

private struct FileWorkspaceHeader: View {
	let path: String
	let fileCount: Int
	let folderCount: Int
	let canNavigateUp: Bool
	let goUp: () -> Void
	let importFiles: () -> Void
	let newFile: () -> Void
	let newFolder: () -> Void
	let openSystemBrowser: () -> Void
	let refresh: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			HStack(alignment: .top, spacing: 16) {
				VStack(alignment: .leading, spacing: 10) {
					Label("Files", systemImage: "folder.fill")
						.font(.system(size: 34, weight: .black, design: .rounded))
						.foregroundStyle(.primary)
					Text("Native iOS file access plus an editable OpenTerm workspace. No fake demo files, no toy rows.")
						.font(.system(.body, design: .rounded, weight: .medium))
						.foregroundStyle(.secondary)
				}
				Spacer(minLength: 0)
				VStack(alignment: .trailing, spacing: 8) {
					MetricPill(title: "Files", value: "\(fileCount)")
					MetricPill(title: "Folders", value: "\(folderCount)")
				}
			}

			HStack(spacing: 8) {
				Image(systemName: "internaldrive")
					.foregroundStyle(AppColor.amber)
				Text(path)
					.font(.system(.callout, design: .monospaced, weight: .semibold))
					.foregroundStyle(.primary)
					.lineLimit(2)
				Spacer(minLength: 0)
			}
			.padding(.horizontal, 14)
			.padding(.vertical, 11)
			.background(Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

			VStack(spacing: 10) {
				PrimaryWorkspaceButton(title: "Open iOS Files Browser", symbol: "doc.viewfinder", tint: AppColor.amber, action: openSystemBrowser)
				LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: 10)], spacing: 10) {
					FileHeaderButton(title: "Import Copy", symbol: "square.and.arrow.down", tint: AppColor.blue, action: importFiles)
					FileHeaderButton(title: "New File", symbol: "doc.badge.plus", tint: AppColor.green, action: newFile)
					FileHeaderButton(title: "New Folder", symbol: "folder.badge.plus", tint: AppColor.violet, action: newFolder)
					FileHeaderButton(title: "Refresh", symbol: "arrow.clockwise", tint: AppColor.coral, action: refresh)
					if canNavigateUp {
						FileHeaderButton(title: "Parent", symbol: "arrow.up.folder", tint: AppColor.coral, action: goUp)
					}
				}
			}
		}
		.padding(22)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(WorkspaceCardBackground(tint: AppColor.amber))
	}
}

private struct FileHeaderButton: View {
	let title: String
	let symbol: String
	let tint: Color
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Label(title, systemImage: symbol)
				.font(.system(.subheadline, design: .rounded, weight: .bold))
				.frame(maxWidth: .infinity)
				.padding(.vertical, 9)
		}
		.buttonStyle(.bordered)
		.tint(tint)
	}
}

private struct FileRow: View {
	let file: LocalWorkspaceFile
	let open: () -> Void
	let rename: () -> Void
	let export: () -> Void
	let duplicate: () -> Void
	let copyPath: () -> Void
	let openTerminal: () -> Void
	let delete: () -> Void

	private var tint: Color { file.isDirectory ? AppColor.blue : AppColor.amber }
	private var iconName: String {
		if file.isDirectory { return "folder.fill" }
		switch file.fileExtension {
		case "swift": return "swift"
		case "sh", "zsh", "bash": return "terminal.fill"
		case "json", "yml", "yaml", "plist", "xml": return "curlybraces"
		case "png", "jpg", "jpeg", "gif", "heic", "webp": return "photo.fill"
		case "zip", "tar", "gz", "tgz": return "archivebox.fill"
		default: return "doc.text.fill"
		}
	}

	var body: some View {
		HStack(alignment: .center, spacing: 12) {
			Button(action: open) {
				HStack(spacing: 12) {
					ZStack {
						RoundedRectangle(cornerRadius: 12, style: .continuous)
							.fill(tint.opacity(0.14))
						Image(systemName: iconName)
							.font(.system(size: 19, weight: .semibold))
							.foregroundStyle(tint)
					}
					.frame(width: 42, height: 42)

					VStack(alignment: .leading, spacing: 4) {
						Text(file.name)
							.font(.system(.headline, design: .rounded, weight: .semibold))
							.foregroundStyle(.primary)
							.lineLimit(1)
						Text(file.relativePath)
							.font(.system(.caption, design: .monospaced, weight: .medium))
							.foregroundStyle(.secondary)
							.lineLimit(1)
						HStack(spacing: 8) {
							Text(file.kindDescription)
							Text(file.sizeDescription)
							Text(file.modifiedDescription)
						}
						.font(.system(.caption, design: .default))
						.foregroundStyle(.secondary)
					}
					Spacer(minLength: 0)
				}
			}
			.buttonStyle(.plain)

			Menu {
				Button(action: open) { Label(file.isDirectory ? "Open Folder" : "Open Editor", systemImage: file.isDirectory ? "folder" : "doc.text") }
				Button(action: openTerminal) { Label("Open Terminal Here", systemImage: "terminal") }
				Button(action: copyPath) { Label("Copy Path", systemImage: "doc.on.doc") }
				Button(action: duplicate) { Label("Duplicate", systemImage: "plus.square.on.square") }
				Button(action: rename) { Label("Rename", systemImage: "pencil") }
				Button(action: export) { Label(file.isDirectory ? "Export Folder Archive" : "Share / Export", systemImage: "square.and.arrow.up") }
				Button(role: .destructive, action: delete) { Label("Delete", systemImage: "trash") }
			} label: {
				Image(systemName: "ellipsis.circle")
					.font(.system(size: 22, weight: .semibold))
					.foregroundStyle(.secondary)
					.frame(width: 40, height: 40)
			}
		}
		.padding(.horizontal, 14)
		.padding(.vertical, 11)
		.contextMenu {
			Button(action: open) { Label(file.isDirectory ? "Open Folder" : "Open Editor", systemImage: file.isDirectory ? "folder" : "doc.text") }
			Button(action: openTerminal) { Label("Open Terminal Here", systemImage: "terminal") }
			Button(action: copyPath) { Label("Copy Path", systemImage: "doc.on.doc") }
			Button(action: duplicate) { Label("Duplicate", systemImage: "plus.square.on.square") }
			Button(action: rename) { Label("Rename", systemImage: "pencil") }
			Button(action: export) { Label(file.isDirectory ? "Export Folder Archive" : "Share / Export", systemImage: "square.and.arrow.up") }
			Button(role: .destructive, action: delete) { Label("Delete", systemImage: "trash") }
		}
	}
}

private struct SnippetRow: View {
	let snippet: WorkspaceSnippet
	let run: () -> Void
	let edit: () -> Void
	let delete: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Text(snippet.title)
					.font(.system(.headline, design: .default, weight: .semibold))
					.foregroundStyle(.primary)
				Spacer()
				Text(snippet.category)
					.font(.system(.caption, design: .default, weight: .semibold))
					.foregroundStyle(AppColor.amber)
			}
			Text(snippet.body)
				.font(.system(.footnote, design: .monospaced))
				.foregroundStyle(.secondary)
			HStack(spacing: 10) {
				PrimaryWorkspaceButton(title: "Run", symbol: "play.fill", tint: AppColor.amber, action: run)
				PrimaryWorkspaceButton(title: "Edit", symbol: "pencil", tint: AppColor.blue, action: edit)
				Button(role: .destructive, action: delete) {
					Image(systemName: "trash")
				}
				.buttonStyle(.bordered)
			}
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
				.font(.system(.title3, design: .default, weight: .semibold))
				.foregroundStyle(.primary)
			Text(repo.path)
				.font(.system(.footnote, design: .monospaced))
				.foregroundStyle(.secondary)
			HStack(spacing: 10) {
				MetricPill(title: "Branch", value: repo.branch)
				MetricPill(title: "State", value: repo.status)
			}
			TextField("Required commit message", text: $commitMessage)
				.textFieldStyle(.roundedBorder)
			LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
				PrimaryWorkspaceButton(title: "Status", symbol: "list.bullet", tint: AppColor.blue) { run("git status") }
					PrimaryWorkspaceButton(title: "Diff", symbol: "doc.text.magnifyingglass", tint: AppColor.amber) { run("git diff --stat && git diff") }
					PrimaryWorkspaceButton(title: "Log", symbol: "clock.arrow.circlepath", tint: AppColor.blue) { run("git log --oneline --decorate -n 20") }
				PrimaryWorkspaceButton(title: "Pull", symbol: "arrow.down.circle", tint: AppColor.green) { run("git pull") }
				PrimaryWorkspaceButton(title: "Commit", symbol: "checkmark.circle", tint: AppColor.amber) { run("git add -A && git commit -m '\(commitMessage.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "'", with: "'\\''"))'") }
					.disabled(commitMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				PrimaryWorkspaceButton(title: "Push", symbol: "arrow.up.circle", tint: AppColor.violet) { run("git push") }
			}
				Menu {
					Button("Inspect conflicts") { run("git status --short && git diff --name-only --diff-filter=U && git diff --check") }
					Button("Show conflict diff") { run("git diff --merge") }
					Button("Abort merge") { run("git merge --abort") }
					Button("Continue merge") { run("git add -A && git commit") }
					Button("Use ours for conflicted files") { run("git diff --name-only --diff-filter=U | xargs git checkout --ours --") }
					Button("Use theirs for conflicted files") { run("git diff --name-only --diff-filter=U | xargs git checkout --theirs --") }
				} label: {
					Label("Conflict Tools", systemImage: "exclamationmark.triangle")
						.font(.system(.headline, design: .default, weight: .semibold))
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
				.tint(AppColor.coral)
		}
		.padding(18)
		.background(WorkspaceCardBackground(tint: AppColor.violet))
	}
}

private struct SSHProfileCard: View {
	let profile: SSHProfileSummary
	let lastSeen: String
	let connect: () -> Void
	let installDevStack: (String) -> Void
	let auditTools: () -> Void
	let edit: () -> Void
	let delete: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack(alignment: .top) {
				VStack(alignment: .leading, spacing: 5) {
					Text(profile.label)
						.font(.system(.title3, design: .default, weight: .semibold))
						.foregroundStyle(.primary)
					Text("\(profile.username)@\(profile.host):\(profile.port)")
						.font(.system(.subheadline, design: .monospaced))
						.foregroundStyle(.secondary)
					Text("\(profile.platform?.title ?? "Linux / Unix") / \(profile.authKind.title) / Last used \(lastSeen)")
						.font(.system(.footnote, design: .default))
						.foregroundStyle(.secondary)
				}
				Spacer()
				Button(role: .destructive, action: delete) { Image(systemName: "trash") }
			}
			HStack(spacing: 10) {
				PrimaryWorkspaceButton(title: "Connect", symbol: "bolt.horizontal.circle", tint: AppColor.green, action: connect)
				Menu {
					Button("Auto-detect Linux") { installDevStack("Auto") }
					Button("Debian / Ubuntu") { installDevStack("Debian/Ubuntu") }
					Button("Alpine") { installDevStack("Alpine") }
					Button("Fedora / RHEL") { installDevStack("Fedora/RHEL") }
					Button("Windows Full Runtime Kit") { installDevStack("Windows") }
				} label: {
					Label("Full Runtime Kit", systemImage: "shippingbox.and.arrow.backward")
						.font(.system(.headline, design: .default, weight: .semibold))
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
				.tint(AppColor.amber)
			}
			HStack(spacing: 10) {
				PrimaryWorkspaceButton(title: "Audit Remote Tools", symbol: "checklist", tint: AppColor.violet, action: auditTools)
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
						.font(.system(.headline, design: .default, weight: .semibold))
						.foregroundStyle(.primary)
					Text(item.fingerprint)
						.font(.system(.footnote, design: .monospaced))
						.foregroundStyle(.secondary)
				}
				Spacer()
				Button(role: .destructive, action: delete) { Image(systemName: "trash") }
			}
			if profiles.isEmpty {
				Text("Create an SSH profile before attaching this key.")
					.font(.system(.footnote, design: .default))
					.foregroundStyle(.secondary)
			} else {
				Menu {
					ForEach(profiles) { profile in
						Button(profile.label) { attach(profile) }
					}
				} label: {
					Label("Attach to Profile", systemImage: "link")
						.font(.system(.headline, design: .default, weight: .semibold))
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
				Text("Keys are stored locally with iOS file protection. Cloud sync uses AES-GCM encryption when configured in Settings.")
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

private struct ServerAlertCard: View {
	let alert: ServerAlertEvent
	let acknowledge: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Label(alert.title, systemImage: "exclamationmark.triangle")
					.font(.system(.headline, design: .default, weight: .semibold))
					.foregroundStyle(.primary)
				Spacer()
				Button("Acknowledge", action: acknowledge)
					.font(.system(.caption, design: .default, weight: .semibold))
			}
			Text(alert.detail)
				.font(.system(.footnote, design: .default))
				.foregroundStyle(.secondary)
		}
		.padding(16)
		.background(WorkspaceCardBackground(tint: alert.level.tint))
	}
}

private struct ServerSnapshotCard: View {
	let snapshot: ServerSnapshotSummary

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Text(snapshot.name)
					.font(.system(.headline, design: .default, weight: .semibold))
					.foregroundStyle(.primary)
				Spacer()
				Text(snapshot.alertLevel.title)
					.font(.system(.caption, design: .default, weight: .bold))
					.foregroundStyle(snapshot.alertLevel.tint)
			}
			HStack(spacing: 8) {
				MetricPill(title: "CPU", value: percent(snapshot.cpuPercent))
				MetricPill(title: "RAM", value: percent(snapshot.memoryPercent))
				MetricPill(title: "Disk", value: percent(snapshot.diskPercent))
			}
			Text(snapshot.detail)
				.font(.system(.footnote, design: .default))
				.foregroundStyle(.secondary)
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
					.font(.system(.caption, design: .default, weight: .bold))
					.foregroundStyle(message.role == "assistant" ? AppColor.violet : AppColor.green)
				Spacer()
				if message.role == "assistant" {
					Button(action: insertInTerminal) {
						Label("Terminal", systemImage: "terminal")
							.font(.system(.caption, design: .default, weight: .semibold))
					}
					.buttonStyle(.bordered)
				}
			}
			Text(message.content)
				.font(.system(.body, design: message.content.contains("$") ? .monospaced : .rounded))
				.foregroundStyle(.primary)
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
				.font(.system(.title2, design: .default, weight: .bold))
				.foregroundStyle(.primary)
			Text(title)
				.font(.system(.subheadline, design: .default))
				.foregroundStyle(.secondary)
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
				.font(.system(size: 10, weight: .bold, design: .default))
				.foregroundStyle(.tertiary)
			Text(value)
				.font(.system(.caption, design: .default, weight: .semibold))
				.foregroundStyle(.primary)
		}
		.padding(.horizontal, 10)
		.padding(.vertical, 8)
		.background(Color.primary.opacity(0.08), in: Capsule())
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
	@State private var showingDiff = false

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

						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: 8) {
								ForEach(completionSuggestions, id: \.self) { suggestion in
									Button(suggestion) { insertCompletion(suggestion) }
										.font(.system(.caption, design: .monospaced, weight: .semibold))
										.buttonStyle(.borderedProminent)
										.tint(AppColor.blue.opacity(0.85))
								}
							}
						}
				}
				.padding(.horizontal, 16)
				.padding(.vertical, 12)
				.background(AppColor.ink.opacity(0.96))

					if showingDiff {
						EditorDiffView(lines: diffLines)
					} else {
						HighlightedCodeEditor(text: $text, language: languageName, searchQuery: searchQuery)
					}
			}
			.background(AppColor.ink.ignoresSafeArea())
			.navigationTitle(document.title)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Close") { store.closeEditor() }
				}
					ToolbarItem(placement: .primaryAction) {
						Button(showingDiff ? "Editor" : "Diff") { showingDiff.toggle() }
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Save") { store.saveEditorDocument(relativePath: document.relativePath, content: text) }
					}
			}
		}
	}

	private var completionSuggestions: [String] {
		switch languageName {
		case "Swift": return ["import Foundation", "struct", "func", "guard let", "Task { }", "do { } catch { }"]
		case "Python": return ["import", "def", "class", "if __name__ == \"__main__\":", "try:\n    ", "with open"]
		case "JavaScript": return ["import", "async function", "await", "try { } catch", "console.log", "export default"]
		case "Shell": return ["#!/bin/sh", "set -e", "if [ ]; then", "for item in", "grep -R", "ssh user@host"]
		case "YAML": return ["name:", "on:", "jobs:", "steps:", "uses:", "run: |"]
		default: return ["TODO:", "NOTE:", "FIXME:"]
		}
	}

	private var diffLines: [EditorDiffLine] {
		let original = document.initialContent.components(separatedBy: .newlines)
		let current = text.components(separatedBy: .newlines)
		let maxCount = max(original.count, current.count)
		var output = [EditorDiffLine]()
		for index in 0..<maxCount {
			let old = index < original.count ? original[index] : nil
			let new = index < current.count ? current[index] : nil
			if old == new, let old {
				output.append(EditorDiffLine(prefix: " ", text: old, tint: .white.opacity(0.66)))
			} else {
				if let old { output.append(EditorDiffLine(prefix: "-", text: old, tint: AppColor.coral)) }
				if let new { output.append(EditorDiffLine(prefix: "+", text: new, tint: AppColor.green)) }
			}
		}
		return output
	}

	private func insertCompletion(_ suggestion: String) {
		if text.isEmpty || text.hasSuffix("\n") {
			text += suggestion
		} else {
			text += " " + suggestion
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

private struct EditorDiffLine: Identifiable {
	let id = UUID()
	let prefix: String
	let text: String
	let tint: Color
}

private struct EditorDiffView: View {
	let lines: [EditorDiffLine]

	var body: some View {
		ScrollView([.vertical, .horizontal]) {
			LazyVStack(alignment: .leading, spacing: 3) {
				ForEach(lines) { line in
					Text("\(line.prefix) \(line.text)")
						.font(.system(.footnote, design: .monospaced))
						.foregroundStyle(line.tint)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			.padding(18)
		}
		.background(AppColor.ink.opacity(0.98))
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


private struct SnippetDraft: Identifiable {
	var id: UUID
	var title: String
	var body: String
	var category: String

	init(snippet: WorkspaceSnippet?) {
		id = snippet?.id ?? UUID()
		title = snippet?.title ?? ""
		body = snippet?.body ?? ""
		category = snippet?.category ?? "Custom"
	}

	var snippet: WorkspaceSnippet {
		WorkspaceSnippet(id: id, title: title, body: body, category: category)
	}
}

private struct SnippetEditorSheet: View {
	@Environment(\.dismiss) private var dismiss
	@State private var draft: SnippetDraft
	let save: (WorkspaceSnippet) -> Void

	init(draft: SnippetDraft, save: @escaping (WorkspaceSnippet) -> Void) {
		_draft = State(initialValue: draft)
		self.save = save
	}

	var body: some View {
		NavigationStack {
			Form {
				TextField("Title", text: $draft.title)
				TextField("Category", text: $draft.category)
				TextField("Command", text: $draft.body, axis: .vertical)
					.lineLimit(3...8)
			}
			.navigationTitle("Snippet")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						save(draft.snippet)
						dismiss()
					}
				}
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
	var platform: SSHHostPlatform
	var password: String
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
		platform = profile?.platform ?? .linux
		password = profile.map { WorkspaceStore.shared.sshPassword(for: $0.id) } ?? ""
		port = profile?.port ?? 22
		privateKeyPath = profile?.privateKeyPath ?? ""
		startupPath = profile?.startupPath ?? ""
		notes = profile?.notes ?? ""
		lastSeen = profile?.lastSeen
	}

	var profile: SSHProfileSummary {
		SSHProfileSummary(id: id, label: label, host: host, username: username, authKind: authKind, lastSeen: lastSeen, port: port, privateKeyPath: privateKeyPath, startupPath: startupPath, notes: notes, platform: platform)
	}
}

private struct SSHProfileEditorSheet: View {
	@Environment(\.dismiss) private var dismiss
	@State private var draft: SSHProfileDraft
	let save: (SSHProfileSummary, String) -> Void

	init(draft: SSHProfileDraft, save: @escaping (SSHProfileSummary, String) -> Void) {
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
				Picker("Host OS", selection: $draft.platform) {
					ForEach(SSHHostPlatform.allCases) { platform in
						Text(platform.title).tag(platform)
					}
				}
				Picker("Auth", selection: $draft.authKind) {
					ForEach(SSHAuthKind.allCases) { kind in
						Text(kind.title).tag(kind)
					}
				}
				if draft.authKind == .password {
					SecureField("Password stored in Keychain", text: $draft.password)
					Text("OpenTerm copies this password before opening SSH. Paste it into the interactive password prompt; background polling still requires key/agent auth.")
						.font(.footnote)
						.foregroundStyle(.secondary)
				}
				if draft.authKind == .key || draft.authKind == .certificate {
					TextField("Private key path", text: $draft.privateKeyPath)
				}
				TextField("Startup path", text: $draft.startupPath)
				TextField("Notes", text: $draft.notes, axis: .vertical)
			}
			.navigationTitle("SSH Profile")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						save(draft.profile, draft.password)
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


private struct EmptyStateCard: View {
	let title: String
	let detail: String
	let symbol: String

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Image(systemName: symbol)
				.font(.system(size: 22, weight: .semibold))
				.foregroundStyle(.primary)
			Text(title)
				.font(.system(.headline, design: .default, weight: .semibold))
				.foregroundStyle(.primary)
			Text(detail)
				.font(.system(.subheadline, design: .default))
				.foregroundStyle(.secondary)
		}
		.padding(18)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(WorkspaceCardBackground(tint: AppColor.amber))
	}
}


private struct NativeDocumentBrowserSheet: UIViewControllerRepresentable {
	let onPick: ([URL]) -> Void

	func makeUIViewController(context: Context) -> UIDocumentBrowserViewController {
		let browser = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: ["public.item"])
		browser.delegate = context.coordinator
		browser.allowsDocumentCreation = false
		browser.allowsPickingMultipleItems = true
		return browser
	}

	func updateUIViewController(_ uiViewController: UIDocumentBrowserViewController, context: Context) {}

	func makeCoordinator() -> Coordinator {
		Coordinator(onPick: onPick)
	}

	final class Coordinator: NSObject, UIDocumentBrowserViewControllerDelegate {
		let onPick: ([URL]) -> Void

		init(onPick: @escaping ([URL]) -> Void) {
			self.onPick = onPick
		}

		func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
			onPick(documentURLs)
		}

		func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
			onPick([destinationURL])
		}
	}
}

private struct DocumentImportPicker: UIViewControllerRepresentable {
	let onImport: ([URL]) -> Void

	func makeCoordinator() -> Coordinator {
		Coordinator(onImport: onImport)
	}

	func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
		let picker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
		picker.allowsMultipleSelection = true
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

	final class Coordinator: NSObject, UIDocumentPickerDelegate {
		let onImport: ([URL]) -> Void

		init(onImport: @escaping ([URL]) -> Void) {
			self.onImport = onImport
		}

		func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
			onImport(urls)
		}
	}
}

private struct ActivityShareSheet: UIViewControllerRepresentable {
	let url: URL

	func makeUIViewController(context: Context) -> UIActivityViewController {
		UIActivityViewController(activityItems: [url], applicationActivities: nil)
	}

	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


private struct WorkspaceListBackground: View {
	let tint: Color

	var body: some View {
		RoundedRectangle(cornerRadius: 22, style: .continuous)
			.fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.92))
			.overlay(
				RoundedRectangle(cornerRadius: 22, style: .continuous)
					.strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.8)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 22, style: .continuous)
					.fill(LinearGradient(colors: [tint.opacity(0.08), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
			)
			.shadow(color: tint.opacity(0.08), radius: 16, x: 0, y: 8)
	}
}

private struct WorkspaceCardBackground: View {
	let tint: Color

	var body: some View {
		Group {
			if #available(iOS 26.0, *) {
				cardShape
					.fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.66))
					.overlay(cardShape.fill(LinearGradient(colors: [tint.opacity(0.18), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)))
					.overlay(cardShape.strokeBorder(tint.opacity(0.24), lineWidth: 0.9))
					.glassEffect(.regular.tint(tint.opacity(0.12)), in: .rect(cornerRadius: 24))
			} else {
				cardShape
					.fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.94))
					.overlay(cardShape.fill(LinearGradient(colors: [tint.opacity(0.10), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)))
					.overlay(cardShape.strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.8))
			}
		}
		.shadow(color: tint.opacity(0.10), radius: 18, x: 0, y: 10)
	}

	private var cardShape: RoundedRectangle {
		RoundedRectangle(cornerRadius: 24, style: .continuous)
	}
}

private struct WorkspaceBackdrop: View {
	var body: some View {
		ZStack {
			Color(uiColor: .systemGroupedBackground)
			LinearGradient(
				colors: [
					Color(uiColor: .systemBackground),
					Color(uiColor: .secondarySystemGroupedBackground).opacity(0.84),
					Color(uiColor: .systemGroupedBackground)
				],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
			Circle()
				.fill(AppColor.blue.opacity(0.13))
				.frame(width: 280, height: 280)
				.blur(radius: 48)
				.offset(x: -150, y: -260)
			Circle()
				.fill(AppColor.amber.opacity(0.10))
				.frame(width: 240, height: 240)
				.blur(radius: 54)
				.offset(x: 170, y: 120)
		}
	}
}
