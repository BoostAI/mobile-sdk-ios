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

public struct Messages: Decodable {
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
    
    public init() {}
}

public struct Languages: Decodable {
    
    public var languages: [String: Messages]
    
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
    
    public init(languages: [String: Messages]) {
        self.languages = languages
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        var tempArray = [String: Messages]()
        
        for key in container.allKeys {
            let decodedObject = try container.decode(Messages.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            tempArray[key.stringValue] = decodedObject
        }
        languages = tempArray
    }
}

public struct Filter: Decodable {
    public var id: Int
    public var title: String
    public var values: [String]
    
    public init(id: Int, title: String, values: [String]) {
        self.id = id
        self.title = title
        self.values = values
    }
}

extension Filter: Equatable {
  public static func == (lhs: Filter, rhs: Filter) -> Bool {
    return lhs.id == rhs.id && lhs.title == rhs.title && lhs.values == rhs.values
  }
}

public enum AvatarShape: String, Decodable {
    case rounded, squared
    
    public init(from decoder: Decoder) throws {
        self = try AvatarShape(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .rounded
    }
}

public typealias AvatarStyle = AvatarShape

public enum LinkDisplayStyle: String, Decodable {
    case below,
         inside
    
    public init(from decoder: Decoder) throws {
        self = try LinkDisplayStyle(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .below
    }
}

public enum ConversationPace: String, Decodable {
    case glacial
    case slower
    case slow
    case normal
    case fast
    case faster
    case supersonic
    
    public init(from decoder: Decoder) throws {
        self = try ConversationPace(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .normal
    }
}

public struct ConfigV2: Decodable {
    public var primaryColor: UIColor?
    public var contrastColor: UIColor?
    public var clientMessageBackground: UIColor?
    public var clientMessageColor: UIColor?
    public var serverMessageBackground: UIColor?
    public var serverMessageColor: UIColor?
    public var linkBelowBackground: UIColor?
    public var linkBelowColor: UIColor?
    public var linkDisplayStyle: LinkDisplayStyle?
    public var fileUploadServiceEndpointUrl: String?
    public var hasFilterSelector: Bool?
    public var rememberConversation: Bool?
    public var requestConversationFeedback: Bool?
    public var avatarStyle: AvatarStyle?
    public var pace: ConversationPace?
    public var filters: [Filter]?
    public var messages: Languages?
    
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
        case rememberConversation
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
        linkDisplayStyle = try container.decodeIfPresent(LinkDisplayStyle.self, forKey: .linkDisplayStyle)
        fileUploadServiceEndpointUrl = try container.decodeIfPresent(String.self, forKey: .fileUploadServiceEndpointUrl)
        hasFilterSelector = try container.decodeIfPresent(Bool.self, forKey: .hasFilterSelector)
        requestConversationFeedback = try container.decodeIfPresent(Bool.self, forKey: .requestConversationFeedback)
        rememberConversation = try container.decodeIfPresent(Bool.self, forKey: .rememberConversation)
        avatarStyle = try container.decodeIfPresent(AvatarStyle.self, forKey: .avatarStyle)
        pace = try container.decodeIfPresent(ConversationPace.self, forKey: .pace)
        filters = try container.decodeIfPresent([Filter].self, forKey: .filters)
        messages = try container.decodeIfPresent(Languages.self, forKey: .messages)
    }
    
    public func language(languageCode: String) -> Messages? {
        if let val = self.messages?.languages[languageCode] {
            return val
        } else {
            return self.messages?.languages["en-US"]
        }
    }
    
    public struct Defaults {
        public static let primaryColor = UIColor(hex: "#552a55")!
        public static let contrastColor = UIColor.white
        public static let clientMessageBackground = UIColor(hex: "#ede5ed")!
        public static let clientMessageColor = UIColor(hex: "#363636")!
        public static let serverMessageBackground = UIColor(hex: "#f2f2f2")!
        public static let serverMessageColor = UIColor(hex: "#363636")!
        public static let linkBelowBackground = UIColor(hex: "#552a55")!
        public static let linkBelowColor = UIColor.white
        public static let linkDisplayStyle = "below"
        public static let hasFilterSelector = false
        public static let requestConversationFeedback = true
        public static let rememberConversation = false
        public static let avatarStyle: AvatarStyle = .rounded
        public static let pace: ConversationPace = .normal
        public static let headlineFont = UIFont.preferredFont(forTextStyle: .headline)
        public static let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        public static let footnoteFont = UIFont.preferredFont(forTextStyle: .footnote)
        public static let menuItemFont = UIFont.preferredFont(forTextStyle: .title3)
    }
}

/// Chat config (version 3(
public struct ConfigV3: Decodable {
    public var messages: Languages?
    public var chatPanel: ChatPanel?
    
