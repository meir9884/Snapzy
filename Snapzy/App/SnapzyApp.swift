//
//  SnapzyApp.swift
//  Snapzy
//
//  Main app entry point - Menu Bar App
//

import AppKit
import Carbon
import CoreGraphics
import SwiftUI

// MARK: - Notification Names

extension Notification.Name {
  static let showOnboarding = Notification.Name("showOnboarding")
}

@main
struct SnapzyApp: App {
  private let localizationBootstrap: Void = AppLanguageManager.prepareDefaultLanguage()
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @ObservedObject private var themeManager = ThemeManager.shared

  init() {
    if CommandLine.arguments.contains("--check-screen-capture-granted") {
      let granted = CGPreflightScreenCaptureAccess()
      exit(granted ? 0 : 1)
    }
    AppIdentityManager.shared.refresh()
  }

  var body: some Scene {
    // Settings Window
    Settings {
      PreferencesView()
        .preferredColorScheme(themeManager.systemAppearance)
    }
  }
}

struct AppLaunchPolicy {
  private let environment: [String: String]
  private let screenCountProvider: () -> Int

  init(
    environment: [String: String] = ProcessInfo.processInfo.environment,
    screenCountProvider: @escaping () -> Int = { NSScreen.screens.count }
  ) {
    self.environment = environment
    self.screenCountProvider = screenCountProvider
  }

  var shouldStartInteractiveApplication: Bool {
    if isRunningUnderXCTest && !allowsInteractiveXCTestHost {
      return false
    }

    return !isHeadlessDisplaySession
  }

  var isRunningUnderXCTest: Bool {
    environment["XCTestConfigurationFilePath"] != nil
  }

  var isHeadlessDisplaySession: Bool {
    screenCountProvider() == 0
  }

  private var allowsInteractiveXCTestHost: Bool {
    environment["SNAPZY_ALLOW_INTERACTIVE_XCTEST_HOST"] == "1"
  }
}

