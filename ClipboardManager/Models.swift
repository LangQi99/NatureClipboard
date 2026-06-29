import Foundation
import AppKit

enum ClipboardItemType: String, Codable, CaseIterable {
    case text
    case image
    case file
    case url
    case color
    case html
    case rtf
}

enum ClipboardCategory: String, Codable, CaseIterable {
    case all
    case text
    case images
    case files
    case urls
    case colors
    case pinned
    case favorites

    var displayName: String {
        switch self {
        case .all: return "All"
        case .text: return "Text"
        case .images: return "Images"
        case .files: return "Files"
        case .urls: return "URLs"
        case .colors: return "Colors"
        case .pinned: return "Pinned"
        case .favorites: return "Favorites"
        }
    }

    var icon: String {
        switch self {
        case .all: return "tray.full"
        case .text: return "doc.text"
        case .images: return "photo"
        case .files: return "folder"
        case .urls: return "link"
        case .colors: return "paintpalette"
        case .pinned: return "pin"
        case .favorites: return "star"
        }
    }
}

struct ClipboardItem: Identifiable, Codable, Hashable {
    let id: UUID
    var type: ClipboardItemType
    var textContent: String?
    var htmlContent: String?
    var rtfData: Data?
    var imageData: Data?
    var filePaths: [String]?
    var urlString: String?
    var colorHex: String?
    var appName: String?
    var appBundleId: String?
    var createdAt: Date
    var lastUsedAt: Date
    var useCount: Int
    var isPinned: Bool
    var isFavorite: Bool
    var tags: [String]
    var title: String?
    var characterCount: Int?
    var wordCount: Int?

    init(type: ClipboardItemType, textContent: String? = nil, htmlContent: String? = nil,
         rtfData: Data? = nil, imageData: Data? = nil, filePaths: [String]? = nil,
         urlString: String? = nil, colorHex: String? = nil, appName: String? = nil,
         appBundleId: String? = nil) {
        self.id = UUID()
        self.type = type
        self.textContent = textContent
        self.htmlContent = htmlContent
        self.rtfData = rtfData
        self.imageData = imageData
        self.filePaths = filePaths
        self.urlString = urlString
        self.colorHex = colorHex
        self.appName = appName
        self.appBundleId = appBundleId
        self.createdAt = Date()
        self.lastUsedAt = Date()
        self.useCount = 0
        self.isPinned = false
        self.isFavorite = false
        self.tags = []
        self.characterCount = textContent?.count
        self.wordCount = textContent?.split(separator: " ").count
    }

    var displayTitle: String {
        if let title = title { return title }
        switch type {
        case .text: return textContent?.prefix(100).description ?? "Empty Text"
        case .image: return "Image"
        case .file: return filePaths?.first?.components(separatedBy: "/").last ?? "File"
        case .url: return urlString ?? "URL"
        case .color: return colorHex ?? "Color"
        case .html: return "HTML Content"
        case .rtf: return "Rich Text"
        }
    }

    var preview: String {
        switch type {
        case .text: return textContent ?? ""
        case .url: return urlString ?? ""
        case .file: return filePaths?.joined(separator: "\n") ?? ""
        case .html: return htmlContent?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression) ?? ""
        case .color: return colorHex ?? ""
        case .image: return "[\(imageSize)]"
        case .rtf: return "[Rich Text Format]"
        }
    }

    var imageSize: String {
        guard let data = imageData, let image = NSImage(data: data) else { return "Unknown size" }
        return "\(Int(image.size.width))×\(Int(image.size.height))"
    }

    var category: ClipboardCategory {
        switch type {
        case .text, .html, .rtf: return .text
        case .image: return .images
        case .file: return .files
        case .url: return .urls
        case .color: return .colors
        }
    }
}

struct Snippet: Identifiable, Codable {
    let id: UUID
    var name: String
    var content: String
    var keyword: String
    var category: String
    var createdAt: Date
    var lastUsedAt: Date
    var useCount: Int

    init(name: String, content: String, keyword: String, category: String = "General") {
        self.id = UUID()
        self.name = name
        self.content = content
        self.keyword = keyword
        self.category = category
        self.createdAt = Date()
        self.lastUsedAt = Date()
        self.useCount = 0
    }
}