    private enum CodingKeys: String, CodingKey {
        case messages
        case chatPanel
    }
    
    public init(messages: Languages? = nil,
                chatPanel: ChatPanel?) {
        self.messages = messages
        self.chatPanel = chatPanel
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        messages = try container.decodeIfPresent(Languages.self, forKey: .messages)
        chatPanel = try container.decodeIfPresent(ChatPanel.self, forKey: .chatPanel)
    }
    
    public func language(languageCode: String) -> Messages? {
        if let val = self.messages?.languages[languageCode] {
            return val
        } else {
            return self.messages?.languages["en-US"]
        }
    }
    
    public struct Defaults {
        public struct Styling {
            public static let avatarShape = AvatarShape.rounded
            public static let pace = ConversationPace.normal
            public static let primaryColor = UIColor(hex: "#552a55")!
            public static let contrastColor = UIColor.white
            
            public struct ChatBubbles {
                public static let userBackgroundColor = UIColor(hex: "#ede5ed")!
                public static let userTextColor = UIColor(hex: "#363636")!
                public static let vaBackgroundColor = UIColor(hex: "#f2f2f2")!
                public static let vaTextColor = UIColor(hex: "#363636")!
            }
            
            public struct Buttons {
                public static let backgroundColor = UIColor(hex: "#552a55")!
                public static let textColor = UIColor.white
                public static let variant = ButtonType.button
                public static let multiline = false
            }
            
            public struct Composer {
                public static let hide = false
            }
            
            public struct MessageFeedback {
                public static let hide = false
            }
            
            public struct Fonts {
                public static let headlineFont = UIFont.preferredFont(forTextStyle: .headline)
                public static let bodyFont = UIFont.preferredFont(forTextStyle: .body)
                public static let footnoteFont = UIFont.preferredFont(forTextStyle: .footnote)
                public static let menuItemFont = UIFont.preferredFont(forTextStyle: .title3)
            }
        }
        
        public struct Settings {
            public static let messageFeedbackOnFirstAction = false
            public static let rememberConversation = false
            public static let requestFeedback = true
            public static let showLinkClickAsChatBubble = false
            public static let startNewConversationOnResumeFailure = true
            public static let triggerActionOnResume = false
        }
    }
}

/// Chat panel settings and styling wrapper object
public struct ChatPanel: Decodable {
    /// Panel header styling
    public var header: Header?
    
    /// Chat panel styling
    public var styling: Styling?
    
    /// General settings related to the chat
    public var settings: Settings?
    
    private enum CodingKeys: String, CodingKey {
        case header
        case styling
        case settings
    }
    
    public init(header: Header? = nil,
                styling: Styling? = nil,
                settings: Settings? = nil) {
        self.header = header
        self.styling = styling
        self.settings = settings
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        header = try container.decodeIfPresent(Header.self, forKey: .header)
        styling = try container.decodeIfPresent(Styling.self, forKey: .styling)
        settings = try container.decodeIfPresent(Settings.self, forKey: .settings)
    }
}

/// Chat panel header
public struct Header: Decodable {
    /// See `Filters` definition
    public var filters: Filters?
    
    /// Sets the title of the chat window. Will override the value from the Admin Panel.
    public var title: String?
    
    private enum CodingKeys: String, CodingKey {
        case filters
        case title
    }
    
    public init(filters: Filters? = nil,
                title: String? = nil) {
        self.filters = filters
        self.title = title
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        filters = try container.decodeIfPresent(Filters.self, forKey: .filters)
        title = try container.decodeIfPresent(String.self, forKey: .title)
    }
}

public struct Filters: Decodable {
    /// An array or string of action filter values.
    /// See the chapter on action filters for more information on this feature.
    public var filterValues: [String]?
    
    /// An array of filter objects
    public var options: [Filter]?
    
    private enum CodingKeys: String, CodingKey {
        case filterValues
        case options
    }
    
