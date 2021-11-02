//
//  Response.swift
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

/// Status of current chat
///
/// - virtual_agent: Chat is in virtual agent mode
/// - in_human_chat_queue: Chat is in human chat queue
/// - assigned_to_human: Chat is assigned to human
public enum ChatStatus: String, Codable {
    /// virtual_agent Chat is in virtual agent mode
    case virtual_agent
    /// in_human_chat_queue
    case in_human_chat_queue
    /// assigned_to_human
    case assigned_to_human
}

/// Types an element result can have
///
/// When receiving data this indicates how your client should render their data.
/// - text
/// - html
/// - image
/// - video
/// - json
/// - links
public enum ElementType: String, Codable {
    case
    text,
    html,
    image,
    video,
    json,
    links,
    unknown
        
    public init(from decoder: Decoder) throws {
        self = try ElementType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum LinkType: String, Codable {
    case
    action_link,
    external_link
}

/// Possible values of response.source
public enum SourceType: String, Codable {
    case
    bot,
    client
}

public enum FunctionType: String, Codable {
    case
    approve = "APPROVE",
    deny = "DENY"
    
}

public struct ConversationStateFiles: Codable {
    public let acceptedTypes: [String]?
    public let maxNumberOfFiles: Int?
    
    enum CodingKeys: String, CodingKey {
        case acceptedTypes = "accepted_types"
        case maxNumberOfFiles = "max_number_of_files"
    }
}

/**
    Conversation state object
 */
public struct ConversationState: Decodable {
    /// One of `ChatStatus`
    public let chatStatus: ChatStatus
    /// When true, the conversation is blocked
    public let isBlocked: Bool?
    /// Identifier for the user-user, if authenticated
    public let authenticatedUserId: String?
    /// Conversation id used before the user was authenticated
    public let unauthConversationId: String?
    /// Privacy policy URL
    public let privacyPolicyUrl: String?
    /// If true, the DELETE command is operational
    public let allowDeleteConversation: Bool?
    /// Wheter the conversation is in Human Chat state. The client should POLL the server for more data. The SDK will handle this automatically.
    public let poll: Bool?
    /// true if human is typing in Human Chat
    public let humanIsTyping: Bool?
    /// Maximum characters allowed in a text POST. Overflow will result in an error on message()
    public let maxInputChars: Int?
    /// A string containing the skill set on the predicted intent
    public let skill: String?
    ///Present when an upload file entity extraction has been triggered
    public let awaitingFiles: ConversationStateFiles?
    
    enum CodingKeys: String, CodingKey {
        case isBlocked = "is_blocked"
        case authenticatedUserId = "authenticated_user_id"
        case unauthConversationId = "unauth_conversation_id"
        case privacyPolicyUrl = "privacy_policy_url"
        case allowDeleteConversation = "allow_delete_conversation"
        case poll = "poll"
        case humanIsTyping = "human_is_typing"
        case maxInputChars = "max_input_chars"
        case skill = "skill"
        case awaitingFiles = "awaiting_files"
        case chatStatus = "chat_status"
    }
}

/**
    Conversation object
 */
public struct ConversationResult: Decodable {
    /// Identifies the conversation
    public let id: String?
    public let reference: String?
    /// Conversation state object
    public let state: ConversationState
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case reference = "reference"
        case state = "state"
    }
}

public struct Link: Decodable {
    public let id: String
    public let text: String
    public let type: LinkType
    public let function: FunctionType?
    public let question: String?
    public let url: String?
    public let vanBaseUrl: String?
    public let vanName: String?
    public let vanOrganization: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case text = "text"
        case type = "type"
        case function = "function"
        case question = "question"
        case url = "url"
        case vanBaseUrl = "van_base_url"
        case vanName = "van_name"
        case vanOrganization = "van_organization"
    }
}

public struct Payload: Decodable {
    public let html: String?
    public let text: String?
    public let url: String?  // Video: youtube, vimeo, wistia
    public let source: String?
    public let fullScreen: Bool?
    public let json: Data?
    public let links: [Link]?
    
    // Google stuff, not supported at the time
/*    let GD_START_LAT: String?
    let GD_START_LNG: String?
    let GD_END_LAT: String?
    let GD_END_LNG: String?
    let GD_ENDCODED_PATH: String?
    let START_ADDRESS: String?
    let END_ADDRESS: String?
    
    let GP_TITLE: String?
    let GP_LATITUDE: String?
    let GP_LONGITUDE: String?
    let GP_NW_LAT: String?
    let GP_NW_LNG: String?
    let GP_SW_LAT: String?
    let GP_SW_LNG: String?
    let PLACE: String?
    
    let GL_FORMATTED_ADDRESS: String?
    let GL_LATITUDE: String?
    let GL_LONGITUDE: String?
    let GL_NW_LAT: String?
    let GL_NW_LNG: String?
    let GL_SW_LAT: String?
    let GL_SW_LNG: String?
    */
    enum CodingKeys: String, CodingKey {
        case html = "html"
        case text = "text"
        case url = "url"
        case source = "source"
        case fullScreen = "fullscreen"
        case json = "json"
        case links = "links"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
                
        html = try container.decodeIfPresent(String.self, forKey: .html)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        fullScreen = try container.decodeIfPresent(Bool.self, forKey: .fullScreen)
        links = try container.decodeIfPresent([Link].self, forKey: .links)
        
        if let json = try container.decodeIfPresent([String: AnyCodable].self, forKey: .json) {
            let encoder = JSONEncoder()
            self.json = try encoder.encode(json)
        } else {
            self.json = nil
        }
    }
}

