//
//  Config.swift
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

public struct ConfigMessages: Decodable {
    public var back = "Back"
    public var closeWindow = "Close"
    public var composeCharactersUsed = "{0} out of {1} characters used"
    public var composePlaceholder = "Type in here"
    public var deleteConversation = "Delete conversation"
    public var downloadConversation = "Download conversation"
    public var feedbackPlaceholder = "Write in your feedback here"
    public var feedbackPrompt = "Do you want to give me feedback?"
    public var feedbackThumbsDown = "Not satisfied with conversation"
    public var feedbackThumbsUp = "Satisfied with conversation"
    public var filterSelect = "Select user group"
    public var headerText = "Conversational AI"
    public var loggedIn = "Secure chat"
    public var messageThumbsDown = "Not satisfied with answer"
    public var messageThumbsUp = "Satisfied with answer"
    public var minimizeWindow = "Minimize window"
    public var openMenu = "Open menu"
    public var opensInNewTab = "Opens in new tab"
    public var privacyPolicy = "Privacy policy"
    public var submitFeedback = "Send"
    public var submitMessage = "Send"
    public var textTooLong = "The message cannot be longer than {0} characters"
    public var uploadFile = "Upload image"
    public var uploadFileError = "Upload failed"
    public var uploadFileProgress = "Uploading ..."
    public var uploadFileSuccess = "Upload successful"
    
    private enum CodingKeys: String, CodingKey {
        case back
        case closeWindow = "close.window"
        case composeCharactersUsed = "compose.characters.used"
        case composePlaceholder = "compose.placeholder"
        case deleteConversation = "delete.conversation"
        case downloadConversation = "download.conversation"
        case feedbackPlaceholder = "feedback.placeholder"
        case feedbackPrompt = "feedback.prompt"
        case feedbackThumbsDown = "feedback.thumbs.down"
        case feedbackThumbsUp = "feedback.thumbs.up"
        case filterSelect = "filter.select"
        case headerText = "header.text"
        case loggedIn = "logged.in"
        case messageThumbsDown = "message.thumbs.down"
        case messageThumbsUp = "message.thumbs.up"
        case minimizeWindow = "minimize.window"
        case openMenu = "open.menu"
        case opensInNewTab = "opens.in.new.tab"
        case privacyPolicy = "privacy.policy"
        case submitFeedback = "submit.feedback"
        case submitMessage = "submit.message"
        case textTooLong = "text.too.long"
        case uploadFile = "upload.file"
        case uploadFileError = "upload.file.error"
        case uploadFileProgress = "upload.file.progress"
        case uploadFileSuccess = "upload.file.success"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        back = try container.decodeIfPresent(String.self, forKey: .back) ?? back
        closeWindow = try container.decodeIfPresent(String.self, forKey: .closeWindow) ?? closeWindow
        composeCharactersUsed = try container.decodeIfPresent(String.self, forKey: .composeCharactersUsed) ?? composeCharactersUsed
        composePlaceholder = try container.decodeIfPresent(String.self, forKey: .composePlaceholder) ?? composePlaceholder
        deleteConversation = try container.decodeIfPresent(String.self, forKey: .deleteConversation) ?? deleteConversation
        downloadConversation = try container.decodeIfPresent(String.self, forKey: .downloadConversation) ?? downloadConversation
        feedbackPlaceholder = try container.decodeIfPresent(String.self, forKey: .feedbackPlaceholder) ?? feedbackPlaceholder
        feedbackPrompt = try container.decodeIfPresent(String.self, forKey: .feedbackPrompt) ?? feedbackPrompt
        feedbackThumbsDown = try container.decodeIfPresent(String.self, forKey: .feedbackThumbsDown) ?? feedbackThumbsDown
        feedbackThumbsUp = try container.decodeIfPresent(String.self, forKey: .feedbackThumbsUp) ?? feedbackThumbsUp
        filterSelect = try container.decodeIfPresent(String.self, forKey: .filterSelect) ?? filterSelect
        headerText = try container.decodeIfPresent(String.self, forKey: .headerText) ?? headerText
        loggedIn = try container.decodeIfPresent(String.self, forKey: .loggedIn) ?? loggedIn
        messageThumbsDown = try container.decodeIfPresent(String.self, forKey: .messageThumbsDown) ?? messageThumbsDown
        messageThumbsUp = try container.decodeIfPresent(String.self, forKey: .messageThumbsUp) ?? messageThumbsUp
        minimizeWindow = try container.decodeIfPresent(String.self, forKey: .minimizeWindow) ?? minimizeWindow
        openMenu = try container.decodeIfPresent(String.self, forKey: .openMenu) ?? openMenu
        opensInNewTab = try container.decodeIfPresent(String.self, forKey: .opensInNewTab) ?? opensInNewTab
        privacyPolicy = try container.decodeIfPresent(String.self, forKey: .privacyPolicy) ?? privacyPolicy
        submitFeedback = try container.decodeIfPresent(String.self, forKey: .submitFeedback) ?? submitFeedback
        submitMessage = try container.decodeIfPresent(String.self, forKey: .submitMessage) ?? submitMessage
        textTooLong = try container.decodeIfPresent(String.self, forKey: .textTooLong) ?? textTooLong
        uploadFile = try container.decodeIfPresent(String.self, forKey: .uploadFile) ?? uploadFile
        uploadFileError = try container.decodeIfPresent(String.self, forKey: .uploadFileError) ?? uploadFileError
        uploadFileProgress = try container.decodeIfPresent(String.self, forKey: .uploadFileProgress) ?? uploadFileProgress
        uploadFileSuccess = try container.decodeIfPresent(String.self, forKey: .uploadFileSuccess) ?? uploadFileSuccess
    }
}

