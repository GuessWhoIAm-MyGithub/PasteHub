import SwiftUI
import AppKit
import ApplicationServices

private enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case hotkey
    case excludedApps
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: return "通用"
        case .hotkey: return "快捷键"
        case .excludedApps: return "排除应用"
        case .about: return "关于"
        }
    }

    var systemImage: String {
        switch self {
        case .general: return "gearshape"
        case .hotkey: return "keyboard"
        case .excludedApps: return "hand.raised.slash"
        case .about: return "info.circle"
        }
    }
}

struct SettingsView: View {
    var settings: SettingsManager
    @State private var selection: SettingsSection? = .general

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            HStack(spacing: 18) {
                VStack(spacing: 0) {
                    SettingsSidebarHeader()

                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(SettingsSection.allCases) { section in
                                SettingsSidebarRow(
                                    section: section,
                                    isSelected: selection == section
                                ) {
                                    selection = section
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 12)
                    }
                }
                .frame(width: 220)
                .frame(maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(nsColor: .underPageBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
                )

                Group {
                    if let selection {
                        SettingsDetailView(section: selection, settings: settings)
                    } else {
                        ContentUnavailableView("选择设置项", systemImage: "sidebar.left")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))
            }
            .padding(14)
        }
        .frame(minWidth: 880, minHeight: 600)
    }
}

private struct SettingsSidebarRow: View {
    let section: SettingsSection
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: section.systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 18)

                Text(section.title)
                    .font(.system(size: 13, weight: .semibold))

                Spacer(minLength: 0)
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected ? Color.accentColor : Color.clear,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsDetailView: View {
    let section: SettingsSection
    let settings: SettingsManager

    @ViewBuilder
    private var content: some View {
        switch section {
        case .general:
            GeneralTab(settings: settings)
        case .hotkey:
            HotkeyTab(settings: settings)
        case .excludedApps:
            ExcludedAppsTab(settings: settings)
        case .about:
            AboutTab()
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            SettingsPageHeader(section: section)
            Group {
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct SettingsSidebarHeader: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 42, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("PasteHub")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text("版本 \(version)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
}

private struct SettingsPageHeader: View {
    let section: SettingsSection

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: section.systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 38, height: 38)
                .background(
                    Color.accentColor.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(section.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 10)
    }
}

private struct SettingsPane<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                content
            }
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.top, 14)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }
}

