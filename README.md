# BoostAI SDK

## Table of Contents
* [License](#license)
* [Installation](#installation)
    * [CocoaPods](#cocoapods)
    * [Carthage](#carthage)
* [Frontend/UI](#frontendui)
    * [ChatBackend](#chatbackend)
    * [Config](#config)
        * [Fonts](#fonts)
        * [Config overview](#config-overview)
    * [Display the chat](#display-the-chat)
        * [Floating avatar](#floating-avatar)
        * [Docked chat view (in a tab bar)](#docked-chat-view-in-a-tab-bar)
        * [Modal chat view](#modal-chat-view)
    * [ChatViewController](#chatviewcontroller)
    * [Customize responses (i.e. handle custom JSON responses)](#customize-responses-ie-handle-custom-json-responses)
    * [Subscribe to UI events](#subscribe-to-ui-events)
    * [Override URL button tap handling](#override-url-button-tap-handling)
* [Backend](#backend)
    * [Subscribe to messages](#subscribe-to-messages)
    * [Subscribe to config changes](#subscribe-to-config-changes)
    * [Subscribe to backend `emitEvent` JSON](#subscribe-to-backend-emitevent-json)
    * [Commands](#commands)
    * [Post](#post)
    * [Send](#send)
    * [Certificate pinning](#certificate-pinning)

## License

A commercial license will be granted to any Boost AI clients that want to use the SDK.

## Installation

### CocoaPods

CocoaPods is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate BoostAI into your Xcode project using CocoaPods, specify it in your Podfile:

```
pod 'BoostAI', '~> 1.2.9'
```

### Carthage

Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate BoostAI into your Xcode project using Carthage, specify it in your Cartfile:

```
github "BoostAI/mobile-sdk-ios" ~> 1.2.9
```

## Frontend/UI

The UI library is developed with two main goals:

1. Make it "plug and play" for normal use cases
2. Make it easy to extend and customize by exposing configurable variables and opening up for subclassing

See the `iOS Example` project for a demo of how to set up chat view via a floating avatar or a chat view under a tab in the tab bar.

### ChatBackend

To start off, we need an instance of the `ChatBackend` class. You can use the `ChatBackend.shared` static variable if you only want a single conversation in the app, or create multiple instance of the `ChatBackend` if you want multiple/separate conversations in several places in the app.

```
let backend = ChatBackend.shared
backend.domain = "your-name.boost.ai" // Your boost.ai server domain name
backend.languageCode = "en-US" // Default value – will potentially be overriden by the backend config
```

### Config

Almost all of colors, string and other customization is available in a `Config` object that comes from the server. The config object kan be accessed at any point later through the `ChatBackend.config` property. Before we display the chat view, we should wait for the config to be ready. This can be done by calling `ChatBackend.onReady(completion: @escaping (ChatConfig?, Error?) -> Void)` with a callback.

If you want to locally override some of the config variables, you can pass a custom `ChatConfig` object to the `ChatViewController` or `AgentAvatarView`:

```swift
let customConfig = ChatConfig(
    chatPanel: ChatPanel(
        header: Header(title: "Testing..."),
        styling: Styling(
            primaryColor: .red,
            contrastColor: .blue,
            chatBubbles: ChatBubbles(
                userBackgroundColor: .brown,
                userTextColor: .purple,
                vaBackgroundColor: .green,
                vaTextColor: .yellow),
            buttons: Buttons(
                multiline: true,
                backgroundColor: .cyan,
                textColor: .magenta
            )
        ),
        settings: Settings(
            showLinkClickAsChatBubble: true
        )
    )
)

let vc = ChatViewController(backend: backend, customConfig: customConfig)
let navController = UINavigationController(rootViewController: vc)

present(navController, animated: true, completion: nil)
```

See the "Configuring the Chat Panel" > "Options" chapter of the Chat Panel JavaScript documentation for an extensive overview of the options available for overriding.

#### Fonts

The UI by default uses the `UIFont.preferredFont(forTextStyle: ...)` methods to get fonts for different use cases. Pass a custom font to customize the font and/or font sizes. Supported fonts (with default values :

```swift
/// Font used for body text
public var bodyFont: UIFont = UIFont.preferredFont(forTextStyle: .body)

/// Font used for headlines
public var headlineFont: UIFont = UIFont.preferredFont(forTextStyle: .headline)

/// Font used for menu titles
public var menuItemFont: UIFont = UIFont.preferredFont(forTextStyle: .title3)

/// Font used for footnote sized strings (status messages, character count text etc.)
public var footnoteFont: UIFont = UIFont.preferredFont(forTextStyle: .footnote)
```

Plase note that these are not a part of the JavaScript specification.

Set them on a custom chat config and pass it to a `ChatViewController`:

```swift
let customConfig = ChatConfig(
    chatPanel: ChatPanel(
        styling: Styling(
            fonts: Fonts(
                bodyFont: // My custom body font here
            )
        )
    )
)
```

#### Config overview

Here is a full overview over the available properties with corresponding types in the `ChatConfig` object (please note that this is not runnable code):

```
ChatConfig(
    messages: Languages?,
    chatPanel: ChatPanel(
        styling: Styling(
            pace: ConversationPace?,
            avatarShape: AvatarShape?,
            primaryColor: UIColor?,
            contrastColor: UIColor?,
            panelBackgroundColor: UIColor?,
            panelScrollbarStyle: UIScrollView.IndicatorStyle?,
            chatBubbles: ChatBubbles(
                userBackgroundColor: UIColor?,
                userTextColor: UIColor?,
                vaBackgroundColor: UIColor?,
                vaTextColor: UIColor?,
                typingDotColor: UIColor?,
                typingBackgroundColor: UIColor?
            ),
            buttons: Buttons(
                backgroundColor: UIColor?,
                textColor: UIColor?,
                focusBackgroundColor: UIColor?,
                focusOutlineColor: UIColor?,
                variant: ButtonType?,
                multiline: Bool?
            ),
            composer: Composer(
                hide: Bool?,
                composeLengthColor: UIColor?,
                frameBackgroundColor: UIColor?,
                sendButtonColor: UIColor?,
                sendButtonDisabledColor: UIColor?,
                textareaBackgroundColor: UIColor?,
                textareaBorderColor: UIColor?,
                textareaFocusBorderColor: UIColor?,
                textareaFocusOutlineColor: UIColor?,
                textareaPlaceholderTextColor: UIColor?,
                textareaTextColor: UIColor?,
                topBorderColor: UIColor?,
                topBorderFocusColor: UIColor?
            ),
            messageFeedback: MessageFeedback(
                hide: Bool?,
                outlineColor: UIColor?,
                selectedColor: UIColor?
            ),
            fonts: Fonts(
                bodyFont: UIFont?,
                headlineFont: UIFont?,
                footnoteFont: UIFont?,
                menuItemFont: UIFont?
            )
        ),
        settings: Settings(
            authStartTriggerActionId: Int?,
            contextTopicIntentId: Int?,
            conversationId: String?,
            customPayload: AnyCodable?,
            fileUploadServiceEndpointUrl: String?,
            messageFeedbackOnFirstAction: Bool?,
            rememberConversation: Bool?,
            requestFeedback: Bool?,
            showLinkClickAsChatBubble: Bool?,
            skill: String?,
            startLanguage: String?,
            startNewConversationOnResumeFailure: Bool?,
            startTriggerActionId: Int?,
            userToken: String?
        )
    )
)
```

### Display the chat

#### Floating avatar

To set up a floating avatar, you can do something along the lines of:

```swift
backend.onReady { [weak self] (_, _) in
    // The backend has received a config and is now ready
    DispatchQueue.main.async {
        guard let self = self else { return }

        let avatarView = AgentAvatarView(backend: self.backend)
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(avatarView)

        let constraints = [
            self.view.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 20),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 20)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
```

The `AgentAvatarView` class handles tapping on the icon and displaying the default `ChatViewController`. You may configure the `AgentAvatarView` by passing an `UIImage` to the `avatarImage` property, and optionally override the default `avatarSize` (which is 60 points).

#### Docked chat view (in a tab bar)

To display the `ChatViewController` in a tab bar:

```swift
let chatViewController = ChatViewController(backend: backend)
let chatDialogNavController = UINavigationController(rootViewController: chatViewController)
tabBarController.viewControllers = [chatDialogNavController]
```

#### Modal chat view

To present the chat modally:

```swift
let backend = ChatBackend.shared
backend.onReady { [weak self] (_, _) in
    DispatchQueue.main.async {
        let chatViewController = ChatViewController(backend: backend)
        let chatDialogNavController = UINavigationController(rootViewController: chatViewController)
        self?.present(chatDialogNavController, animated: true)
    }
}
```

### ChatViewController

The `ChatViewController` is the main entry point for the chat view. It can be subclassed for fine-grained control, or you can set and override properties and assign yourself as a delegate to configure most of the normal use cases.

### Customize responses (i.e. handle custom JSON responses)

If you want to override the display of responses from the server, you can assign yourself as a `ChatViewControllerDelegate`:

```swift
let chatViewController = ChatViewController(backend: backend)
chatViewController.chatResponseViewDataSource = self
```

In order to display a view for a custom JSON object, return a view for the `json` type (return nil will lead the `ChatResponseView` to handle it).

Use the `JSONDecoder` to parse the JSON with a custom class describing the JSON object, i.e. for the "genericCard" default template, where the object looks like: 


```json
{
  "body": {
    "text": "This is the logo for the worlds best football club."
  },
  "heading": {
    "text": "UNITED"
  },
  "image": {
    "alt": "Photo of product",
    "position": "top",
    "url": "https://cdn.united.no/uploads/2020/09/kenilworthroad220720.jpg"
  },
  "link": {
    "text": "More information",
    "url": "https://united.no"
  },
  "template": "genericCard"
}
```

Define a `Decodable` struct that matches the data:

```swift
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
```

Return a view that displays the data:

```swift
class MyClass: ChatResponseViewDataSource {
    func messageViewFor(element: Element) -> UIView? {
        switch element.type {
        case .json:
            guard let json = element.payload.json else { return nil }
            
            let decoder = JSONDecoder()
            do {
                let content = try decoder.decode(GenericCard.self, from: json)
                
                // Create a view tree that displays the data
                let view = ...
                return view
            } catch {
                // Handle JSON parsing error
            }
        default:
            return nil
    }
}
```

If you want more control, you can return a `ChatResponseView` subclass from the `chatResponseView(backend: ChatBackend)` method, which will get its `configureWith(response: Response, conversation: ConversationResult? = nil, animateElements: Bool = true, sender: ChatResponseViewDelegate?)` method call for each message that arrives from the server or the user:

```swift
class CustomChatResponseView: ChatResponseView {
    override open func configureWith(response: Response, conversation: ConversationResult? = nil, animateElements: Bool = true, sender: ChatResponseViewDelegate?) {
          ...
    }
}

class MyClass: ChatViewControllerDelegate {

    /// Return a fully custom response view (must be a subclass of ChatResponseView
    func chatResponseView(backend: ChatBackend) -> ChatResponseView? {
        return CustomChatResponseView(backend: backend)
    }
    
    /// Return a custom subclass of a menu view controller if needed
    func menuViewController(backend: ChatBackend) -> MenuViewController? {
        return nil
    }

    /// Return a custom subclass of the conversation feedback view controller if needed
    func conversationFeedbackViewController(backend: ChatBackend) -> ConversationFeedbackViewController? {
        return nil
    }
}
```

Return `MenuViewController` or `ConversationFeedbackViewController` subclasses if needed, if not return nil.

### Subscribe to UI events

You can subscribe to UI events by adding an observer to the `BoostUIEvents`. `event` (defined as an enum called `Event`) and `detail` refer to the events and detail as described in the JS Chat Panel documentation under the chapter "Events" (`addEventListener`).

```swift
BoostUIEvents.shared.addEventObserver(self) { event, detail in
   switch event {
   case .menuOpened:
       // Do something when the menu has opened
   default:
       break
   }
}
```

### Override URL button tap handling

By default all taps on URL buttons that contain a URL (not just an action ID) will open in an SFSafariViewController inside the app. You can override this behavior to fit your needs.

You can either set the `shouldOpenLinksInSystemBrowser` to true to open all URL links in the system browser (calls `UIApplication.shared.openUrl(url)` and normally opens Safari), sending users out of the app.

If you want more fine grained control on a per URL basis, i.e. if the virtual agent will return buttons with deep links to your own app and you want to let the system handle the URL and open your app in the correct spot, you can assign yourself as a delegate and decide if you want to open the URL in an app browser or let the system handle it for you:

```
class YourClass: ..., ChatResponseViewURLDelegate {
    func viewDidLoad() {
        super.viewDidLoad()

        let chatViewController = ChatViewController(backend: backend)
        chatViewController.urlHandlingDelegate = self // Assign yourself as a delegate
    }

    func chatResponseView(_ chatResponseView: BoostAI.ChatResponseView, decidePolicyFor url: URL, decisionHandler: (BoostAI.ChatResponseViewURLHandling) -> Void) {
        if let host = url.host, host == "[your domain with deep links]" {
            decisionHandler(.openInSystemBrowser) // Will follow deep links, as it calls UIApplication.shared.openUrl(url)
        } else {
            decisionHandler(.openInAppBrowser)
        }
    }
}
```

## Backend

The `ChatBackend` class is the main entry point for everything backend/API related. As a minimum, it needs an SDK domain to point to:

```swift
let backend = ChatBackend()
backend.domain = "your-name.boost.ai" // Your boost.ai server domain name
```

If you use the `ChatBackend` outside of the provided UI classes, always start by calling `getConfig(completion: @escaping (ChatConfig?, Error?) -> Void)` to get the server config object, which has colors and string etc. that is needed for the UI.

### Subscribe to messages

The easiest way to use the backend for your own frontend needs is to subscribe to messages:

```swift
backend.addMessageObserver(self) { [weak self] (message, error) in
    DispatchQueue.main.async {
        // Handle the ApiMessage (Response.swift) received
    }
}
```

### Subscribe to config changes

The server config might be updated/changed based on the user chat. If the user is transferred to another virtual agent in a VAN (Virtual Agent Network), i.e. the user is transferred to a virtual agent specialized in insurance cases after the user asks a question regarding insurance, the virtual agent avatar might change, and the dialog colors change etc.

Subscribe to notifications about config changes and update UI styling accordingly:

```swift
backend.addConfigObserver(self) { (config, error) in
    DispatchQueue.main.async {
        if let config = config {
            // Update styling based on the new config
        }
    }
}
```

### Subscribe to backend `emitEvent` JSON

If you are sending custom events from the server-side action flow, you can subscribe to these in your app by adding an observer to the chat backend. `type` and `detail` refer to the events and detail as described in the JS Chat Panel documentation under the chapter "Events" (`addEventListener`), regarding the `emitEvent` JSON type.

```swift
backend.addEventObserver(self) { type, detail in
   switch type {
   case "myEventKey":
       // Handle emitted event with the key "myEventKey"
   default:
       break
   }
}
```

### Commands

All commands available in the API is accessible in the `Commands.swift` file, with the `Command` enum describing them all:

```swift
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
```

You'll find all the commands on the `ChatBackend` object. Almost all of them can be called without a parameter, which will use the
default value, or you can add the message definition from `Commands.swift`.

```swift
backend.start()
backend.start(CommandStart())
backend.start(CommandStart(filterValues: ['test']))

backend.stop()
backend.resume()
backend.delete()
backend.poll()
backend.pollStop()
backend.smartReply()
backend.humanChatPost()
backend.typing()
backend.conversationFeedback(CommandFeedback())
backend.download()
backend.loginEvent(CommandLoginEvent())
```

### Post

Post is a bit different. You should try to avoid using the internal 
`backend.post(parameters: Data, completion: @escaping (APIMessage?, Error?) -> Void)` command, and instead use the
predefined commands:

```swift
backend.actionButton(id: String)
backend.message(value: String)
backend.feedback(id: String, value: FeedbackValue)
backend.urlButton(id: String)
backend.sendFiles(files: [File])
backend.triggerAction(id: String)
backend.smartReply(value: String)
backend.humanChatPost(value: String)
backend.clientTyping(value: String) -> ClientTyping
backend.conversationFeedback(rating: Int, text: String?)
backend.loginEvent(userToken: String)
```

### Send

You can also send a command with `send()`. You can use the predefined commands, which should include all the ones the server support,
or define your own if you have a server which support more. The command must then conform to the `CommandProtocol` and
`JSONEncoder()`.

```swift
public protocol CommandProtocol: Encodable {
    var command: Command {get set}
}

backend.send(CommandStart())
```

The result will be received throught the regular publish/subscribe methods described above.

Or if you want to directly take control over the result, use the callback.

```swift
backend.send(CommandStart()) { (apiMessage, error) in
    if let error = error {
        // Handle the error
        return
    }
    
    // Handle the ApiMessage
}
```

### Certificate pinning

If you want to pin SSL certificates used for the `ChatBackend` communication with the Boost API backend, you can enable this by setting `isCertificatePinningEnabled` to `true`:

```swift
backend.isCertificatePinningEnabled = true
```

Please note that the certificates are pinned against Amazon Root CAs, as described here: [Can I pin an application that's running on AWS to a certificate that was issued by AWS Certificate Manager (ACM)?](https://aws.amazon.com/premiumsupport/knowledge-center/pin-application-acm-certificate/)

The list of root CAs pinned against can be found in the [Amazon Trust Repository](https://www.amazontrust.com/repository/).
