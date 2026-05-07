import SwiftUI

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
		.tint(Color(red: 0.35, green: 0.60, blue: 0.98))
		.onReceive(NotificationCenter.default.publisher(for: .workspaceDidRequestTerminalFocus)) { _ in
			selection = .terminal
		}
	}

	private var compactLayout: some View {
		TabView(selection: $selection) {
			NavigationStack {
				WorkspaceHomeView(store: store, selection: $selection)
			}
			.tag(WorkspaceDestination.home)
			.tabItem {
				Label("Workspace", systemImage: WorkspaceDestination.home.systemImage)
			}

			NavigationStack {
				FilesWorkspaceView(store: store)
			}
			.tag(WorkspaceDestination.files)
			.tabItem {
				Label("Files", systemImage: WorkspaceDestination.files.systemImage)
			}

			LegacyTerminalContainerView()
				.tag(WorkspaceDestination.terminal)
				.tabItem {
					Label("Terminal", systemImage: WorkspaceDestination.terminal.systemImage)
				}

			NavigationStack {
				ServersWorkspaceView(store: store, selection: $selection)
			}
			.tag(WorkspaceDestination.servers)
			.tabItem {
				Label("Servers", systemImage: WorkspaceDestination.servers.systemImage)
			}

			NavigationStack {
				WorkspaceAssistantView(store: store)
			}
			.tag(WorkspaceDestination.assistant)
			.tabItem {
				Label("AI", systemImage: WorkspaceDestination.assistant.systemImage)
			}

			NavigationStack {
				GitWorkspaceView(store: store, selection: $selection)
			}
			.tag(WorkspaceDestination.git)
			.tabItem {
				Label("Git", systemImage: WorkspaceDestination.git.systemImage)
			}

			NavigationStack {
				SettingsWorkspaceView(store: store)
			}
			.tag(WorkspaceDestination.settings)
			.tabItem {
				Label("Settings", systemImage: WorkspaceDestination.settings.systemImage)
			}
		}
		.background(WorkspaceBackdrop().ignoresSafeArea())
	}

	private var regularLayout: some View {
		NavigationSplitView {
			List(selection: $selection) {
				ForEach(WorkspaceDestination.allCases) { destination in
					Label(destination.title, systemImage: destination.systemImage)
						.tag(destination)
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
			NavigationStack {
				WorkspaceHomeView(store: store, selection: $selection)
			}
		case .terminal:
			LegacyTerminalContainerView()
		case .files:
			NavigationStack {
				FilesWorkspaceView(store: store)
			}
		case .git:
			NavigationStack {
				GitWorkspaceView(store: store, selection: $selection)
			}
		case .servers:
			NavigationStack {
				ServersWorkspaceView(store: store, selection: $selection)
			}
		case .assistant:
			NavigationStack {
				WorkspaceAssistantView(store: store)
			}
		case .settings:
			NavigationStack {
				SettingsWorkspaceView(store: store)
			}
		}
	}
}

private struct WorkspaceHomeView: View {

	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {
				HeroPanel(selection: $selection)
				quickActions
				sectionHeader(title: "Live Sessions", subtitle: "Jump back into local, SSH, and container work.")
				featureGrid(items: store.recentSessions.map {
					WorkspaceFeature(title: $0.title, detail: "\($0.subtitle)\n\($0.detail)", symbol: $0.symbol, tint: $0.tint)
				})
				sectionHeader(title: "SSH Quick Connect", subtitle: "Saved hosts should feel one tap away, not buried in settings.")
				sshQuickConnect
				sectionHeader(title: "AI Tools", subtitle: "Built for command generation, debugging, and repo help.")
				featureGrid(items: store.aiTools)
				sectionHeader(title: "Premium Surface", subtitle: "Worth paying for because it saves time or prevents mistakes.")
				featureGrid(items: store.premiumFeatures)
			}
			.padding(20)
			.padding(.bottom, 32)
		}
		.background(WorkspaceBackdrop().ignoresSafeArea())
		.navigationTitle("OpenTerm")
		.navigationBarTitleDisplayMode(.large)
		.toolbar {
			ToolbarItemGroup(placement: .topBarTrailing) {
				Button {
					selection = .assistant
				} label: {
					Image(systemName: "sparkles")
				}
				.keyboardShortcut("k", modifiers: [.command])

				Button {
					selection = .terminal
				} label: {
					Image(systemName: "plus.square.on.square")
				}
				.keyboardShortcut("t", modifiers: [.command])
			}
		}
	}

	private var quickActions: some View {
		VStack(alignment: .leading, spacing: 16) {
			sectionHeader(title: "Quick Actions", subtitle: "Clean entry points for the most common developer flows.")

			if #available(iOS 26.0, *) {
				GlassEffectContainer(spacing: 16) {
					actionRow
				}
			} else {
				actionRow
			}
		}
	}

	private var actionRow: some View {
		VStack(spacing: 14) {
			HStack(spacing: 14) {
				WorkspaceActionButton(title: "New Session", subtitle: "Local or SSH", symbol: "plus.square.on.square", tint: Color(red: 0.29, green: 0.57, blue: 0.95)) {
					selection = .terminal
				}

				WorkspaceActionButton(title: "Quick Connect", subtitle: "Saved hosts", symbol: "bolt.horizontal.circle", tint: Color(red: 0.31, green: 0.72, blue: 0.57)) {
					selection = .servers
				}
			}

			HStack(spacing: 14) {
				WorkspaceActionButton(title: "Open Files", subtitle: "Edit and preview", symbol: "doc.text", tint: Color(red: 0.96, green: 0.60, blue: 0.24)) {
					selection = .files
				}

				WorkspaceActionButton(title: "Git Status", subtitle: "Repo overview", symbol: "point.topleft.down.curvedto.point.bottomright.up", tint: Color(red: 0.55, green: 0.47, blue: 0.96)) {
					selection = .git
				}
			}
		}
	}

	private var sshQuickConnect: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 14) {
				ForEach(store.sshProfiles) { profile in
					Button {
						selection = .terminal
					} label: {
						VStack(alignment: .leading, spacing: 8) {
							Text(profile.label)
								.font(.system(.headline, design: .rounded, weight: .semibold))
								.foregroundStyle(.white)
							Text("\(profile.username)@\(profile.host)")
								.font(.system(.subheadline, design: .monospaced))
								.foregroundStyle(.white.opacity(0.72))
							Text("Port \(profile.port) / \(profile.authKind)")
								.font(.system(.footnote, design: .rounded))
								.foregroundStyle(.white.opacity(0.66))
						}
						.padding(18)
						.frame(width: 240, alignment: .leading)
						.background(WorkspaceCardBackground(tint: Color(red: 0.31, green: 0.72, blue: 0.57)))
					}
					.buttonStyle(.plain)
				}
			}
			.padding(.vertical, 2)
		}
	}

	private func sectionHeader(title: String, subtitle: String) -> some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(title)
				.font(.system(.title3, design: .rounded, weight: .semibold))
				.foregroundStyle(.white)
			Text(subtitle)
				.font(.system(.subheadline, design: .rounded))
				.foregroundStyle(.white.opacity(0.72))
		}
	}

	private func featureGrid(items: [WorkspaceFeature]) -> some View {
		LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
			ForEach(items) { item in
				WorkspaceFeatureCard(feature: item)
			}
		}
	}
}