private struct SettingsCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        title = ""
        subtitle = nil
        self.content = content()
    }

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SettingsRow<Accessory: View>: View {
    let title: String
    let subtitle: String?
    let accessoryColumnWidth: CGFloat
    let accessory: Accessory

    init(
        title: String,
        subtitle: String? = nil,
        accessoryColumnWidth: CGFloat = 220,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.subtitle = subtitle
        self.accessoryColumnWidth = accessoryColumnWidth
        self.accessory = accessory()
    }

    var body: some View {
        HStack(alignment: subtitle == nil ? .center : .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 12)

            accessory
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .frame(width: accessoryColumnWidth, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SettingsMetricRow: View {
    let title: String
    let value: String
    var allowsSelection: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))

            Spacer(minLength: 12)

            Group {
                if allowsSelection {
                    Text(value)
                        .textSelection(.enabled)
                } else {
                    Text(value)
                }
            }
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SettingsHint: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - General

private struct GeneralTab: View {
    @Bindable var settings: SettingsManager

    private let countOptions = [10, 20, 50, 100, 200, 500]

    var body: some View {
        SettingsPane {
            SettingsCard(
                title: "历史记录",
                subtitle: "控制自动保留的剪贴板历史数量。"
            ) {
                SettingsRow(
                    title: "最大保留条数",
                    subtitle: "超过上限后，旧记录会自动按时间清理。"
                ) {
                    Picker("最大保留条数", selection: $settings.maxHistoryCount) {
                        ForEach(countOptions, id: \.self) { count in
                            Text("\(count) 条").tag(count)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 120, alignment: .trailing)
                }
            }

            SettingsCard(
                title: "系统",
                subtitle: "管理 PasteHub 与系统的集成方式。"
            ) {
                SettingsRow(
                    title: "开机自动启动",
                    subtitle: "登录后自动在后台启动 PasteHub。"
                ) {
                    Toggle("", isOn: $settings.launchAtLogin)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
            }

            SettingsCard(
                title: "面板",
                subtitle: "控制主面板和精简面板的显示行为。"
            ) {
                VStack(alignment: .leading, spacing: 14) {
                    SettingsRow(
                        title: "默认弹出位置",
                        subtitle: "仅对非精简模式生效。"
                    ) {
                        Picker("弹出位置", selection: $settings.panelEdge) {
                            ForEach(PanelEdge.allCases) { edge in
                                Text(edge.title).tag(edge)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 110, alignment: .trailing)
                        .disabled(settings.compactModeEnabled)
                    }

                    Divider()

                    SettingsRow(
                        title: "精简模式",
                        subtitle: "点击状态栏图标时直接弹出紧凑面板。"
                    ) {
                        Toggle("", isOn: $settings.compactModeEnabled)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }

                    Divider()

                    SettingsRow(
                        title: "精简面板大小",
                        subtitle: "小 / 中 / 大分别按屏幕高度的 45% / 60% / 75% 计算。"
                    ) {
                        Picker("精简面板大小", selection: $settings.compactPanelSize) {
                            ForEach(CompactPanelSize.allCases) { size in
                                Text(size.title).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: 210, alignment: .trailing)
                        .disabled(!settings.compactModeEnabled)
                    }
                }
            }
        }
    }
}

// MARK: - Hotkey

private struct HotkeyTab: View {
    var settings: SettingsManager
    @State private var isAccessibilityTrusted = AXIsProcessTrusted()
    @State private var lastCheckedAt = Date()

    private var executablePath: String {
        Bundle.main.executableURL?.path ?? "未知"
    }

    private var bundlePath: String {
        Bundle.main.bundleURL.path
    }

    private var bundleID: String {
        Bundle.main.bundleIdentifier ?? "未知"
    }

    private var processID: String {
        String(ProcessInfo.processInfo.processIdentifier)
    }

    var body: some View {
        SettingsPane {
            SettingsCard(
                title: "全局快捷键",
                subtitle: "录制新的组合键后即可立即生效。"
            ) {
                VStack(alignment: .leading, spacing: 14) {
                    SettingsRow(
                        title: "显示 / 隐藏面板",
                        subtitle: "点击录制区域后直接按下新的快捷键组合，按 Esc 取消。"
                    ) {
                        HotkeyRecorderButton(
                            displayString: settings.hotkeyDisplayString,
                            onRecorded: { code, mods in
                                settings.setHotkey(keyCode: code, modifiers: mods)
                            }
                        )
                    }

                    Divider()

                    SettingsHint(text: "单击卡片会先复制内容，再尝试自动键入。首次授予辅助功能权限后建议重启 PasteHub。")
                }
            }

            SettingsCard(
                title: "内置快捷入口",
                subtitle: "应用菜单和常用操作的固定触发方式。"
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    ShortcutRow(label: "打开设置", shortcut: "\u{2318},")
                    ShortcutRow(label: "退出应用", shortcut: "\u{2318}Q")
                    ShortcutRow(label: "完成键入条目", shortcut: "单击卡片")
                    ShortcutRow(label: "重新复制 / 标签 / 删除", shortcut: "卡片按钮或右键菜单")
                }
            }

            SettingsCard(
                title: "辅助功能权限诊断",
                subtitle: "若自动键入异常，可先检查当前运行实例和系统授权是否一致。"
            ) {
                VStack(alignment: .leading, spacing: 14) {
                    SettingsRow(title: "辅助功能权限") {
                        Text(isAccessibilityTrusted ? "已授权" : "未授权")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(isAccessibilityTrusted ? .green : .red)
                    }

                    Divider()

                    SettingsMetricRow(title: "Bundle ID", value: bundleID, allowsSelection: true)
                    SettingsMetricRow(title: "进程 PID", value: processID, allowsSelection: true)
                    SettingsMetricRow(title: "上次检测", value: Self.timeFormatter.string(from: lastCheckedAt))

                    Divider()

                    VStack(alignment: .leading, spacing: 6) {
                        Text("当前可执行路径")
                            .font(.system(size: 13, weight: .semibold))
                        Text(executablePath)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("当前 Bundle 路径")
                            .font(.system(size: 13, weight: .semibold))
                        Text(bundlePath)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Divider()

                    HStack(spacing: 10) {
                        Button("刷新状态") {
                            refreshAccessibilityState()
                        }
                        .buttonStyle(.bordered)

                        Button("打开辅助功能设置") {
                            openAccessibilitySettings()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("重置提示缓存") {
                            PasteToAppService.resetAccessibilityPromptCache()
                            refreshAccessibilityState()
                        }
                        .buttonStyle(.bordered)
                    }

                    SettingsHint(text: "若路径与你在系统“辅助功能”里勾选的 PasteHub 不一致，会导致一直提示未授权。")
                }
            }
        }
        .onAppear {
            refreshAccessibilityState()
        }
    }

    private func refreshAccessibilityState() {
        isAccessibilityTrusted = AXIsProcessTrusted()
        lastCheckedAt = Date()
    }

    private func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else { return }
        NSWorkspace.shared.open(url)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()
}

private struct ShortcutRow: View {
    let label: String
    let shortcut: String

    var body: some View {
        HStack(spacing: 16) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
            Spacer(minLength: 12)
            Text(shortcut)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.secondary.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Excluded Apps

private struct ExcludedAppsTab: View {
    @Bindable var settings: SettingsManager

    private var availableApps: [(name: String, bundleID: String, icon: NSImage)] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app in
                guard let name = app.localizedName,
                      let id = app.bundleIdentifier,
                      let icon = app.icon,
                      !settings.excludedApps.contains(where: { $0.bundleIdentifier == id })
                else { return nil }
                return (name, id, icon)
            }
            .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        SettingsPane {
            SettingsCard(
                title: "排除应用",
                subtitle: "来自这些应用的剪贴板内容将不会被记录。"
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    if settings.excludedApps.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "hand.raised.slash")
                                .font(.system(size: 30, weight: .medium))
                                .foregroundStyle(.secondary)
                            Text("暂无排除应用")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            Text("可从当前正在运行的应用里快速加入排除名单。")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(settings.excludedApps.enumerated()), id: \.element.id) { index, app in
                                HStack(spacing: 12) {
                                    appIcon(for: app.bundleIdentifier)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(app.name)
                                            .font(.system(size: 13, weight: .semibold))
                                        Text(app.bundleIdentifier)
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer(minLength: 12)

                                    Button(role: .destructive) {
                                        settings.excludedApps.removeAll { $0.id == app.id }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 12)

                                if index < settings.excludedApps.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }

                    Divider()

                    Menu {
                        ForEach(availableApps, id: \.bundleID) { app in
                            Button {
                                settings.excludedApps.append(
                                    ExcludedApp(bundleIdentifier: app.bundleID, name: app.name)
                                )
                            } label: {
                                Label {
                                    Text(app.name)
                                } icon: {
                                    Image(nsImage: app.icon)
                                }
                            }
                        }

                        if availableApps.isEmpty {
                            Text("无可添加的运行中应用")
                        }
                    } label: {
                        Label("添加正在运行的应用", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .fixedSize()
                }
            }
        }
    }

    private func appIcon(for bundleID: String) -> Image {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            return Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
        }
        return Image(systemName: "app")
    }
}

// MARK: - About

private struct AboutTab: View {
    private let author = "FringHuang"
    private let email = "hfl1995@gmail.com"
    @State private var didCopyEmail = false

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }

    var body: some View {
        SettingsPane {
            SettingsCard {
                HStack(spacing: 16) {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .frame(width: 58, height: 58)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("PasteHub")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Text("简洁高效的剪贴板助手")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }
            }

            SettingsCard(
                title: "应用信息",
                subtitle: "版本、构建号与维护者信息。"
            ) {
                VStack(spacing: 12) {
                    AboutInfoRow(icon: "tag.fill", title: "版本", value: version)
                    AboutInfoRow(icon: "hammer.fill", title: "构建", value: build)
                    AboutInfoRow(icon: "person.fill", title: "作者", value: author)

                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 18)
                        Text("邮箱")
                            .font(.system(size: 13, weight: .semibold))
                        Spacer()
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(email, forType: .string)
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                                didCopyEmail = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    didCopyEmail = false
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                if didCopyEmail {
                                    Image(systemName: "checkmark.circle.fill")
                                        .transition(.scale.combined(with: .opacity))
                                }
                                Text(didCopyEmail ? "已复制" : email)
                            }
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(didCopyEmail ? .green : .secondary)
                        .scaleEffect(didCopyEmail ? 1.04 : 1.0)
                        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: didCopyEmail)
                    }
                }
            }
        }
    }
}

private struct AboutInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 18)

            Text(title)
                .font(.system(size: 13, weight: .semibold))

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
    }
}

