import Foundation
import CoreGraphics

public enum AIStatus: String, Codable, Sendable {
    case none
    case queued
    case running
    case done
    case failed

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = AIStatus(rawValue: raw) ?? .none
    }
}

public struct OCRLine: Codable, Hashable, Sendable {
    public var rect: CGRect
    public var text: String

    public init(rect: CGRect, text: String) {
        self.rect = rect
        self.text = text
    }
}

/// Codable helper that mirrors the AI-related fields on ClipboardItem.
/// Used in tests to verify backward compatibility; also usable by decoders
/// that don't want to depend on the entire ClipboardItem struct.
public struct AIFieldsSnapshot: Codable, Sendable {
    public var aiTags: [String]
    public var aiSummary: String?
    public var aiModel: String?
    public var aiStatus: AIStatus
    public var ocrText: String?
    public var ocrLines: [OCRLine]?
    public var urlTitle: String?
    public var urlSiteName: String?

    public init(
        aiTags: [String] = [],
        aiSummary: String? = nil,
        aiModel: String? = nil,
        aiStatus: AIStatus = .none,
        ocrText: String? = nil,
        ocrLines: [OCRLine]? = nil,
        urlTitle: String? = nil,
        urlSiteName: String? = nil
    ) {
        self.aiTags = aiTags
        self.aiSummary = aiSummary
        self.aiModel = aiModel
        self.aiStatus = aiStatus
        self.ocrText = ocrText
        self.ocrLines = ocrLines
        self.urlTitle = urlTitle
        self.urlSiteName = urlSiteName
    }

    private enum CodingKeys: String, CodingKey {
        case aiTags, aiSummary, aiModel, aiStatus, ocrText, ocrLines, urlTitle, urlSiteName
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.aiTags = try c.decodeIfPresent([String].self, forKey: .aiTags) ?? []
        self.aiSummary = try c.decodeIfPresent(String.self, forKey: .aiSummary)
        self.aiModel = try c.decodeIfPresent(String.self, forKey: .aiModel)
        self.aiStatus = (try c.decodeIfPresent(AIStatus.self, forKey: .aiStatus)) ?? .none
        self.ocrText = try c.decodeIfPresent(String.self, forKey: .ocrText)
        self.ocrLines = try c.decodeIfPresent([OCRLine].self, forKey: .ocrLines)
        self.urlTitle = try c.decodeIfPresent(String.self, forKey: .urlTitle)
        self.urlSiteName = try c.decodeIfPresent(String.self, forKey: .urlSiteName)
    }
}