private struct FilesWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore

	var body: some View {
		List {
			Section {
				Text("Local file manager, code editor, and quick-open should all grow from the same documents foundation. This section already reads the app sandbox documents folder through `DocumentManager`.")
					.font(.system(.subheadline, design: .rounded))
					.foregroundStyle(.secondary)
			}

			Section("Recent Files") {
				ForEach(store.localFiles) { file in
					HStack(alignment: .top, spacing: 12) {
						Image(systemName: file.isDirectory ? "folder.fill" : "doc.text")
							.foregroundStyle(file.isDirectory ? .blue : .secondary)
						VStack(alignment: .leading, spacing: 4) {
							Text(file.name)
								.font(.system(.headline, design: .rounded, weight: .semibold))
							Text(file.relativePath)
								.font(.system(.footnote, design: .monospaced))
								.foregroundStyle(.secondary)
							Text("\(file.sizeDescription) / \(file.modifiedDescription)")
								.font(.system(.footnote, design: .rounded))
								.foregroundStyle(.secondary)
						}
					}
					.padding(.vertical, 4)
				}
			}

			Section("Planned Editor Upgrades") {
				Text("Syntax highlighting")
				Text("Inline AI code assistant")
				Text("Diff and blame views")
				Text("Keyboard-first editing on iPad")
			}
		}
		.scrollContentBackground(.hidden)
		.background(WorkspaceBackdrop().ignoresSafeArea())
		.navigationTitle("Files")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("Refresh") {
					store.refreshLocalFiles()
				}
			}
		}
	}
}