    public init(filterValues: [String]? = nil,
                options: [Filter]? = nil) {
        self.filterValues = filterValues
        self.options = options
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        filterValues = try container.decodeIfPresent([String].self, forKey: .filterValues)
        options = try container.decodeIfPresent([Filter].self, forKey: .options)
    }
}

/// Chat panel styling
public struct Styling: Decodable {
    /// Configures the speed with which replies are shown to the user.
    /// Valid values: glacial, slower, slow, normal, fast, faster, supersonic
    public var pace: ConversationPace?
    
    /// Avatar shape. Valid values: rounded, squared
    public var avatarShape: AvatarShape?
    
    /// Color for header bar and menu background.
    public var primaryColor: UIColor?
    
    /// Color for header text and text input outline.
    public var contrastColor: UIColor?
    
    /// Background color for the chat panel
    public var panelBackgroundColor: UIColor?
    
    /// Scrollbar style
    public var panelScrollbarStyle: UIScrollView.IndicatorStyle?
    
    /// Disable style changes when transferring VA in a VAN network?
    //public var disableVanStylingChange: Bool?
    
    /// See `ChatBubbles` definition
    public var chatBubbles: ChatBubbles?
    
    /// See `Buttons` definition
    public var buttons: Buttons?
    
    /// See `Composer` definition
    public var composer: Composer?
    
    /// See `MessageFeedback` definition
    public var messageFeedback: MessageFeedback?
    
    /// See `Fonts` definition
    public var fonts: Fonts?
    
    private enum CodingKeys: String, CodingKey {
        case pace
        case avatarShape
        case primaryColor
        case contrastColor
        case panelBackgroundColor
        //case disableVanStylingChange
        case buttons
        case composer
        case messageFeedback
    }
    
    public init(pace: ConversationPace? = nil,
                avatarShape: AvatarShape? = nil,
                primaryColor: UIColor? = nil,
                contrastColor: UIColor? = nil,
                panelBackgroundColor: UIColor? = nil,
                panelScrollbarStyle: UIScrollView.IndicatorStyle? = nil,
                //disableVanStylingChange: Bool? = nil,
                chatBubbles: ChatBubbles? = nil,
                buttons: Buttons? = nil,
                composer: Composer? = nil,
                messageFeedback: MessageFeedback? = nil,
                fonts: Fonts? = nil) {
        self.pace = pace
        self.avatarShape = avatarShape
        self.primaryColor = primaryColor
        self.contrastColor = contrastColor
        self.panelBackgroundColor = panelBackgroundColor
        self.panelScrollbarStyle = panelScrollbarStyle
        //self.disableVanStylingChange = disableVanStylingChange
        self.chatBubbles = chatBubbles
        self.buttons = buttons
        self.composer = composer
        self.messageFeedback = messageFeedback
        self.fonts = fonts
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        pace = try container.decodeIfPresent(ConversationPace.self, forKey: .pace)
        avatarShape = try container.decodeIfPresent(AvatarShape.self, forKey: .avatarShape)
        primaryColor = try container.decodeIfPresent(HexColor.self, forKey: .primaryColor)?.uiColor
        contrastColor = try container.decodeIfPresent(HexColor.self, forKey: .contrastColor)?.uiColor
        panelBackgroundColor = try container.decodeIfPresent(HexColor.self, forKey: .panelBackgroundColor)?.uiColor
        //disableVanStylingChange = try container.decodeIfPresent(Bool.self, forKey: .disableVanStylingChange)
        buttons = try container.decodeIfPresent(Buttons.self, forKey: .buttons)
        composer = try container.decodeIfPresent(Composer.self, forKey: .composer)
        messageFeedback = try container.decodeIfPresent(MessageFeedback.self, forKey: .messageFeedback)
    }
}

/// Styling of chat bubbles
public struct ChatBubbles: Decodable {
    /// Background color for client messages
    public var userBackgroundColor: UIColor?
    
    /// Color of text in client messages
    public var userTextColor: UIColor?
    
    /// Background color for virtual agent messages
    public var vaBackgroundColor: UIColor?
    
    /// Color of text from the virtual agent
    public var vaTextColor: UIColor?
    
    /// Color of dots showing VA or human operator is typing
    public var typingDotColor: UIColor?

    /// Background color of dots showing VA or human operator is typing
    public var typingBackgroundColor: UIColor?
    
