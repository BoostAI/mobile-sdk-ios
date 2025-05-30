//
//  Commands.swift
//  BoostAI
//
//  Copyright © 2021 boost.ai
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
//  Please contact us at contact@boost.ai if you have any questions.
//

import Foundation

/**
    Types a CommandPost can be
 
    - text: message()
    - trigger_action: triggerAction()
    - action_link: actionButton()
    - external_link: urlButton()
    - feedback: feedback()
    - files: sendFiles()
 */
public enum Type: String, Encodable {
    case text, trigger_action, action_link, external_link, feedback, files
}

public struct File: Encodable {
    public let filename: String
    public let mimetype: String
    public let url: String
    public var isUploading: Bool = false
    public var hasUploadError: Bool = false
    
    public init(filename: String, mimetype: String, url: String, isUploading: Bool = false, hasUploadError: Bool = false) {
        self.filename = filename
        self.mimetype = mimetype
        self.url = url
        self.isUploading = isUploading
        self.hasUploadError = hasUploadError
    }
}

/**
    The types of feeback possible on an element.
 
    Types can be: positive, removePositive, negative, removeNegative
 */
public enum FeedbackValue: String, Encodable {
    case positive
    case removePositive = "remove-positive"
    case negative
    case removeNegative = "remove-negative"
}

public struct ConversationFeedback {
    public let rating: Int
    public let text: String?
}

/// Commands the API understand
public enum Command: String, Codable {
    case
    START = "START",
    POST = "POST",
    DOWNLOAD = "DOWNLOAD",
    RESUME = "RESUME",
    DELETE = "DELETE",
    FEEDBACK = "FEEDBACK",
    TYPING = "TYPING",
    POLL = "POLL",
    POLLSTOP = "POLLSTOP",
    STOP = "STOP",
    LOGINEVENT = "LOGINEVENT",
    SMARTREPLY = "SMARTREPLY",
    HUMANCHATPOST = "HUMANCHATPOST",
    CONFIG = "CONFIG"
}

/// Protocol for all commands
public protocol CommandProtocol: Encodable {
    var command: Command {get set}
    var filterValues: [String]? { get set }
}

/// Protocol for all conversations
public protocol ConversationProtocol: CommandProtocol {
    var conversationId: String? { get set }
    var userToken: String? { get set }
}

/**
    Starting a conversation
 
    You initiate a conversation by calling CommandStart.
    The simples form of the command is without parameters
 */
public struct CommandStart: CommandProtocol {
    public var command = Command.START
    /// BCP47 code string. Examples 'en-US', 'fr-FR' and 'sv-SE'. This will cause the VA to respond in the specified language
    public var language: String?
    /// List of strings, e.g. ['login', 'production']. Filter values are used to filter actions in the action flow
    public var filterValues: [String]?
    /// Initial context topic for the chat.
    public var contextTopicIntentId: Int?
    /// Specific aciton id you want to trigger instead of the welcome message configured in Settings -> System action Triggers. If you have enabled consent
    /// this parameter will return an error message
    public var triggerAction: Int?
    /// Specific action id you want to trigger for authenticated users instead of the welcome message configured in Settings -> System action Triggers.
    /// If you have enabled consent this parameter will return an error message.
    public var authTriggerAction: Int?
    /// Identifies an authenticated user
    public var userToken: String?
    /// Sets the Human Chat skill for the conversation
    public var skill: String?
    /// Return clean text
    public var clean: Bool?
    /// Forwarded to the API Connector and External API's. This parameter can tell an API which timezone the client is currently in.
    /// The format is listed [here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
    /// Use the column TZ database name from the list.
    public var clientTimezone: String?
    /// Forwarded to the API Connector and External API's. You can set this parameter to any JSON value
    public var customPayload: AnyCodable?
    /// A list of preferred client languages in ISO format (i.e. ["en-US", "nb-NO"])
    public var preferredClientLanguages: [String]?
    /// Sets if the backend should skip the welcome message
    public var skipWelcomeMessage: Bool?
    