private struct GitWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				WorkspaceSummaryBanner(
					title: "Git Workspace",
					detail: "Status, branch context, and AI-assisted diffs should be first-class, not hidden behind raw shell commands.",
					tint: Color(red: 0.29, green: 0.57, blue: 0.95)
				)

				ForEach(store.gitWorkspaces) { repo in
					VStack(alignment: .leading, spacing: 10) {
						Text(repo.name)
							.font(.system(.title3, design: .rounded, weight: .semibold))
							.foregroundStyle(.white)
						Text("Branch: \(repo.branch)")
							.font(.system(.subheadline, design: .monospaced))
							.foregroundStyle(.white.opacity(0.72))
						Text("State: \(repo.status)")
							.font(.system(.subheadline, design: .rounded))
							.foregroundStyle(.white.opacity(0.72))
						Text("Remote: \(repo.aheadBehind)")
							.font(.system(.footnote, design: .rounded))
							.foregroundStyle(.white.opacity(0.60))

						HStack(spacing: 10) {
							WorkspaceMiniButton(title: "Open Terminal") {
								selection = .terminal
							}
							WorkspaceMiniButton(title: "Ask AI") {
								selection = .assistant
							}
						}
					}
					.padding(18)
					.background(WorkspaceCardBackground(tint: Color(red: 0.29, green: 0.57, blue: 0.95)))
				}
			}
			.padding(20)
			.padding(.bottom, 32)
		}
		.background(WorkspaceBackdrop().ignoresSafeArea())
		.navigationTitle("Git")
	}
}

private struct ServersWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore
	@Binding var selection: WorkspaceDestination

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				WorkspaceSummaryBanner(
					title: "Servers",
					detail: "The server layer should combine SSH quick connect, health snapshots, and premium alerts in one place.",
					tint: Color(red: 0.31, green: 0.72, blue: 0.57)
				)

				Text("SSH Profiles")
					.font(.system(.title3, design: .rounded, weight: .semibold))
					.foregroundStyle(.white)

				ForEach(store.sshProfiles) { profile in
					VStack(alignment: .leading, spacing: 8) {
						Text(profile.label)
							.font(.system(.headline, design: .rounded, weight: .semibold))
							.foregroundStyle(.white)
						Text("\(profile.username)@\(profile.host):\(profile.port)")
							.font(.system(.subheadline, design: .monospaced))
							.foregroundStyle(.white.opacity(0.72))
						Text("\(profile.authKind) / Last used \(profile.lastSeen)")
							.font(.system(.footnote, design: .rounded))
							.foregroundStyle(.white.opacity(0.66))

						WorkspaceMiniButton(title: "Connect") {
							selection = .terminal
						}
					}
					.padding(18)
					.background(WorkspaceCardBackground(tint: Color(red: 0.31, green: 0.72, blue: 0.57)))
				}

				Text("Live Monitoring")
					.font(.system(.title3, design: .rounded, weight: .semibold))
					.foregroundStyle(.white)

				LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
					ForEach(store.serverSnapshots) { snapshot in
						VStack(alignment: .leading, spacing: 10) {
							Text(snapshot.name)
								.font(.system(.headline, design: .rounded, weight: .semibold))
								.foregroundStyle(.white)
							Text("CPU \(snapshot.cpu) / RAM \(snapshot.memory)")
								.font(.system(.subheadline, design: .rounded))
								.foregroundStyle(.white.opacity(0.74))
							Text("Disk \(snapshot.disk) / Net \(snapshot.network)")
								.font(.system(.subheadline, design: .rounded))
								.foregroundStyle(.white.opacity(0.74))
							Text(snapshot.alertState)
								.font(.system(.footnote, design: .rounded))
								.foregroundStyle(snapshot.tint)
						}
						.padding(18)
						.frame(maxWidth: .infinity, alignment: .leading)
						.background(WorkspaceCardBackground(tint: snapshot.tint))
					}
				}
			}
			.padding(20)
			.padding(.bottom, 32)
		}
		.background(WorkspaceBackdrop().ignoresSafeArea())
		.navigationTitle("Servers")
	}
}

private struct WorkspaceAssistantView: View {