    private enum CodingKeys: String, CodingKey {
        case userBackgroundColor
        case userTextColor
        case vaBackgroundColor
        case vaTextColor
        case typingDotColor
        case typingBackgroundColor
    }
    
    public init(userBackgroundColor: UIColor? = nil,
                userTextColor: UIColor? = nil,
                vaBackgroundColor: UIColor? = nil,
                vaTextColor: UIColor? = nil,
                typingDotColor: UIColor? = nil,
                typingBackgroundColor: UIColor? = nil) {
        self.userBackgroundColor = userBackgroundColor
        self.userTextColor = userTextColor
        self.vaBackgroundColor = vaBackgroundColor
        self.vaTextColor = vaTextColor
        self.typingDotColor = typingDotColor
        self.typingBackgroundColor = typingBackgroundColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userBackgroundColor = try container.decodeIfPresent(HexColor.self, forKey: .userBackgroundColor)?.uiColor
        userTextColor = try container.decodeIfPresent(HexColor.self, forKey: .userTextColor)?.uiColor
        vaBackgroundColor = try container.decodeIfPresent(HexColor.self, forKey: .vaBackgroundColor)?.uiColor
        vaTextColor = try container.decodeIfPresent(HexColor.self, forKey: .vaTextColor)?.uiColor
        typingDotColor = try container.decodeIfPresent(HexColor.self, forKey: .typingDotColor)?.uiColor
        typingBackgroundColor = try container.decodeIfPresent(HexColor.self, forKey: .typingBackgroundColor)?.uiColor
    }
}

/// Styling of action buttons
public struct Buttons: Decodable {
    /// Background color for links and buttons
    public var backgroundColor: UIColor?
    
    /// Text color for links and buttons
    public var textColor: UIColor?
    
    /// Background color when focused
    public var variant: ButtonType?
    
    /// Allow multiline text in buttons? Default false.
    public var multiline: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case backgroundColor
        case textColor
        case variant
        case multiline
    }
    
    public init(backgroundColor: UIColor? = nil,
                textColor: UIColor? = nil,
                focusBackgroundColor: UIColor? = nil,
                focusOutlineColor: UIColor? = nil,
                variant: ButtonType? = nil,
                multiline: Bool? = nil) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.variant = variant
        self.multiline = multiline
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        backgroundColor = try container.decodeIfPresent(HexColor.self, forKey: .backgroundColor)?.uiColor
        textColor = try container.decodeIfPresent(HexColor.self, forKey: .textColor)?.uiColor
        variant = try container.decodeIfPresent(ButtonType.self, forKey: .variant)
        multiline = try container.decodeIfPresent(Bool.self, forKey: .multiline)
    }
}

/// Styling of message feedback
public struct MessageFeedback: Decodable {
    /// Hide message feedback? Default false.
    public let hide: Bool?

    /// Outline color of thumbs up/down
    public let outlineColor: UIColor?
    
    /// Color of thumbs up/down when selected
    public let selectedColor: UIColor?
    
    private enum CodingKeys: String, CodingKey {
        case hide
        case outlineColor
        case selectedColor
    }
    
    public init(hide: Bool? = nil,
                outlineColor: UIColor? = nil,
                selectedColor: UIColor? = nil) {
        self.hide = hide
        self.outlineColor = outlineColor
        self.selectedColor = selectedColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        hide = try container.decodeIfPresent(Bool.self, forKey: .hide)
        outlineColor = try container.decodeIfPresent(HexColor.self, forKey: .outlineColor)?.uiColor
        selectedColor = try container.decodeIfPresent(HexColor.self, forKey: .selectedColor)?.uiColor
    }
}

/// Styling of the composer view, i.e. input field, submit button etc.
public struct Composer: Decodable {
    /// Hide composer
    public let hide: Bool?

    /// Color of the text that says how many characters have been typed (i.e. "5 / 130")
    public let composeLengthColor: UIColor?
    
    /// Disabled color of the number of characters typed
    //public let composeLengthDisabledColor: UIColor?

    /// Background color of the frame around the composer. The “frame” is everything below the
    /// topBorder  – the container around the text area (gray by default).
    public let frameBackgroundColor: UIColor?

    /// Color of the send button
    public let sendButtonColor: UIColor?

    /// Color of send button when disabled
    public let sendButtonDisabledColor: UIColor?

    /// Text area border color
    public let textareaFocusBorderColor: UIColor?
    