public struct ConfigLanguages: Decodable {
    
    public var languages: [String: ConfigMessages]
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            // We are not using this, thus just return nil
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        var tempArray = [String: ConfigMessages]()
        
        for key in container.allKeys {
            let decodedObject = try container.decode(ConfigMessages.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            tempArray[key.stringValue] = decodedObject
        }
        languages = tempArray
    }
}

public struct ConfigFilter: Decodable {
    public var id: Int
    public var title: String
    public var values: [String]
}

extension ConfigFilter: Equatable {
  public static func == (lhs: ConfigFilter, rhs: ConfigFilter) -> Bool {
    return lhs.id == rhs.id && lhs.title == rhs.title && lhs.values == rhs.values
  }
}

public struct ChatConfig: Decodable {
    public var avatarStyle: String
    public var clientMessageBackground: String
    public var clientMessageColor: String
    public var contrastColor: String
    public var fileUploadServiceEndpointUrl: String
    public var filters: [ConfigFilter]?
    public var hasFilterSelector: Bool
    public var linkBelowBackground: String
    public var linkBelowColor: String
    public var linkDisplayStyle: String
    public var primaryColor: String
    public var requestConversationFeedback: Bool
    public var serverMessageBackground: String
    public var serverMessageColor: String
    public var spacingBottom: Int
    public var spacingRight: Int
    public var windowStyle: String
    public var pace: String?
    public var messages: ConfigLanguages?
    
    private enum CodingKeys: String, CodingKey {
        case avatarStyle
        case clientMessageBackground
        case clientMessageColor
        case contrastColor
        case fileUploadServiceEndpointUrl
        case filters
        case hasFilterSelector
        case linkBelowBackground
        case linkBelowColor
        case linkDisplayStyle
        case primaryColor
        case requestConversationFeedback
        case serverMessageBackground
        case serverMessageColor
        case spacingBottom
        case spacingRight
        case windowStyle
        case pace
        case messages
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        avatarStyle = try container.decodeIfPresent(String.self, forKey: .avatarStyle) ?? "square"
        clientMessageBackground = try container.decodeIfPresent(String.self, forKey: .clientMessageBackground) ?? "#ede5ed"
        clientMessageColor = try container.decodeIfPresent(String.self, forKey: .clientMessageColor) ?? "#363636"
        contrastColor = try container.decodeIfPresent(String.self, forKey: .contrastColor) ?? "#ffffff"
        fileUploadServiceEndpointUrl = try container.decodeIfPresent(String.self, forKey: .fileUploadServiceEndpointUrl) ?? ""
        filters = try container.decodeIfPresent([ConfigFilter].self, forKey: .filters) ?? nil
        hasFilterSelector = try container.decodeIfPresent(Bool.self, forKey: .hasFilterSelector) ?? false
        linkBelowBackground = try container.decodeIfPresent(String.self, forKey: .linkBelowBackground) ?? "#552a55"
        linkBelowColor = try container.decodeIfPresent(String.self, forKey: .linkBelowColor) ?? "#ffffff"
        linkDisplayStyle = try container.decodeIfPresent(String.self, forKey: .linkDisplayStyle) ?? "below"
        primaryColor = try container.decodeIfPresent(String.self, forKey: .primaryColor) ?? "#552a55"
        requestConversationFeedback = try container.decodeIfPresent(Bool.self, forKey: .requestConversationFeedback) ?? true
        serverMessageBackground = try container.decodeIfPresent(String.self, forKey: .serverMessageBackground) ?? "#f2f2f2"
        serverMessageColor = try container.decodeIfPresent(String.self, forKey: .serverMessageColor) ?? "#363636"
        spacingBottom = try container.decodeIfPresent(Int.self, forKey: .spacingBottom) ?? 0
        spacingRight = try container.decodeIfPresent(Int.self, forKey: .spacingRight) ?? 80
        windowStyle = try container.decodeIfPresent(String.self, forKey: .windowStyle) ?? "rounded"
        pace = try container.decodeIfPresent(String.self, forKey: .pace)
        messages = try container.decodeIfPresent(ConfigLanguages.self, forKey: .messages)
        
    }
    
    public func language(languageCode: String) -> ConfigMessages {
        if let val = self.messages?.languages[languageCode] {
            return val
        } else {
            return (self.messages?.languages["en-US"])!
        }
    }
}