	@ObservedObject var store: WorkspaceStore
	@State private var prompt: String = "Turn my goal into commands"

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 18) {
				Text("AI Command Center")
					.font(.system(.largeTitle, design: .rounded, weight: .bold))
					.foregroundStyle(.white)

				Text("This shell should sell automation, not just chat. Every premium AI feature should map to a concrete developer outcome.")
					.font(.system(.body, design: .rounded))
					.foregroundStyle(.white.opacity(0.76))

				VStack(alignment: .leading, spacing: 12) {
					Text("Suggested prompt")
						.font(.system(.headline, design: .rounded, weight: .semibold))
						.foregroundStyle(.white)
					TextField("Ask OpenTerm AI", text: $prompt)
						.textFieldStyle(.roundedBorder)
					Text("Examples: explain this SSH error, generate a Docker command, fix this shell script, convert bash to zsh, or summarize a Git diff.")
						.font(.system(.footnote, design: .rounded))
						.foregroundStyle(.white.opacity(0.68))
				}
				.padding(20)
				.background(WorkspaceCardBackground(tint: Color(red: 0.55, green: 0.47, blue: 0.96)))

				ForEach(store.aiTools) { tool in
					WorkspaceFeatureCard(feature: tool)
				}
			}
			.padding(20)
			.padding(.bottom, 32)
		}
		.background(WorkspaceBackdrop().ignoresSafeArea())
		.navigationTitle("AI")
		.navigationBarTitleDisplayMode(.inline)
	}
}

private struct SettingsWorkspaceView: View {

	@ObservedObject var store: WorkspaceStore

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				WorkspaceSummaryBanner(
					title: "Premium + Settings",
					detail: "Digital entitlements need a compliant split: StoreKit 2 inside App Store builds, Stripe Checkout on the web account side, and Supabase as the backend source of truth.",
					tint: Color(red: 0.55, green: 0.47, blue: 0.96)
				)

				VStack(alignment: .leading, spacing: 10) {
					Text("Current Theme")
						.font(.system(.headline, design: .rounded, weight: .semibold))
						.foregroundStyle(.white)
					Text(store.activeThemeName)
						.font(.system(.title3, design: .rounded, weight: .bold))
						.foregroundStyle(.white)
					Text(store.billingSourceDescription)
						.font(.system(.subheadline, design: .rounded))
						.foregroundStyle(.white.opacity(0.72))
				}
				.padding(18)
				.background(WorkspaceCardBackground(tint: Color(red: 0.55, green: 0.47, blue: 0.96)))

				ForEach(store.premiumPlans) { plan in
					VStack(alignment: .leading, spacing: 12) {
						Text(plan.name)
							.font(.system(.title3, design: .rounded, weight: .bold))
							.foregroundStyle(.white)
						Text(plan.price)
							.font(.system(.headline, design: .rounded, weight: .semibold))
							.foregroundStyle(plan.tint)
						Text(plan.highlight)
							.font(.system(.subheadline, design: .rounded))
							.foregroundStyle(.white.opacity(0.72))

						ForEach(plan.features, id: \.self) { feature in
							Label(feature, systemImage: "checkmark.circle.fill")
								.font(.system(.subheadline, design: .rounded))
								.foregroundStyle(.white.opacity(0.78))
						}
					}
					.padding(18)
					.background(WorkspaceCardBackground(tint: plan.tint))
				}
			}
			.padding(20)
			.padding(.bottom, 32)
		}
		.background(WorkspaceBackdrop().ignoresSafeArea())
		.navigationTitle("Settings")
	}
}

private struct HeroPanel: View {

	@Binding var selection: WorkspaceDestination

	var body: some View {
		VStack(alignment: .leading, spacing: 18) {
			Text("Raycast-speed workflows, terminal-first power, and a friendlier mobile UX.")
				.font(.system(.largeTitle, design: .rounded, weight: .bold))
				.foregroundStyle(.white)
				.fixedSize(horizontal: false, vertical: true)

			Text("OpenTerm is shifting from a single-screen shell into a modern mobile developer workspace for terminal sessions, SSH, files, Git, servers, and AI.")
				.font(.system(.body, design: .rounded))
				.foregroundStyle(.white.opacity(0.78))

			HStack(spacing: 12) {
				heroButton(title: "Launch Terminal", systemImage: "terminal", prominent: true) {
					selection = .terminal
				}
				heroButton(title: "Explore AI", systemImage: "sparkles", prominent: false) {
					selection = .assistant
				}
			}

			HStack(spacing: 12) {
				WorkspaceStatPill(title: "iOS Baseline", value: "18+")
				WorkspaceStatPill(title: "Latest SDK", value: "26.4")
				WorkspaceStatPill(title: "Shell Model", value: "SwiftUI")
			}
		}
		.padding(24)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(WorkspaceCardBackground(tint: Color(red: 0.28, green: 0.41, blue: 0.86)))
	}

