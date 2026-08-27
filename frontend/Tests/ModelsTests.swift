/**
 * Model Tests
 *
 * Unit tests for data model decoding and initialization
 */

import Foundation
import Testing
@testable import Anchor

// Disambiguate Anchor types from Testing types
private typealias Tag = Anchor.Tag
private typealias Attachment = Anchor.Attachment

struct ModelsTests {

    // MARK: - Conversation Tests

    @Test func testConversationDecoding() throws {
        let json = """
        {
            "id": "conv_123",
            "title": "Test Conversation",
            "createdAt": "2026-01-29T10:30:00.000Z",
            "updatedAt": "2026-01-29T11:00:00.000Z",
            "model": "claude-sonnet-4-20250514",
            "agent": null,
            "sessionId": "session_456",
            "tags": []
        }
        """.data(using: .utf8)!
        
        let conversation = try JSONDecoder().decode(Conversation.self, from: json)
        
        #expect(conversation.id == "conv_123")
        #expect(conversation.title == "Test Conversation")
        #expect(conversation.model == "claude-sonnet-4-20250514")
        #expect(conversation.agent == nil)
        #expect(conversation.sessionId == "session_456")
        #expect(conversation.tags.isEmpty)
    }
    
    @Test func testConversationDecodingWithMissingOptionalFields() throws {
        let json = """
        {
            "id": "conv_123",
            "title": "Test",
            "createdAt": "2026-01-29T10:30:00.000Z",
            "updatedAt": "2026-01-29T10:30:00.000Z"
        }
        """.data(using: .utf8)!
        
        let conversation = try JSONDecoder().decode(Conversation.self, from: json)
        
        #expect(conversation.id == "conv_123")
        #expect(conversation.model == nil)
        #expect(conversation.agent == nil)
        #expect(conversation.sessionId == nil)
        #expect(conversation.tags.isEmpty)
    }
    
    @Test func testConversationInitializer() {
        let conversation = Conversation(
            id: "conv_test",
            title: "My Chat",
            model: "gpt-5",
            agent: nil
        )
        
        #expect(conversation.id == "conv_test")
        #expect(conversation.title == "My Chat")
        #expect(conversation.model == "gpt-5")
    }
    
    @Test func testConversationEquality() {
        let now = Date()
        let conv1 = Conversation(id: "conv_1", title: "Chat 1", createdAt: now, updatedAt: now)
        let conv2 = Conversation(id: "conv_1", title: "Chat 1", createdAt: now, updatedAt: now)
        let conv3 = Conversation(id: "conv_2", title: "Chat 2", createdAt: now, updatedAt: now)

        #expect(conv1 == conv2)
        #expect(conv1 != conv3)
    }
    
    // MARK: - Message Tests
    
    @Test func testMessageDecoding() throws {
        let json = """
        {
            "id": "msg_123",
            "conversationId": "conv_456",
            "role": "assistant",
            "content": "Hello! How can I help you?",
            "createdAt": "2026-01-29T10:30:00.000Z",
            "status": "sent",
            "errorMessage": null
        }
        """.data(using: .utf8)!
        
        let message = try JSONDecoder().decode(Message.self, from: json)
        
        #expect(message.id == "msg_123")
        #expect(message.conversationId == "conv_456")
        #expect(message.role == .assistant)
        #expect(message.content == "Hello! How can I help you?")
        #expect(message.status == .sent)
        #expect(message.errorMessage == nil)
    }
    
    @Test func testMessageWithError() throws {
        let json = """
        {
            "id": "msg_123",
            "conversationId": "conv_456",
            "role": "assistant",
            "content": "",
            "createdAt": "2026-01-29T10:30:00.000Z",
            "status": "error",
            "errorMessage": "Rate limit exceeded"
        }
        """.data(using: .utf8)!
        
        let message = try JSONDecoder().decode(Message.self, from: json)
        
        #expect(message.status == .error)
        #expect(message.errorMessage == "Rate limit exceeded")
    }

    @Test func testMessageWithAttachmentsDecoding() throws {
        let json = """
        {
            "id": "msg_789",
            "conversationId": "conv_456",
            "role": "user",
            "content": "See attached",
            "createdAt": "2026-01-29T10:35:00.000Z",
            "status": "sent",
            "attachments": [
                {
                    "id": "att_123",
                    "conversationId": "conv_456",
                    "originalName": "spec.pdf",
                    "displayName": "spec.pdf",
                    "size": 1024,
                    "mimeType": "application/pdf",
                    "createdAt": "2026-01-29T10:34:00.000Z"
                }
            ]
        }
        """.data(using: .utf8)!

        let message = try JSONDecoder().decode(Message.self, from: json)

        #expect(message.attachments?.count == 1)
        #expect(message.attachments?.first?.id == "att_123")
        #expect(message.attachments?.first?.mimeType == "application/pdf")
    }
    
    @Test func testMessageRoles() {
        #expect(MessageRole.user.rawValue == "user")
        #expect(MessageRole.assistant.rawValue == "assistant")
        #expect(MessageRole.system.rawValue == "system")
    }
    
