import Foundation

extension L10n {
  nonisolated enum Recovery {
    static var retryFailed: String {
      string("crash-report.recovery.retry-failed", defaultValue: "Previous attempt also failed. If this keeps happening, Start Fresh will let you use Snapzy without old data.", comment: "Launch recovery message")
    }
    static func skipFailed(_ value0: String) -> String {
      format("crash-report.recovery.skip-failed", defaultValue: "Could not mark migration as skipped: %@", comment: "Launch recovery message", value0)
    }
    static var migrationTitle: String {
      string("crash-report.recovery.migration-title", defaultValue: "Snapzy could not migrate your existing data.", comment: "Launch recovery message")
    }
    static func migrationMessage(_ value0: String) -> String {
      format("crash-report.recovery.migration-message", defaultValue: "Snapzy needs to move data from the old sandboxed storage before opening the unsandboxed version.\n\nNo new database was opened yet, so your existing data has not been replaced.\n\nError:\n%@", comment: "Launch recovery message", value0)
    }
    static var migrationHint: String {
      string("crash-report.recovery.migration-hint", defaultValue: "Try again if the error is temporary. Start Fresh launches Snapzy with default settings — your old data stays in the sandbox container and is not deleted.", comment: "Launch recovery message")
    }
    static var tryAgain: String {
      string("crash-report.recovery.try-again", defaultValue: "Try Again", comment: "Launch recovery message")
    }
    static var startFreshEllipsis: String {
      string("crash-report.recovery.start-fresh-ellipsis", defaultValue: "Start Fresh…", comment: "Launch recovery message")
    }
    static var startFresh: String {
      string("crash-report.recovery.start-fresh", defaultValue: "Start Fresh", comment: "Launch recovery message")
    }
    static var freshTitle: String {
      string("crash-report.recovery.fresh-title", defaultValue: "Start Fresh Without Old Data?", comment: "Launch recovery message")
    }
    static func freshMessage(_ value0: String, _ value1: String) -> String {
      format("crash-report.recovery.fresh-message", defaultValue: "Snapzy will launch with default settings and an empty capture history.\n\nYour old data remains in the sandbox container and is not deleted. You can access it manually at:\n~/Library/Containers/%@\n\nCurrent error:\n%@", comment: "Launch recovery message", value0, value1)
    }
    static var repairFailed: String {
      string("crash-report.recovery.repair-failed", defaultValue: "Repair did not succeed. You can reset the database after backing up the current files, or quit Snapzy.", comment: "Launch recovery message")
    }
    static var resetInitializationFailed: String {
      string("crash-report.recovery.reset-initialization-failed", defaultValue: "Reset moved the old database files aside, but Snapzy still could not create a fresh database.", comment: "Launch recovery message")
    }
    static var resetFailed: String {
      string("crash-report.recovery.reset-failed", defaultValue: "Reset failed before Snapzy could create a fresh database.", comment: "Launch recovery message")
    }
    static var databaseTitle: String {
      string("crash-report.recovery.database-title", defaultValue: "Snapzy could not open its database.", comment: "Launch recovery message")
    }
    static func databaseMessage(_ value0: String, _ value1: String) -> String {
      format("crash-report.recovery.database-message", defaultValue: "Snapzy needs this database for capture history and cloud upload records.\n\nDatabase:\n%@\n\nError:\n%@", comment: "Launch recovery message", value0, value1)
    }
    static var databaseHint: String {
      string("crash-report.recovery.database-hint", defaultValue: "Try a repair first. Reset starts with an empty database after moving the current database files into a recovery folder.", comment: "Launch recovery message")
    }
    static var tryRepair: String {
      string("crash-report.recovery.try-repair", defaultValue: "Try Repair", comment: "Launch recovery message")
    }
    static var resetDatabaseEllipsis: String {
      string("crash-report.recovery.reset-database-ellipsis", defaultValue: "Reset Database...", comment: "Launch recovery message")
    }
    static var resetDatabase: String {
      string("crash-report.recovery.reset-database", defaultValue: "Reset Database", comment: "Launch recovery message")
    }
    static var resetTitle: String {
      string("crash-report.recovery.reset-title", defaultValue: "Reset Snapzy Database?", comment: "Launch recovery message")
    }
    static func resetMessage(_ value0: String, _ value1: String) -> String {
      format("crash-report.recovery.reset-message", defaultValue: "Snapzy will move the current database files into a recovery folder, then create a new empty database.\n\nThis resets capture history and cloud upload history inside Snapzy. Capture files on disk and cloud files are not deleted.\n\nDatabase:\n%@\n\nCurrent error:\n%@", comment: "Launch recovery message", value0, value1)
    }
    static func directoryFailed(_ value0: String, _ value1: String) -> String {
      format("crash-report.recovery.directory-failed", defaultValue: "Could not create database directory at %@: %@", comment: "Launch recovery message", value0, value1)
    }
    static func databaseOpenFailed(_ value0: String, _ value1: String) -> String {
      format("crash-report.recovery.database-open-failed", defaultValue: "Could not open or migrate database at %@: %@", comment: "Launch recovery message", value0, value1)
    }
    static var recoverySuggestion: String {
      string("crash-report.recovery.recovery-suggestion", defaultValue: "Try repairing the database, reset it after backing up the existing files, or quit Snapzy.", comment: "Launch recovery message")
    }
    static var migrationPathsUnavailable: String {
      string("crash-report.recovery.migration-paths-unavailable", defaultValue: "Could not resolve user Library paths for sandbox data migration.", comment: "Launch recovery message")
    }
    static var migrationIdentityUnavailable: String {
      string("crash-report.recovery.migration-identity-unavailable", defaultValue: "Could not resolve Snapzy bundle identifier for sandbox data migration.", comment: "Launch recovery message")
    }
    static var keyEncodingFailed: String {
      string("crash-report.recovery.key-encoding-failed", defaultValue: "Failed to encode the API key for Keychain storage", comment: "Launch recovery message")
    }
    static func keySaveFailed(_ value0: String) -> String {
      format("crash-report.recovery.key-save-failed", defaultValue: "Failed to save the API key to the Keychain (error %@)", comment: "Launch recovery message", value0)
    }
  }
}