// MARK: - App Delegate

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
  private let launchPolicyProvider: () -> AppLaunchPolicy
  private var coordinator: AppCoordinator?
  private var pendingDeepLinkURLs: [URL] = []
  private var pendingOpenFileURLs: [URL] = []
  private var didFinishLaunching = false

  override init() {
    self.launchPolicyProvider = { AppLaunchPolicy() }
    super.init()
  }

  init(launchPolicyProvider: @escaping () -> AppLaunchPolicy) {
    self.launchPolicyProvider = launchPolicyProvider
    super.init()
  }

  func applicationWillFinishLaunching(_ notification: Notification) {
    NSAppleEventManager.shared().setEventHandler(
      self,
      andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL)
    )
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    guard launchPolicyProvider().shouldStartInteractiveApplication else {
      return
    }

    AppIdentityManager.shared.refresh()

    guard ensureSandboxOffDataMigrationReadyForLaunch() else {
      return
    }

    guard ensureDatabaseReadyForLaunch() else {
      return
    }

    // Cleanup orphaned temp capture files from previous sessions
    TempCaptureManager.shared.cleanupOrphanedFiles()

    let coordinator = AppCoordinator(environment: AppEnvironment.live())
    self.coordinator = coordinator
    coordinator.applicationDidFinishLaunching()
    didFinishLaunching = true
    flushPendingDeepLinks()
    flushPendingOpenFileURLs()
  }

  func applicationWillTerminate(_ notification: Notification) {
    NSAppleEventManager.shared().removeEventHandler(
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL)
    )
    coordinator?.applicationWillTerminate()
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    guard didFinishLaunching else { return true }
    let showsMenuBarIcon = UserDefaults.standard.object(forKey: PreferencesKeys.showMenuBarIcon) as? Bool ?? true
    // An enabled icon can still be hidden behind the notch on a crowded menu bar (issue #587).
    let isIconObscured = showsMenuBarIcon && AppStatusBarController.shared.isMenuBarIconObscured
    guard !showsMenuBarIcon || isIconObscured else { return true }

    if isIconObscured {
      DiagnosticLogger.shared.log(.info, .ui, "Opening Settings on reopen because the menu bar icon is hidden")
    }
    AppStatusBarController.shared.openPreferencesWindow(tab: .general)
    return false
  }

  private enum DatabaseLaunchRecoveryAction {
    case repair
    case reset
    case quit
  }

  private enum SandboxOffMigrationRecoveryAction {
    case retry
    case startFresh
    case quit
  }

  private func ensureSandboxOffDataMigrationReadyForLaunch() -> Bool {
    var note: String?

    while true {
      do {
        let result = try SandboxOffDataMigrationService.shared.runIfNeeded()
        if result.didRun {
          DiagnosticLogger.shared.log(
            .info,
            .lifecycle,
            "Sandbox-off data migration completed",
            context: [
              "appSupportCopied": "\(result.copiedApplicationSupportItems)",
              "appSupportSkipped": "\(result.skippedApplicationSupportItems)",
              "appSupportErrorSkipped": "\(result.errorSkippedApplicationSupportItems)",
              "preferencesImported": "\(result.importedPreferenceKeys)",
              "preferencesSkipped": "\(result.skippedPreferenceKeys)",
              "logsCopied": "\(result.copiedLogItems)",
            ]
          )
        }
        return true
      } catch {
        switch presentSandboxOffMigrationRecoveryAlert(error: error, note: note) {
        case .retry:
          note = L10n.Recovery.retryFailed
          continue

        case .startFresh:
          guard confirmMigrationSkip(error: error) else {
            note = nil
            continue
          }
          do {
            try SandboxOffDataMigrationService.shared.skipMigration()
            DiagnosticLogger.shared.log(
              .warning,
              .lifecycle,
              "Sandbox-off data migration skipped by user (Start Fresh)"
            )
            return true
          } catch {
            note = L10n.Recovery.skipFailed(error.localizedDescription)
            continue
          }

        case .quit:
          NSApp.terminate(nil)
          return false
        }
      }
    }
  }

  private func presentSandboxOffMigrationRecoveryAlert(
    error: Error,
    note: String? = nil
  ) -> SandboxOffMigrationRecoveryAction {
    NSApp.activate(ignoringOtherApps: true)

    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = L10n.Recovery.migrationTitle

    var informativeText = L10n.Recovery.migrationMessage(error.localizedDescription)
    if let note {
      informativeText += "\n\n\(note)"
    }
    informativeText += "\n\n" + L10n.Recovery.migrationHint
    alert.informativeText = informativeText

    alert.addButton(withTitle: L10n.Recovery.tryAgain)
    alert.addButton(withTitle: L10n.Recovery.startFreshEllipsis)
    alert.addButton(withTitle: L10n.Menu.quitSnapzy)

    switch alert.runModal() {
    case .alertFirstButtonReturn:
      return .retry
    case .alertSecondButtonReturn:
      return .startFresh
    default:
      return .quit
    }
  }

  private func confirmMigrationSkip(error: Error) -> Bool {
    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = L10n.Recovery.freshTitle
    alert.informativeText = L10n.Recovery.freshMessage(
      Bundle.main.bundleIdentifier ?? "com.duongductrong.Snapzy", error.localizedDescription
    )
    alert.addButton(withTitle: L10n.Recovery.startFresh)
    alert.addButton(withTitle: L10n.Common.cancel)
    return alert.runModal() == .alertFirstButtonReturn
  }

  private func ensureDatabaseReadyForLaunch() -> Bool {
    switch DatabaseManager.prepare() {
    case .success:
      return true
    case let .failure(error):
      return presentDatabaseRecoveryFlow(startingWith: error)
    }
  }

  private func presentDatabaseRecoveryFlow(startingWith error: Error) -> Bool {
    var currentError: Error = error
    var note: String?

    while true {
      switch presentDatabaseRecoveryAlert(error: currentError, note: note) {
      case .repair:
        do {
          try DatabaseManager.attemptRepair()
          return true
        } catch {
          currentError = error
          note = L10n.Recovery.repairFailed
        }

      case .reset:
        guard confirmDatabaseReset(error: currentError) else {
          note = nil
          continue
        }

        do {
          let archive = try DatabaseManager.resetDatabaseFiles()
          switch DatabaseManager.retryInitialization() {
          case .success:
            if let archiveDirectoryURL = archive.archiveDirectoryURL {
              DiagnosticLogger.shared.log(
                .warning,
                .lifecycle,
                "Database reset during launch",
                context: ["archive": archiveDirectoryURL.path]
              )
            }
            return true
          case let .failure(error):
            currentError = error
            note = L10n.Recovery.resetInitializationFailed
          }
        } catch {
          currentError = error
          note = L10n.Recovery.resetFailed
        }

      case .quit:
        NSApp.terminate(nil)
        return false
      }
    }
  }

  private func presentDatabaseRecoveryAlert(
    error: Error,
    note: String?
  ) -> DatabaseLaunchRecoveryAction {
    NSApp.activate(ignoringOtherApps: true)

    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = L10n.Recovery.databaseTitle

    var informativeText = L10n.Recovery.databaseMessage(DatabaseManager.defaultDatabaseURL.path, error.localizedDescription)
    if let note {
      informativeText += "\n\n\(note)"
    }
    informativeText += "\n\n" + L10n.Recovery.databaseHint
    alert.informativeText = informativeText

    alert.addButton(withTitle: L10n.Recovery.tryRepair)
    alert.addButton(withTitle: L10n.Recovery.resetDatabaseEllipsis)
    alert.addButton(withTitle: L10n.Menu.quitSnapzy)

    switch alert.runModal() {
    case .alertFirstButtonReturn:
      return .repair
    case .alertSecondButtonReturn:
      return .reset
    default:
      return .quit
    }
  }

  private func confirmDatabaseReset(error: Error) -> Bool {
    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = L10n.Recovery.resetTitle
    alert.informativeText = L10n.Recovery.resetMessage(DatabaseManager.defaultDatabaseURL.path, error.localizedDescription)
    alert.addButton(withTitle: L10n.Recovery.resetDatabase)
    alert.addButton(withTitle: L10n.Common.cancel)
    return alert.runModal() == .alertFirstButtonReturn
  }

  @objc private func handleGetURLEvent(
    _ event: NSAppleEventDescriptor,
    withReplyEvent replyEvent: NSAppleEventDescriptor
  ) {
    guard
      let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
      let url = URL(string: urlString)
    else {
      DiagnosticLogger.shared.log(.warning, .action, "Received invalid URL event")
      return
    }

    guard let coordinator else {
      pendingDeepLinkURLs.append(url)
      return
    }

    coordinator.handleDeepLink(url)
  }

  private func flushPendingDeepLinks() {
    guard let coordinator, !pendingDeepLinkURLs.isEmpty else { return }

    let urls = pendingDeepLinkURLs
    pendingDeepLinkURLs.removeAll()
    urls.forEach { coordinator.handleDeepLink($0) }
  }

  // MARK: - Open With (Finder right-click → Open With → Snapzy)

  /// Called when the user opens one or more image files with Snapzy from
  /// Finder's "Open With" submenu, by double-clicking a file whose default
  /// app is Snapzy, or by drag-dropping files onto the app icon in the Dock.
  ///
  /// Files declared in `CFBundleDocumentTypes` (PNG/JPEG/HEIC/HEIF/TIFF/GIF/
  /// WebP/BMP) are routed straight into the annotation editor.
  ///
  /// Note: macOS 13+ prefers `application(_:open:)` over the legacy
  /// `application(_:openFiles:)`, and the latter is silently skipped on
  /// recent OS releases. We only act on file URLs here so that the existing
  /// Apple Event handler for `snapzy://` deep links keeps working.
  func application(_ application: NSApplication, open urls: [URL]) {
    let fileURLs = urls.filter { $0.isFileURL }
    guard !fileURLs.isEmpty else { return }

    DiagnosticLogger.shared.log(
      .info,
      .action,
      "Received open-file request",
      context: ["count": "\(fileURLs.count)"]
    )

    if didFinishLaunching {
      openImageURLs(fileURLs)
    } else {
      // Files arriving before launch finishes (e.g. a cold launch via "Open With")
      // are queued and flushed once the coordinator is ready.
      pendingOpenFileURLs.append(contentsOf: fileURLs)
    }
  }

  private func openImageURLs(_ urls: [URL]) {
    for url in urls {
      AnnotateManager.shared.openAnnotation(url: url)
    }
  }

  private func flushPendingOpenFileURLs() {
    guard !pendingOpenFileURLs.isEmpty else { return }

    let urls = pendingOpenFileURLs
    pendingOpenFileURLs.removeAll()
    openImageURLs(urls)
  }

  #if DEBUG
    var hasCoordinatorForTesting: Bool {
      coordinator != nil
    }

    var didFinishLaunchingForTesting: Bool {
      didFinishLaunching
    }

    var pendingOpenFileURLCountForTesting: Int {
      pendingOpenFileURLs.count
    }
  #endif
}