    public init(
        userToken: String? = nil,
        language: String? = nil,
        filterValues: [String]? = nil,
        contextTopicIntentId: Int? = nil,
        triggerAction: Int? = nil,
        authTriggerAction: Int? = nil,
        skill: String? = nil,
        clean: Bool? = nil,
        clientTimezone: String? = nil,
        customPayload: AnyCodable? = nil,
        preferredClientLanguages: [String]? = nil,
        skipWelcomeMessage: Bool? = nil
    ) {
        self.userToken = userToken
        self.language = language
        self.filterValues = filterValues
        self.contextTopicIntentId = contextTopicIntentId
        self.triggerAction = triggerAction
        self.authTriggerAction = authTriggerAction
        self.skill = skill
        self.clean = clean
        self.clientTimezone = clientTimezone
        self.customPayload = customPayload
        self.preferredClientLanguages = preferredClientLanguages
        self.skipWelcomeMessage = skipWelcomeMessage
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case command
        case language
        case filterValues = "filter_values"
        case contextTopicIntentId = "context_intent_id"
        case triggerAction = "trigger_action"
        case authTriggerAction = "auth_trigger_action"
        case userToken = "user_token"
        case skill
        case clean
        case clientTimezone = "client_timezone"
        case customPayload = "custom_payload"
        case preferredClientLanguages = "preferred_client_languages"
        case skipWelcomeMessage = "skip_welcome_message"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(command, forKey: .command)
        try container.encodeIfPresent(language, forKey: .language)
        try container.encodeIfPresent(filterValues, forKey: .filterValues)
        try container.encodeIfPresent(contextTopicIntentId, forKey: .contextTopicIntentId)
        try container.encodeIfPresent(triggerAction, forKey: .triggerAction)
        try container.encodeIfPresent(authTriggerAction, forKey: .authTriggerAction)
        try container.encodeIfPresent(userToken, forKey: .userToken)
        try container.encodeIfPresent(clean, forKey: .clean)
        try container.encodeIfPresent(clientTimezone, forKey: .clientTimezone)
        try container.encodeIfPresent(customPayload, forKey: .customPayload)
        try container.encodeIfPresent(preferredClientLanguages, forKey: .preferredClientLanguages)
        try container.encodeIfPresent(skipWelcomeMessage, forKey: .skipWelcomeMessage)
    }
}

/**
    Stopping a conversation
 
    The STOP command will block the conversation. This is useful in authenticated conversation flows when you want
    to force a new conversation to be created with the START command
 
    {"command": "STOP", "conversation_id": String}
 */
public struct CommandStop: ConversationProtocol {
    public var command = Command.STOP
    public var conversationId: String?
    public var userToken: String?
    public var filterValues: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case command
        case conversationId = "conversation_id"
        case userToken = "user_token"
        case filterValues = "filter_values"
    }
}

/**
    Use the CommandResume to list previous responses in a given conversation. When you resume a conversation,
     you supply a conversation id
 
        {"command": "RESUME", "clean": Boolean, "conversation_id": String}
 */
public struct CommandResume: ConversationProtocol {
    public var command = Command.RESUME
    public var filterValues: [String]?
    public var conversationId: String?
    public var userToken: String?
    public var clean = false
    public var skill: String?
    public var skipWelcomeMesssage = false
    
    private enum CodingKeys: String, CodingKey {
        case command
        case filterValues = "filter_values"
        case conversationId = "conversation_id"
        case userToken = "user_token"
        case clean
        case skill
        case skipWelcomeMessage = "skip_welcome_message"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(command, forKey: .command)
        try container.encodeIfPresent(filterValues, forKey: .filterValues)
        try container.encodeIfPresent(conversationId, forKey: .conversationId)
        try container.encodeIfPresent(userToken, forKey: .userToken)
        try container.encodeIfPresent(clean, forKey: .clean)
        try container.encodeIfPresent(skill, forKey: .skill)
        try container.encodeIfPresent(skipWelcomeMesssage, forKey: .skipWelcomeMessage)
    }
}

/**
    To delete a conversation, post a CommandDelete.
 
  When you delete a conversation, the API will delete or overwrite:
  - Message texts sent to and from the API
  - Middle layer data created with API Connector
 */
public struct CommandDelete: ConversationProtocol {
    public var command = Command.DELETE
    public var filterValues: [String]?
    public var conversationId: String?
    public var userToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case command
        case filterValues = "filter_values"
        case conversationId = "conversation_id"
        case userToken = "user_token"
    }
}

/**
    Poll for data
 
    When the API returns poll=false or chat_status="virtual_agent", the conversation is in Virtual Agent mode.
    When the API returns poll=true or chat_status="assigned_to_human" or chat_status="in_human_chat_queue"
    the conversation is in Human Chat mode.
 
    You can poll the server for more conversation data using the last known response id where response.source="bot".
    Responses will contain any response with an Id larger then the supplied id. The maximum number of responses that
    can be returned is 100
 
    {"command": "POLL", "conversation_id": String, "clean": Boolean, "value: String}
 */