    /// Input text area outline color
    public let textareaFocusOutlineColor: UIColor?

    /// Input text area border color
    public let textareaBorderColor: UIColor?

    /// Input text area background color
    public let textareaBackgroundColor: UIColor?

    /// Input text area text color
    public let textareaTextColor: UIColor?

    /// Input text area placeholder color
    public let textareaPlaceholderTextColor: UIColor?

    /// Top border color
    public let topBorderColor: UIColor?

    /// Top border color when focused
    public let topBorderFocusColor: UIColor?
    
    private enum CodingKeys: String, CodingKey {
        case hide
        case composeLengthColor
        //case composeLengthDisabledColor
        case frameBackgroundColor
        case sendButtonColor
        case sendButtonDisabledColor
        case textareaFocusBorderColor
        case textareaFocusOutlineColor
        case textareaBorderColor
        case textareaBackgroundColor
        case textareaTextColor
        case textareaPlaceholderTextColor
        case topBorderColor
        case topBorderFocusColor
    }
    
    public init(hide: Bool? = nil,
                composeLengthColor: UIColor? = nil,
                //composeLengthDisabledColor: UIColor? = nil,
                frameBackgroundColor: UIColor? = nil,
                sendButtonColor: UIColor? = nil,
                sendButtonDisabledColor: UIColor? = nil,
                textareaBackgroundColor: UIColor? = nil,
                textareaBorderColor: UIColor? = nil,
                textareaFocusBorderColor: UIColor? = nil,
                textareaFocusOutlineColor: UIColor? = nil,
                textareaPlaceholderTextColor: UIColor? = nil,
                textareaTextColor: UIColor? = nil,
                topBorderColor: UIColor? = nil,
                topBorderFocusColor: UIColor? = nil) {
        self.hide = hide
        self.composeLengthColor = composeLengthColor
        //self.composeLengthDisabledColor = composeLengthDisabledColor
        self.frameBackgroundColor = frameBackgroundColor
        self.sendButtonColor = sendButtonColor
        self.sendButtonDisabledColor = sendButtonDisabledColor
        self.textareaFocusBorderColor = textareaFocusBorderColor
        self.textareaFocusOutlineColor = textareaFocusOutlineColor
        self.textareaBorderColor = textareaBorderColor
        self.textareaBackgroundColor = textareaBackgroundColor
        self.textareaTextColor = textareaTextColor
        self.textareaPlaceholderTextColor = textareaPlaceholderTextColor
        self.topBorderColor = topBorderColor
        self.topBorderFocusColor = topBorderFocusColor
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        hide = try container.decodeIfPresent(Bool.self, forKey: .hide)
        composeLengthColor = try container.decodeIfPresent(HexColor.self, forKey: .composeLengthColor)?.uiColor
        //composeLengthDisabledColor = try container.decodeIfPresent(HexColor.self, forKey: .composeLengthDisabledColor)?.uiColor
        frameBackgroundColor = try container.decodeIfPresent(HexColor.self, forKey: .frameBackgroundColor)?.uiColor
        sendButtonColor = try container.decodeIfPresent(HexColor.self, forKey: .sendButtonColor)?.uiColor
        sendButtonDisabledColor = try container.decodeIfPresent(HexColor.self, forKey: .sendButtonDisabledColor)?.uiColor
        textareaFocusBorderColor = try container.decodeIfPresent(HexColor.self, forKey: .textareaFocusBorderColor)?.uiColor
        textareaFocusOutlineColor = try container.decodeIfPresent(HexColor.self, forKey: .textareaFocusOutlineColor)?.uiColor
        textareaBorderColor = try container.decodeIfPresent(HexColor.self, forKey: .textareaBorderColor)?.uiColor
        textareaBackgroundColor = try container.decodeIfPresent(HexColor.self, forKey: .textareaBackgroundColor)?.uiColor
        textareaTextColor = try container.decodeIfPresent(HexColor.self, forKey: .textareaTextColor)?.uiColor
        textareaPlaceholderTextColor = try container.decodeIfPresent(HexColor.self, forKey: .textareaPlaceholderTextColor)?.uiColor
        topBorderColor = try container.decodeIfPresent(HexColor.self, forKey: .topBorderColor)?.uiColor
        topBorderFocusColor = try container.decodeIfPresent(HexColor.self, forKey: .topBorderFocusColor)?.uiColor
    }
}

/// Button display type for action buttons
public enum ButtonType: String, Decodable {
    case button
    case bullet
    
