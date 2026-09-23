import Foundation

/// One short-lived handoff, not an analysis history. No network or logging.
enum SharedMessageStore {
  static let groupID = "group.com.example.tuzak"
  static let maxLength = 10_000
  static let lifetime: TimeInterval = 600

  private struct Payload: Codable {
    let text: String
    let createdAt: Date
  }

  private static func fileURL() throws -> URL {
    guard let container = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: groupID
    ) else { throw StoreError.unavailable }
    return container.appendingPathComponent("pending-message.json")
  }

  static func save(_ text: String) throws {
    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
          text.utf16.count <= maxLength else { throw StoreError.invalidText }
    var url = try fileURL()
    let bytes = try JSONEncoder().encode(Payload(text: text, createdAt: Date()))
    try bytes.write(to: url, options: [.atomic, .completeFileProtection])
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try url.setResourceValues(values)
  }

  static func take() throws -> String? {
    let url = try fileURL()
    guard FileManager.default.fileExists(atPath: url.path) else { return nil }
    // Remove even expired or malformed handoffs; never retain an invalid message.
    defer { try? FileManager.default.removeItem(at: url) }
    let data = try Data(contentsOf: url)
    guard data.count <= 100_000 else { throw StoreError.invalidText }
    let payload = try JSONDecoder().decode(Payload.self, from: data)
    let age = Date().timeIntervalSince(payload.createdAt)
    guard age >= 0, age <= lifetime,
          payload.text.utf16.count <= maxLength else { return nil }
    return payload.text
  }

  enum StoreError: Error { case unavailable, invalidText }
}