public struct CommandPoll: ConversationProtocol {
    public var command = Command.POLL
    /// List of strings, e.g. ['login', 'production']. Filter values are used to filter actions in the action flow
    public var filterValues: [String]?
    /// Conversation Id
    public var conversationId: String?
    /// User token
    public var userToken: String?
    /// html (false = default) or text (true) response
    public var clean = false
    /// Last known response Id
    public var value: String
    
    private enum CodingKeys: String, CodingKey {
        case command
        case filterValues = "filter_values"
        case conversationId = "conversation_id"
        case userToken = "user_token"
        case clean
        case value
    }
    
}

/**
    Stop Human Chat
 
    POLLSTOP will stop the Human Chat state and return the conversation to AI mode.
 
    {"command": "POLLSTOP", "conversation_id": String}
 */
public struct CommandPollStop: ConversationProtocol {
    public var command = Command.POLLSTOP
    /// List of strings, e.g. ['login', 'production']. Filter values are used to filter actions in the action flow
    public var filterValues: [String]?
    /// Conversation Id
    public var conversationId: String?
    /// User token
    public var userToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case command
        case filterValues = "filter_values"
        case conversationId = "conversation_id"
        case userToken = "user_token"
    }
}

/**
    Get a smart reply
 
    Get a smart reply from the virtual agent when the conversation is in human chat mode
 
    {"command": "SMARTREPLY", "conversation_id": String, "value": String}
 */
public struct CommandSmartReply: ConversationProtocol {
    public var command = Command.SMARTREPLY
    /// List of strings, e.g. ['login', 'production']. Filter values are used to filter actions in the action flow
    public var filterValues: [String]?
    /// Conversation Id
    public var conversationId: String?
    /// User token
    public var userToken: String?
    /// Message text
    public var value: String
    
    private enum CodingKeys: String, CodingKey {
        case command
        case filterValues = "filter_values"
        case conversationId = "conversation_id"
        case userToken = "user_token"
        case value
    }
}

/**
    Post a human chat message
 
    Send a message to the conversation from an external Human Chat system
 
    {"command": "HUMANCHATPOST", "conversation_id", "value": String}
 */
public struct CommandHumanChatPost: ConversationProtocol {
    public var command = Command.HUMANCHATPOST
    /// List of strings, e.g. ['login', 'production']. Filter values are used to filter actions in the action flow
    public var filterValues: [String]?
    /// Conversation Id
    public var conversationId: String?
    /// User token
    public var userToken: String?
    /// Message text
    public var value: String
    
    private enum CodingKeys: String, CodingKey {
        case command
        case filterValues = "filter_values"
        case conversationId = "conversation_id"
        case userToken = "user_token"
        case value
    }
}

/**
    User activity
 
    When the user is typing, you might want to send a typing message to the server. If the conversation
    router is in Human Chat mode, this will update the chat status in the Human Chat.

    {"command": "TYPING", "conversation_id": String}
 */
public struct CommandTyping: ConversationProtocol {
    public var command = Command.TYPING
    /// List of strings, e.g. ['login', 'production']. Filter values are used to filter actions in the action flow
    public var filterValues: [String]?
    /// Conversation Id
    public var conversationId: String?
    /// User token
    public var userToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case command
        case filterValues = "filter_values"
        case conversationId = "conversation_id"
        case userToken = "user_token"
    }
}

/**
    Feedback value
 
    The rating parameter should be the integer 1 or 0. If the rating is missing, its value will be 0.
    If you want your users to provide feedback in the form of text in addition to rating, use the text attribute
 */
public struct CommandFeedbackValue: Encodable {
    /// 1 or 0
    public var rating: Int
    /// Feedback text
    public var text: String?
    
    private enum CodingKeys: String, CodingKey {
        case rating
        case text
    }
}

/**
   Conversation feedback

   When a conversation ends, you might want to give the user the opportunity to give feedback on the conversation

   {"command": "FEEDBACK", "conversation_id": String, "value": { "rating": Integer, "text": String}}
*/
public struct CommandFeedback: ConversationProtocol {
    public var command = Command.FEEDBACK
    /// List of strings, e.g. ['login', 'production']. Filter values are used to filter actions in the action flow
    public var filterValues: [String]?
    /// Conversation id
    public var conversationId: String?
    /// User token
    public var userToken: String?
    /// Feedback value
    public var value: CommandFeedbackValue
    
    private enum CodingKeys: String, CodingKey {
        case command
        case filterValues = "filter_values"
        case conversationId = "conversation_id"
        case userToken = "user_token"
        case value
    }
}

/**
    Download conversation history
 
    Use this command to download a text version of a conversation. Either conversationId or userToken should be present in the payload
 
    {"command": "DOWNLOAD", "conversation_id": String?, "user_token": String?}
 */