    @Test func testMessageStatuses() {
        #expect(MessageStatus.sending.rawValue == "sending")
        #expect(MessageStatus.sent.rawValue == "sent")
        #expect(MessageStatus.error.rawValue == "error")
    }
    
    // MARK: - ModelInfo Tests
    
    @Test func testModelInfoDecoding() throws {
        let json = """
        {
            "id": "claude-sonnet-4-20250514",
            "name": "Claude Sonnet 4",
            "multiplier": 1.5,
            "supportsVision": true,
            "maxContextTokens": 200000,
            "enabled": true
        }
        """.data(using: .utf8)!
        
        let model = try JSONDecoder().decode(ModelInfo.self, from: json)
        
        #expect(model.id == "claude-sonnet-4-20250514")
        #expect(model.name == "Claude Sonnet 4")
        #expect(model.multiplier == 1.5)
        #expect(model.supportsVision)
        #expect(model.maxContextTokens == 200000)
        #expect(model.enabled)
    }
    
    @Test func testModelInfoWithDefaults() throws {
        let json = """
        {
            "id": "simple-model",
            "name": "Simple Model"
        }
        """.data(using: .utf8)!
        
        let model = try JSONDecoder().decode(ModelInfo.self, from: json)
        
        #expect(model.multiplier == 1.0)
        #expect(!model.supportsVision)
        #expect(model.maxContextTokens == 0)
        #expect(model.enabled)
    }
    
    @Test func testModelInfoDisplayName() {
        // Display name no longer includes the billing multiplier
        let model1 = ModelInfo(id: "claude-sonnet-4", name: "Claude Sonnet 4", multiplier: 1.5)
        #expect(model1.displayName == "Claude Sonnet 4")

        let model2 = ModelInfo(id: "gpt-5", name: "GPT-5", multiplier: 1.0)
        #expect(model2.displayName == "GPT-5")
    }
    
    // MARK: - Tag Tests
    
    @Test func testTagDecoding() throws {
        let json = """
        {
            "id": 1,
            "name": "Important",
            "color": "#FF0000"
        }
        """.data(using: .utf8)!
        
        let tag = try JSONDecoder().decode(Tag.self, from: json)
        
        #expect(tag.id == 1)
        #expect(tag.name == "Important")
        #expect(tag.color == "#FF0000")
    }
    
    @Test func testTagDecodingWithNullColor() throws {
        let json = """
        {
            "id": 2,
            "name": "Work",
            "color": null
        }
        """.data(using: .utf8)!
        
        let tag = try JSONDecoder().decode(Tag.self, from: json)
        
        #expect(tag.id == 2)
        #expect(tag.name == "Work")
        #expect(tag.color == nil)
    }
    
    @Test func testTagEquality() {
        let tag1 = Tag(id: 1, name: "Test", color: "#FF0000")
        let tag2 = Tag(id: 1, name: "Test", color: "#FF0000")
        let tag3 = Tag(id: 2, name: "Other", color: nil)
        
        #expect(tag1 == tag2)
        #expect(tag1 != tag3)
    }
    
    @Test func testConversationDecodingWithTags() throws {
        let json = """
        {
            "id": "conv_123",
            "title": "Tagged Conversation",
            "createdAt": "2026-01-29T10:30:00.000Z",
            "updatedAt": "2026-01-29T11:00:00.000Z",
            "model": "claude-sonnet-4",
            "tags": [
                {"id": 1, "name": "Important", "color": "#FF0000"},
                {"id": 2, "name": "Work", "color": null}
            ]
        }
        """.data(using: .utf8)!
        
        let conversation = try JSONDecoder().decode(Conversation.self, from: json)
        
        #expect(conversation.id == "conv_123")
        #expect(conversation.tags.count == 2)
        #expect(conversation.tags[0].name == "Important")
        #expect(conversation.tags[0].color == "#FF0000")
        #expect(conversation.tags[1].name == "Work")
        #expect(conversation.tags[1].color == nil)
    }
    
    // MARK: - Response Types Tests
    
    @Test func testConversationsResponseDecoding() throws {
        let json = """
        {
            "conversations": [
                {
                    "id": "conv_1",
                    "title": "Chat 1",
                    "createdAt": "2026-01-29T10:30:00.000Z",
                    "updatedAt": "2026-01-29T10:30:00.000Z",
                    "tags": []
                }
            ]
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(ConversationsResponse.self, from: json)
        
        #expect(response.conversations.count == 1)
        #expect(response.conversations[0].id == "conv_1")
    }
    
    @Test func testHealthResponseDecoding() throws {
        let json = """
        {
            "status": "healthy",
            "version": "1.0.0",
            "sdk": {
                "connected": true,
                "authenticated": true
            }
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(HealthResponse.self, from: json)
        
        #expect(response.status == "healthy")
        #expect(response.version == "1.0.0")
        #expect(response.sdk.connected)
        #expect(response.sdk.authenticated)
    }
}