// MARK: - Hotkey Recorder

private struct HotkeyRecorderButton: View {
    let displayString: String
    let onRecorded: (UInt16, UInt) -> Void
    @State private var isRecording = false

    var body: some View {
        ZStack {
            if isRecording {
                KeyCatcher(
                    onKey: { code, flags in
                        onRecorded(code, flags.rawValue)
                        isRecording = false
                    },
                    onCancel: { isRecording = false }
                )
                .frame(width: 0, height: 0)
            }

            Button { isRecording = true } label: {
                Text(isRecording ? "按下快捷键组合..." : displayString)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .frame(minWidth: 120)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isRecording ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(isRecording ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct KeyCatcher: NSViewRepresentable {
    let onKey: (UInt16, NSEvent.ModifierFlags) -> Void
    let onCancel: () -> Void

    func makeNSView(context: Context) -> KeyCatcherView {
        let v = KeyCatcherView()
        v.onKey = onKey
        v.onCancel = onCancel
        DispatchQueue.main.async { v.window?.makeFirstResponder(v) }
        return v
    }

    func updateNSView(_ nsView: KeyCatcherView, context: Context) {}

    class KeyCatcherView: NSView {
        var onKey: ((UInt16, NSEvent.ModifierFlags) -> Void)?
        var onCancel: (() -> Void)?

        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            let modifierKeyCodes: Set<UInt16> = [54, 55, 56, 57, 58, 59, 60, 61, 62, 63]
            guard !modifierKeyCodes.contains(event.keyCode) else { return }

            if event.keyCode == 53 { onCancel?(); return }

            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard !flags.intersection([.command, .option, .control, .shift]).isEmpty else { return }

            onKey?(event.keyCode, flags)
        }
    }
}