public struct CommandDownload: CommandProtocol {
    public var command = Command.DOWNLOAD
    public var filterValues: [String]?
    public var conversationId: String?
    public var userToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case command
        case filterValues = "filter_values"
        case conversationId = "conversation_id"
        case userToken = "user_token"
    }
}

public struct CommandLoginEvent: CommandProtocol {
    public var command = Command.LOGINEVENT
    public var filterValues: [String]?
    public var conversationId: String?
    public var userToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case command
        case filterValues = "filter_values"
        case conversationId = "conversation_id"
        case userToken = "user_token"
    }
}

public struct CommandConfig: CommandProtocol {
    public var command = Command.CONFIG
    public var filterValues: [String]?
    public var vanId: Int?
    
    private enum CodingKeys: String, CodingKey {
        case command
        case filterValues = "filter_values"
        case vanId = "van_id"
    }
}

/**
    Posting data
 
    When you have obtained a conversationID with CommandStart, you can post data to the server
 */
public struct CommandPost: ConversationProtocol {
    public var command = Command.POST
    /// Identifies the conversation. The conversation id is generated by the API. The SDK will pick up the conversationID for you,
    /// but if you store the conversationId for later usage (e.g. restart of app) you need to set this manually and not use CommandStart
    public var conversationId: String?
    /// Secure token
    //public var secureToken: String?
    /// Type of the request
    public var type: Type
    /// If true, the API will return clean text instead of HTML in all responses
    public var clean: Bool?
    /// An array of tiler value strings. These values can be used in filtering data in the action flow
    public var filterValues: [String]?
    /// Identifies an authenticated user
    public var userToken: String?
    /// Itent Id to set conversation in a specific context
    public var contextIntentId: Int?
    /// Sets the Human Chat skill for the conversation
    public var skill: String?
    /// The id of a button or a bot question
    public var id: String?
    /// The value of the request
    public var value: Any?
    /// The message of the request (used for text message along file upload)
    public var message: String?
    /// An object which is forwarded to External API's
    public var customPayload: AnyCodable?
    /// Forwarded to the API Connector and External API's. This parameter can tell an API which timezone the client is currently in.
    /// The format is listed [here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
    /// Use the column TZ database name from the list.
    public var clientTimezone: String?
    
    // MARK: Any? helpers
    private var valueEncoder: ((Any, inout KeyedEncodingContainer<CodingKeys>) throws -> Void)? = nil
    
    mutating public func setValue<A: Encodable>(_ value: A) {
        self.value = value
        valueEncoder = { value, container in
            try container.encode(value as! A, forKey: .value)
        }
    }
    
    public init(conversationId: String?,
                userToken: String?,
                type: Type,
                clean: Bool? = nil,
                filterValues: [String]? = nil,
                contextIntentId: Int? = nil,
                skill: String? = nil,
                id: String? = nil,
                clientTimezone: String? = nil,
                customPayload: AnyCodable? = nil
                ) {
        self.conversationId = userToken == nil ? conversationId : nil
        self.userToken = userToken
        self.type = type
        self.clean = clean
        self.filterValues = filterValues
        self.contextIntentId = contextIntentId
        self.skill = skill
        self.id = id
        self.clientTimezone = clientTimezone
        self.customPayload = customPayload
    }
    
    private enum CodingKeys: String, CodingKey {
        case command
        case conversationId = "conversation_id"
        case type = "type"
        case clean
        case filterValues = "filter_values"
        case userToken = "user_token"
        case contextIntentId = "context_intent_id"
        case skill
        case id
        case value
        case message
        case clientTimezone = "client_timezone"
        case customPayload = "custom_payload"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(command, forKey: .command)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(conversationId, forKey: .conversationId)
        try container.encodeIfPresent(clean, forKey: .clean)
        try container.encodeIfPresent(filterValues, forKey: .filterValues)
        try container.encodeIfPresent(userToken, forKey: .userToken)
        try container.encodeIfPresent(contextIntentId, forKey: .contextIntentId)
        try container.encodeIfPresent(skill, forKey: .skill)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(clientTimezone, forKey: .clientTimezone)
        try container.encodeIfPresent(customPayload, forKey: .customPayload)
        
        if let value = self.value {
            guard let encode = self.valueEncoder else {
                let context = EncodingError.Context(codingPath: [], debugDescription: "Invalid value encoder: \(String(describing: self.valueEncoder)).")
                throw EncodingError.invalidValue(self, context)
            }
            
            try encode(value, &container)
        }

    }
}
