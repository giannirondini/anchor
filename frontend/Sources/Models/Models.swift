/**
 * Data Models
 *
 * Core data structures matching the backend API
 */

import Foundation

// MARK: - Conversation

struct Conversation: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    let createdAt: Date
    var updatedAt: Date
    var model: String?
    var agent: String?
    var sessionId: String?
    var tags: [Tag]
    
    enum CodingKeys: String, CodingKey {
        case id, title, model, agent, tags
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case sessionId = "sessionId"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        model = try container.decodeIfPresent(String.self, forKey: .model)
        agent = try container.decodeIfPresent(String.self, forKey: .agent)
        sessionId = try container.decodeIfPresent(String.self, forKey: .sessionId)
        tags = try container.decodeIfPresent([Tag].self, forKey: .tags) ?? []
        
        // Handle date parsing
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = Date()
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
        } else {
            updatedAt = Date()
        }
    }
    
    init(id: String, title: String, createdAt: Date = Date(), updatedAt: Date = Date(), 
         model: String? = nil, agent: String? = nil, sessionId: String? = nil, tags: [Tag] = []) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.model = model
        self.agent = agent
        self.sessionId = sessionId
        self.tags = tags
    }
}

// MARK: - Message

struct Message: Identifiable, Codable, Equatable {
    let id: String
    let conversationId: String
    let role: MessageRole
    var content: String
    let createdAt: Date
    var status: MessageStatus
    var errorMessage: String?
    var attachments: [Attachment]?
    
    enum CodingKeys: String, CodingKey {
        case id, role, content, status, attachments
        case conversationId = "conversationId"
        case createdAt = "createdAt"
        case errorMessage = "errorMessage"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        conversationId = try container.decode(String.self, forKey: .conversationId)
        role = try container.decode(MessageRole.self, forKey: .role)
        content = try container.decode(String.self, forKey: .content)
        status = try container.decode(MessageStatus.self, forKey: .status)
        errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        attachments = try container.decodeIfPresent([Attachment].self, forKey: .attachments)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = Date()
        }
    }
    
    init(id: String, conversationId: String, role: MessageRole, content: String,
         createdAt: Date = Date(), status: MessageStatus = .sent, errorMessage: String? = nil,
         attachments: [Attachment]? = nil) {
        self.id = id
        self.conversationId = conversationId
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.status = status
        self.errorMessage = errorMessage
        self.attachments = attachments
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

enum MessageStatus: String, Codable {
    case sending
    case sent
    case error
}

// MARK: - Tag

struct Tag: Identifiable, Codable, Equatable {
    let id: Int
    var name: String
    var color: String?
}

// MARK: - Model Info

struct ModelInfo: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let multiplier: Double
    let supportsVision: Bool
    let maxContextTokens: Int
    let enabled: Bool
    
    // Provide default values for optional fields during decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        multiplier = try container.decodeIfPresent(Double.self, forKey: .multiplier) ?? 1.0
        supportsVision = try container.decodeIfPresent(Bool.self, forKey: .supportsVision) ?? false
        maxContextTokens = try container.decodeIfPresent(Int.self, forKey: .maxContextTokens) ?? 0
        enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? true
    }
    
    init(id: String, name: String, multiplier: Double = 1.0, supportsVision: Bool = false, maxContextTokens: Int = 0, enabled: Bool = true) {
        self.id = id
        self.name = name
        self.multiplier = multiplier
        self.supportsVision = supportsVision
        self.maxContextTokens = maxContextTokens
        self.enabled = enabled
    }
    
    /// Returns the display name shown in the model picker
    var displayName: String {
        name
    }
}

// MARK: - API Response Types

struct ConversationsResponse: Codable {
    let conversations: [Conversation]
}

struct MessagesResponse: Codable {
    let messages: [Message]
}

struct ModelsResponse: Codable {
    let models: [ModelInfo]
}

struct SendMessageResponse: Codable {
    let messageId: String
    let status: String
}

struct Attachment: Identifiable, Codable, Equatable {
    let id: String
    let conversationId: String
    let originalName: String
    var displayName: String
    let size: Int
    let mimeType: String
    let createdAt: String
}

struct AttachmentUploadResponse: Codable {
    let attachments: [Attachment]
}

struct MessageAttachmentReference: Codable, Equatable {
    let id: String
    let displayName: String?
}

enum PendingAttachmentStatus: Equatable {
    case uploading
    case uploaded(Attachment)
    case failed(String)
}

struct PendingAttachment: Identifiable, Equatable {
    let id: UUID
    let fileURL: URL
    var displayName: String
    let size: Int
    let mimeType: String
    var status: PendingAttachmentStatus
}

struct HealthResponse: Codable {
    let status: String
    let version: String
    let sdk: SDKStatus
}

struct SDKStatus: Codable {
    let connected: Bool
    let authenticated: Bool
}

// MARK: - WebSocket Event Types

struct WebSocketMessage: Codable {
    let event: String
    let data: WebSocketData
}

struct WebSocketData: Codable {
    let messageId: String?
    let content: String?
    let fullContent: String?
    let error: String?
    let toolName: String?
    let success: Bool?
}