	@ViewBuilder
	private func heroButton(title: String, systemImage: String, prominent: Bool, action: @escaping () -> Void) -> some View {
		let label = Label(title, systemImage: systemImage)
			.font(.system(.headline, design: .rounded, weight: .semibold))
			.frame(maxWidth: .infinity)

		if #available(iOS 26.0, *) {
			if prominent {
				Button(action: action) {
					label
				}
				.buttonStyle(.glassProminent)
			} else {
				Button(action: action) {
					label
				}
				.buttonStyle(.glass)
			}
		} else {
			if prominent {
				Button(action: action) {
					label
				}
				.buttonStyle(.borderedProminent)
				.tint(Color.white.opacity(0.22))
			} else {
				Button(action: action) {
					label
				}
				.buttonStyle(.bordered)
				.tint(Color.white.opacity(0.12))
			}
		}
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

private struct WorkspaceFeatureCard: View {

	let feature: WorkspaceFeature

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Image(systemName: feature.symbol)
				.font(.system(size: 18, weight: .semibold))
				.foregroundStyle(feature.tint)
				.frame(width: 40, height: 40)
				.background(feature.tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

			Text(feature.title)
				.font(.system(.headline, design: .rounded, weight: .semibold))
				.foregroundStyle(.white)

			Text(feature.detail)
				.font(.system(.subheadline, design: .rounded))
				.foregroundStyle(.white.opacity(0.74))
				.frame(maxWidth: .infinity, alignment: .leading)
		}
		.padding(18)
		.frame(maxWidth: .infinity, minHeight: 156, alignment: .topLeading)
		.background(WorkspaceCardBackground(tint: feature.tint))
	}
}

private struct WorkspaceActionButton: View {

	let title: String
	let subtitle: String
	let symbol: String
	let tint: Color
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			VStack(alignment: .leading, spacing: 10) {
				Image(systemName: symbol)
					.font(.system(size: 18, weight: .semibold))
					.foregroundStyle(tint)
				Text(title)
					.font(.system(.headline, design: .rounded, weight: .semibold))
					.foregroundStyle(.white)
				Text(subtitle)
					.font(.system(.subheadline, design: .rounded))
					.foregroundStyle(.white.opacity(0.7))
			}
			.padding(18)
			.frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
			.background(WorkspaceCardBackground(tint: tint))
		}
		.buttonStyle(.plain)
	}
}

private struct WorkspaceMiniButton: View {

	let title: String
	let action: () -> Void

	var body: some View {
		Button(title, action: action)
			.buttonStyle(.borderedProminent)
	}
}

private struct WorkspaceStatPill: View {

	let title: String
	let value: String

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(title.uppercased())
				.font(.system(size: 11, weight: .bold, design: .rounded))
				.foregroundStyle(.white.opacity(0.56))
			Text(value)
				.font(.system(.headline, design: .rounded, weight: .semibold))
				.foregroundStyle(.white)
		}
		.padding(.horizontal, 14)
		.padding(.vertical, 10)
		.background(Color.white.opacity(0.08), in: Capsule())
	}
}

private struct WorkspaceCardBackground: View {

	let tint: Color

	var body: some View {
		Group {
			if #available(iOS 26.0, *) {
				RoundedRectangle(cornerRadius: 26, style: .continuous)
					.fill(tint.opacity(0.10))
					.overlay(
						RoundedRectangle(cornerRadius: 26, style: .continuous)
							.strokeBorder(Color.white.opacity(0.12), lineWidth: 0.8)
					)
					.glassEffect(.regular.tint(tint.opacity(0.18)), in: .rect(cornerRadius: 26))
			} else {
				RoundedRectangle(cornerRadius: 26, style: .continuous)
					.fill(.ultraThinMaterial)
					.overlay(
						RoundedRectangle(cornerRadius: 26, style: .continuous)
							.strokeBorder(Color.white.opacity(0.10), lineWidth: 0.8)
					)
			}
		}
	}
}

private struct WorkspaceBackdrop: View {

	var body: some View {
		ZStack {
			LinearGradient(
				colors: [
					Color(red: 0.08, green: 0.10, blue: 0.15),
					Color(red: 0.11, green: 0.16, blue: 0.23),
					Color(red: 0.06, green: 0.07, blue: 0.11),
				],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)

			Circle()
				.fill(Color(red: 0.28, green: 0.41, blue: 0.86).opacity(0.28))
				.blur(radius: 90)
				.offset(x: -120, y: -260)

			Circle()
				.fill(Color(red: 0.27, green: 0.75, blue: 0.64).opacity(0.22))
				.blur(radius: 110)
				.offset(x: 150, y: 220)
		}
	}
}
