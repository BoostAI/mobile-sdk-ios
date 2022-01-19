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
import UIKit

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

public enum AvatarStyle: String, Decodable {
    case rounded, squared
    
    public init(from decoder: Decoder) throws {
        self = try AvatarStyle(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .rounded
    }
}

public enum Pace: String, Decodable {
    case glacial, slower, slow, normal, fast, faster, supersonic
    
    public init(from decoder: Decoder) throws {
        self = try Pace(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .normal
    }
}

public struct ChatConfig: Decodable {
    public var primaryColor: UIColor?
    public var contrastColor: UIColor?
    public var clientMessageBackground: UIColor?
    public var clientMessageColor: UIColor?
    public var serverMessageBackground: UIColor?
    public var serverMessageColor: UIColor?
    public var linkBelowBackground: UIColor?
    public var linkBelowColor: UIColor?
    public var linkDisplayStyle: String?
    public var fileUploadServiceEndpointUrl: String?
    public var hasFilterSelector: Bool?
    public var requestConversationFeedback: Bool?
    public var avatarStyle: AvatarStyle?
    public var pace: Pace?
    public var filters: [ConfigFilter]?
    public var messages: ConfigLanguages?
    
    /// Font used for body text
    public var bodyFont: UIFont?
    
    /// Font used for headlines
    public var headlineFont: UIFont?
    
    /// Font used for footnote sized strings (status messages, character count text etc.)
    public var footnoteFont: UIFont?
    
    /// Font used for menu titles
    public var menuItemFont: UIFont?
    
    private enum CodingKeys: String, CodingKey {
        case primaryColor
        case contrastColor
        case clientMessageBackground
        case clientMessageColor
        case serverMessageBackground
        case serverMessageColor
        case linkBelowBackground
        case linkBelowColor
        case linkDisplayStyle
        case fileUploadServiceEndpointUrl
        case hasFilterSelector
        case requestConversationFeedback
        case avatarStyle
        case pace
        case filters
        case messages
    }
    
    public init() {}
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        primaryColor = try container.decodeIfPresent(HexColor.self, forKey: .primaryColor)?.uiColor
        contrastColor = try container.decodeIfPresent(HexColor.self, forKey: .contrastColor)?.uiColor
        clientMessageBackground = try container.decodeIfPresent(HexColor.self, forKey: .clientMessageBackground)?.uiColor
        clientMessageColor = try container.decodeIfPresent(HexColor.self, forKey: .clientMessageColor)?.uiColor
        serverMessageBackground = try container.decodeIfPresent(HexColor.self, forKey: .serverMessageBackground)?.uiColor
        serverMessageColor = try container.decodeIfPresent(HexColor.self, forKey: .serverMessageColor)?.uiColor
        linkBelowBackground = try container.decodeIfPresent(HexColor.self, forKey: .linkBelowBackground)?.uiColor
        linkBelowColor = try container.decodeIfPresent(HexColor.self, forKey: .linkBelowColor)?.uiColor
        linkDisplayStyle = try container.decodeIfPresent(String.self, forKey: .linkDisplayStyle)
        fileUploadServiceEndpointUrl = try container.decodeIfPresent(String.self, forKey: .fileUploadServiceEndpointUrl)
        hasFilterSelector = try container.decodeIfPresent(Bool.self, forKey: .hasFilterSelector)
        requestConversationFeedback = try container.decodeIfPresent(Bool.self, forKey: .requestConversationFeedback)
        avatarStyle = try container.decodeIfPresent(AvatarStyle.self, forKey: .avatarStyle)
        pace = try container.decodeIfPresent(Pace.self, forKey: .pace)
        filters = try container.decodeIfPresent([ConfigFilter].self, forKey: .filters)
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

public struct ChatConfigDefaults {
    public static var primaryColor = UIColor(hex: "#552a55")!
    public static var contrastColor = UIColor.white
    public static var clientMessageBackground = UIColor(hex: "#ede5ed")!
    public static var clientMessageColor = UIColor(hex: "#363636")!
    public static var serverMessageBackground = UIColor(hex: "#f2f2f2")!
    public static var serverMessageColor = UIColor(hex: "#363636")!
    public static var linkBelowBackground = UIColor(hex: "#552a55")!
    public static var linkBelowColor = UIColor.white
    public static var linkDisplayStyle = "below"
    public static var hasFilterSelector = false
    public static var requestConversationFeedback = true
    public static var avatarStyle: AvatarStyle = .rounded
    public static var pace: Pace = .normal
    public static var headlineFont = UIFont.preferredFont(forTextStyle: .headline)
    public static var bodyFont = UIFont.preferredFont(forTextStyle: .body)
    public static var footnoteFont = UIFont.preferredFont(forTextStyle: .footnote)
    public static var menuItemFont = UIFont.preferredFont(forTextStyle: .title3)
}

public struct HexColor: Decodable {
    
    var uiColor: UIColor?
    
    public init(from decoder: Decoder) throws {
        let data = try decoder.singleValueContainer().decode(String.self)
        uiColor = UIColor(hex: data)
    }
    
    init(hexColor: String) {
        uiColor = UIColor(hex: hexColor)
    }
}
