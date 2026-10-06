import Foundation
import SwiftUI

/// One circle as the iPhone describes it: a name and one status line.
/// Never a member's name, never a location.
struct CircleRow: Identifiable, Hashable {
  let id: String
  let name: String
  let kind: Kind
  let headline: String
  let sub: String

  enum Kind: String {
    case sosMine = "sos_mine"
    case sosOther = "sos_other"
    case checkInRequested = "check_in_requested"
    case waiting
    case ok
  }

  init?(_ dict: [String: Any]) {
    guard let id = dict["circleId"] as? String,
          let name = dict["name"] as? String
    else { return nil }
    self.id = id
    self.name = name
    self.kind = Kind(rawValue: dict["kind"] as? String ?? "") ?? .ok
    self.headline = dict["headline"] as? String ?? ""
    self.sub = dict["sub"] as? String ?? ""
  }

  /// Colour always comes with a word: the status text is never colour alone.
  var tint: Color {
    switch kind {
    case .sosMine, .sosOther: return AlrtColors.sosRed
    case .checkInRequested: return AlrtColors.actionOrange
    case .waiting: return AlrtColors.monitorYellow
    case .ok: return AlrtColors.indigo
    }
  }

  var isSos: Bool { kind == .sosMine || kind == .sosOther }
}

/// The whole status the iPhone last sent.
struct WatchStatus {
  let signedIn: Bool
  let state: String
  let headline: String
  let sub: String
  let generatedAt: Date?
  let rows: [CircleRow]
  let moreCircles: Int

  init(_ dict: [String: Any]) {
    signedIn = dict["signedIn"] as? Bool ?? false
    state = dict["state"] as? String ?? ""
    headline = dict["headline"] as? String ?? ""
    sub = dict["sub"] as? String ?? ""
    moreCircles = dict["moreCircles"] as? Int ?? 0
    rows = (dict["rows"] as? [[String: Any]] ?? []).compactMap(CircleRow.init)
    if let raw = dict["generatedAt"] as? String {
      let f = ISO8601DateFormatter()
      f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      generatedAt = f.date(from: raw) ?? ISO8601DateFormatter().date(from: raw)
    } else {
      generatedAt = nil
    }
  }
}

/// The result of one action, exactly as the iPhone reported it.
enum ActionOutcome: Equatable {
  /// The server confirmed it.
  case done(title: String, detail: String)
  /// It was refused or could not be sent; nothing happened.
  case notSent(title: String, detail: String)
  /// It may have been sent, but no answer came back. Trying again uses the
  /// same key, so the server can never make it two.
  case uncertain
}

/// ALRT's locked colours (frontend/CLAUDE.md): solid red only for a live
/// SOS, the family indigo, the check-in green and the band colours.
enum AlrtColors {
  static let sosRed = Color(red: 0xDA / 255, green: 0x1F / 255, blue: 0x2D / 255)
  static let actionOrange = Color(red: 0xF0 / 255, green: 0x7E / 255, blue: 0x1B / 255)
  static let monitorYellow = Color(red: 0xF5 / 255, green: 0xC5 / 255, blue: 0x18 / 255)
  static let indigo = Color(red: 0x3D / 255, green: 0x3D / 255, blue: 0xDF / 255)
  static let checkInGreen = Color(red: 0x10 / 255, green: 0x84 / 255, blue: 0x3F / 255)
}