/**
    Generic JSON card
 */
public struct GenericCard: Decodable {
    
    public struct TextContent: Decodable {
        public let text: String
    }
    
    public struct Image: Decodable {
        public let alt: String?
        public let position: String?
        public let url: String?
    }
    
    public struct Link: Decodable {
        public let text: String?
        public let url: String
    }
    
    public let body: TextContent?
    public let heading: TextContent?
    public let image: Image?
    public let link: Link?
    public let template: String?
    
    enum CodingKeys: String, CodingKey {
        case body = "body"
        case heading = "heading"
        case image = "image"
        case link = "link"
        case template = "template"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        body = try container.decodeIfPresent(TextContent.self, forKey: .body)
        heading = try container.decodeIfPresent(TextContent.self, forKey: .heading)
        image = try container.decodeIfPresent(Image.self, forKey: .image)
        link = try container.decodeIfPresent(Link.self, forKey: .link)
        template = try container.decodeIfPresent(String.self, forKey: .template)
    }
}

/**
    A list of response elements
 */
public struct Element: Decodable {
    /// Element data
    public let payload: Payload
    /// The data type of the response
    public let type: ElementType
    
    enum CodingKeys: String, CodingKey {
        case payload = "payload"
        case type = "type"
    }
}

/**
    Response from an interactive conversation
 */
public struct Response: Decodable {
    /// The id of the response
    public let id: String
    /// The source of the response. Either "bot" or "client"
    public let source: SourceType
    /// bcp-47 code
    public let language: String
    /// A list of response elements
    public let elements: [Element]
    /// Avatar URL if the mssage is from Human Chat
    public let avatarUrl: String?
    /// Date of the response
    public let dateCreated: Date?
    /// Message feedback
    public let feedback: String?
    /// Server URL used by the chat client
    public let sourceUrl: String?
    /// The text of a link that was clicked by an end-user
    public let linkText: String?
    public let error: String?
    /// Change of van id
    public let vanId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatarUrl = "avatar_url"
        case dateCreated = "date_created"
        case elements = "elements"
        case language = "language"
        case source = "source"
        case feedback = "feedback"
        case sourceUrl = "source_url"
        case linkText = "link_text"
        case error = "error"
        case vanId = "van_id"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // id can sometimes be an Int, so we need to check for both String and Int types.
        // This means we also have to parse the rest of the object manually :/
        if let idString = try? container.decodeIfPresent(String.self, forKey: .id)  {
            id = idString
        } else if let idInt = try? container.decodeIfPresent(Int.self, forKey: .id) {
            id = String(idInt)
        } else {
            id = ""
        }
        
        // Dates sometime have timezone appended (`+00:00` etct), so try decoding with that if the regular date decoding fails
        var dateCreated: Date? = nil
        if let dateString = try? container.decodeIfPresent(String.self, forKey: .dateCreated) {
            dateCreated = DateFormatter.iso8601Full.date(from: dateString) ?? DateFormatter.iso8601FullWithTimezone.date(from: dateString)
        }
        self.dateCreated = dateCreated
        
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        elements = try container.decodeIfPresent([Element].self, forKey: .elements) ?? [Element]()
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? ""
        source = try container.decodeIfPresent(SourceType.self, forKey: .source) ?? .bot
        feedback = try container.decodeIfPresent(String.self, forKey: .feedback)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        linkText = try container.decodeIfPresent(String.self, forKey: .linkText)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        vanId = try container.decodeIfPresent(Int.self, forKey: .vanId)
    }
    
}

public struct SmartReplySmartWords: Decodable {
    public let original: [String]
    public let processed: [String]
    
}

public struct SmartReplyVa: Decodable {
    public let links: [Link]
    public let messages: [String]
    public let score: Int
    public let subTitle: String
    
    enum CodingKeys: String, CodingKey {
        case links = "links"
        case messages = "messages"
        case score = "score"
        case subTitle = "sub_title"
    }
}

public struct SmartReply: Decodable {
    public let importantWords: SmartReplySmartWords
    public let va: [SmartReplyVa]
    
    enum CodingKeys: String, CodingKey {
        case importantWords = "important_words"
        case va
    }
}

/**
    General response for all API calls
 */
public struct APIMessage: Decodable {
    /// Conversation object
    public let conversation: ConversationResult?
    /// Response from an interactive conversation
    public let response: Response?
    /// List of historic `Response` objects
    public let responses: [Response]?
    /// Response from a SMARTREPLY call
    public let smartReplies: SmartReply?
    public let postedId: Int?
    /// Extra variable to be used with the download command. You will get the result as a String in this variable
    public let download: String?
    
    enum CodingKeys: String, CodingKey {
        case conversation
        case response
        case responses
        case smartReplies = "smartreplies"
        case postedId = "posted_id"
        case download
    }
    
    public init(response: Response? = nil, download: String? = nil, conversation: ConversationResult? = nil) {
        self.conversation = conversation
        self.response = response
        self.responses = nil
        self.smartReplies = nil
        self.postedId = nil
        self.download = download
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
                
        conversation = try container.decodeIfPresent(ConversationResult.self, forKey: .conversation)
        response = try container.decodeIfPresent(Response.self, forKey: .response)
        postedId = try container.decodeIfPresent(Int.self, forKey: .postedId)
        smartReplies = try container.decodeIfPresent(SmartReply.self, forKey: .smartReplies)
        responses = try container.decodeIfPresent([Response].self, forKey: .responses)
        download = try container.decodeIfPresent(String.self, forKey: .download)
    }
}

public struct APIResponseError: Decodable {
    public let error: String
}