    public init(from decoder: Decoder) throws {
        self = try ButtonType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .button
    }
}

/// Custom fonts
public struct Fonts {
    /// Font used for body text
    public var bodyFont: UIFont?
    
    /// Font used for headlines
    public var headlineFont: UIFont?
    
    /// Font used for footnote sized strings (status messages, character count text etc.)
    public var footnoteFont: UIFont?
    
    /// Font used for menu titles
    public var menuItemFont: UIFont?
    
    public init(bodyFont: UIFont? = nil,
                headlineFont: UIFont? = nil,
                footnoteFont: UIFont? = nil,
                menuItemFont: UIFont? = nil) {
        self.bodyFont = bodyFont
        self.headlineFont = headlineFont
        self.footnoteFont = footnoteFont
        self.menuItemFont = menuItemFont
    }
}

/// Chat panel settings
public struct Settings: Decodable {
    /// Action to trigger instead of the welcome message when the chat window opens and the user is authenticated
    public var authStartTriggerActionId: Int?

    /// Initial context topic for the chat.
    public var contextTopicIntentId: Int?

    /**
     * conversationId for resuming an existing conversation
     *
     * If provided, the chat window will attempt to resume the conversation with the given ID.
     * If a conversation with the provided ID does not exist, a new conversation with a new ID will
     * be generated. Note that in this case, the provided ID will not be used. To know the current
     * conversation ID, listen to the `conversationIdChanged` event.
     */
    public var conversationId: String?

    /// Custom payload to send for each request
    public var customPayload: AnyCodable?
    
    /// The endpoint to upload files
    public var fileUploadServiceEndpointUrl: String?
    
    /// Enable or disable thumbs up or down in the welcome message. Default false.
    public var messageFeedbackOnFirstAction: Bool?
    
    /// Wether the app should remember conversation when closed (to resume on next launch)? Default false
    public var rememberConversation: Bool?
    
    /// Whether the user should be asked for feedback when they close the panel. Default true.
    public var requestFeedback: Bool?
    
    /// Sets the Human Chat skill for the conversation
    public var skill: String?

    /// Preferred BCP47 language for welcome message. Examples: 'en-US', 'fr-FR' and 'sv-SE'. Default language as configured in Admin Panel.
    public var startLanguage: String?

    /// If an invalid conversation Id is provided, start a new conversation. Default true
    public var startNewConversationOnResumeFailure: Bool?

    /// Action to trigger instead of the welcome message when the chat window opens
    public var startTriggerActionId: Int?
    
    /// Should we trigger action on resume (requires a startTriggerActionId to be set). Default false
    public var triggerActionOnResume: Bool?
    
    /// Sets the user token for authenticated conversations
    public var userToken: String? = nil
    
    /// Whether to show clicked links as new messages (appears as sent from client)
    public var showLinkClickAsChatBubble: Bool?
    
    
    
    /// Whether the welcome message should be skipped (the server should not send the welcome message if this is true)
    public var skipWelcomeMessage: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case authStartTriggerActionId
        case contextTopicIntentId
        case conversationId
        case customPayload
        case fileUploadServiceEndpointUrl
        case messageFeedbackOnFirstAction
        case rememberConversation
        case requestFeedback
        case showLinkClickAsChatBubble
        case skill
        case startLanguage
        case startNewConversationOnResumeFailure
        case startTriggerActionId
        case triggerActionOnResume
        case userToken
        case skipWelcomeMessage
    }
    
    public init(authStartTriggerActionId: Int? = nil,
                contextTopicIntentId: Int? = nil,
                conversationId: String? = nil,
                customPayload: AnyCodable? = nil,
                fileUploadServiceEndpointUrl: String? = nil,
                messageFeedbackOnFirstAction: Bool? = nil,
                rememberConversation: Bool? = nil,
                requestFeedback: Bool? = nil,
                showLinkClickAsChatBubble: Bool? = nil,
                skill: String? = nil,
                startLanguage: String? = nil,
                startNewConversationOnResumeFailure: Bool? = nil,
                startTriggerActionId: Int? = nil,
                triggerActionOnResume: Bool? = false,
                userToken: String? = nil,
                skipWelcomeMessage: Bool? = nil) {
        self.authStartTriggerActionId = authStartTriggerActionId
        self.contextTopicIntentId = contextTopicIntentId
        self.conversationId = conversationId
        self.customPayload = customPayload
        self.fileUploadServiceEndpointUrl = fileUploadServiceEndpointUrl
        self.messageFeedbackOnFirstAction = messageFeedbackOnFirstAction
        self.rememberConversation = rememberConversation
        self.requestFeedback = requestFeedback
        self.showLinkClickAsChatBubble = showLinkClickAsChatBubble
        self.skill = skill
        self.startLanguage = startLanguage
        self.startNewConversationOnResumeFailure = startNewConversationOnResumeFailure
        self.startTriggerActionId = startTriggerActionId
        self.triggerActionOnResume = triggerActionOnResume
        self.userToken = userToken
        self.skipWelcomeMessage = skipWelcomeMessage
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        authStartTriggerActionId = try container.decodeIfPresent(Int.self, forKey: .authStartTriggerActionId)
        contextTopicIntentId = try container.decodeIfPresent(Int.self, forKey: .contextTopicIntentId)
        conversationId = try container.decodeIfPresent(String.self, forKey: .conversationId)
        customPayload = try container.decodeIfPresent(AnyCodable.self, forKey: .customPayload)
        fileUploadServiceEndpointUrl = try container.decodeIfPresent(String.self, forKey: .fileUploadServiceEndpointUrl)
        messageFeedbackOnFirstAction = try container.decodeIfPresent(Bool.self, forKey: .messageFeedbackOnFirstAction)
        requestFeedback = try container.decodeIfPresent(Bool.self, forKey: .requestFeedback)
        rememberConversation = try container.decodeIfPresent(Bool.self, forKey: .rememberConversation)
        showLinkClickAsChatBubble = try container.decodeIfPresent(Bool.self, forKey: .showLinkClickAsChatBubble)
        skill = try container.decodeIfPresent(String.self, forKey: .skill)
        startLanguage = try container.decodeIfPresent(String.self, forKey: .startLanguage)
        startNewConversationOnResumeFailure = try container.decodeIfPresent(Bool.self, forKey: .startNewConversationOnResumeFailure)
        startTriggerActionId = try container.decodeIfPresent(Int.self, forKey: .startTriggerActionId)
        triggerActionOnResume = try container.decodeIfPresent(Bool.self, forKey: .triggerActionOnResume)
        userToken = try container.decodeIfPresent(String.self, forKey: .userToken)
        skipWelcomeMessage = try container.decodeIfPresent(Bool.self, forKey: .skipWelcomeMessage)
    }
}

/// Convert a ConfigV2 struct into a ConfigV3 struct
public func convertConfig(configV2: ConfigV2) -> ConfigV3 {
    func convertButtonVariant(_ configV2Style: LinkDisplayStyle?) -> ButtonType {
        switch configV2Style {
        case .inside:
            return .bullet
        case .below:
            fallthrough
        default:
            return .button
        }
    }
    
    return ConfigV3(messages: configV2.messages,
                    chatPanel: ChatPanel(
                        header: Header(
                            filters: Filters(options: configV2.filters)
                        ),
                        styling: Styling(
                            pace: configV2.pace,
                            avatarShape: configV2.avatarStyle,
                            primaryColor: configV2.primaryColor,
                            contrastColor: configV2.contrastColor,
                            chatBubbles: ChatBubbles(
                                userBackgroundColor: configV2.clientMessageBackground,
                                userTextColor: configV2.clientMessageColor,
                                vaBackgroundColor: configV2.serverMessageBackground,
                                vaTextColor: configV2.serverMessageColor
                            ),
                            buttons: Buttons(
                                backgroundColor: configV2.linkBelowBackground,
                                textColor: configV2.linkBelowColor,
                                variant: convertButtonVariant(configV2.linkDisplayStyle)
                            ),
                            fonts: Fonts(
                                bodyFont: configV2.bodyFont,
                                headlineFont: configV2.headlineFont,
                                footnoteFont: configV2.footnoteFont,
                                menuItemFont: configV2.menuItemFont
                            )
                        ),
                        settings: Settings(fileUploadServiceEndpointUrl: configV2.fileUploadServiceEndpointUrl,
                                           rememberConversation: configV2.rememberConversation,
                                           requestFeedback: configV2.requestConversationFeedback)
                    )
    )
}

public typealias ChatConfig = ConfigV3
