//
//  ChatDialogTableViewCell.swift
//  BoostAIUI
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

import UIKit
import WebKit
import SafariServices


/// Data source for response view. Return custom views for messages received from boost.ai backend..
public protocol ChatResponseViewDataSource {
    
    /// Create a custom view for a message element
    /// - Parameter element: An Element with a payload and type
    func messageViewFor(element: Element) -> UIView?
}

public protocol ChatResponseViewDelegate: UIViewController {
    func setIsUploadingFile()
    func layoutIfNeeded()
    func scrollToEnd(animated: Bool)
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
}

/// View container for a chat dialog response. Contains a list of messages (text/images/videos etc.). Optionally contains an avatar image.
open class ChatResponseView: UIView {

    // Chatbot backend instance
    public var backend: ChatBackend!
    
    /// Custom ChatConfig for overriding colors etc.
    public var customConfig: ChatConfig?
    
    /// Horizontal and vertical padding for message views (i.e. chat message with text) –  width = horizontal, height = vertical
    public var messageViewPadding: CGSize = CGSize(width: 15, height: 12)
    /// Corner radius for message views
    public var messageViewCornerRadius: CGFloat = 10
    
    /// Horizontal and vertical padding for action links (width = horizontal, height = vertical)
    public var actionLinkPadding: CGSize = CGSize(width: 12, height: 10)
    /// Corner radius for action links
    public var actionLinkCornerRadius: CGFloat = 5
    
    /// Margin around responses, i.e. margin to the left of the avatar icon
    public var horizontalMargin: CGFloat = 16
    
    /// Size of avatar image
    public var avatarSize: CGFloat = 40
    
    /// Max width of the view a message element can contain
    public var messageMaxWidthMultiplier: CGFloat = 0.65
    
    /// Button for approving GDPR handling ("I need your approval to handle your information. Ok?" -> Yes
    public weak var approveGDPRButton: UIView?
    /// Button for denying GDPR handling ("I need your approval to handle your information. Ok?" -> No
    public weak var denyGDPRButton: UIView?
    
    /// Data source for delivering custom views based on message elements
    public var dataSource: ChatResponseViewDataSource?
    
    /// Our parent view that contains all dialog responses
    public weak var delegate: ChatResponseViewDelegate?
    
    /// Avatar image view
    public weak var avatarImageView: UIImageView!
    
    /// Message stack view. Contains all the elements in the current response view
    public weak var elementStackView: UIStackView!
    
    /// Feedback stack view. Contains feedback thumbs up and down buttons
    public weak var feedbackStackView: UIStackView!
    /// Positive button (thumbs up)
    public weak var thumbsUpButton: UIButton!
    /// Positive button (thumbs down)
    public weak var thumbsDownButton: UIButton!
    
    /// Should we show feedback (thumbs up/down for this message)?
    public var showFeedback: Bool = true
    
    /// The response we configure this view for
    public var response: Response?
    /// The conversation this response is a part of
    public var conversation: ConversationResult?
    
    private let denyButtonBackgroundColor = UIColor(red: 1, green: 0.831372549, blue: 0.8352941176, alpha: 1)
    private let denyButtonTextColor = UIColor(red: 0.55, green: 0.01176470588, blue: 0.01176470588, alpha: 1)
    private let approveButtonBackgroundColor = UIColor(red: 0.8156862745, green: 0.9254901961, blue: 0.8392156863, alpha: 1)
    private let approveButtonTextColor = UIColor(red: 0, green: 0.3137254902, blue: 0, alpha: 1)
    
    private weak var wrapperStackView: UIStackView!
    private weak var wrapperStackViewLeadingConstraint: NSLayoutConstraint!
    private weak var wrapperStackViewTrailingConstraint: NSLayoutConstraint!
    
    private var imageLoadingToken: UUID?
    private var links: [Link] = []
    private var uploadButtons: [ActionLinkView] = []
    private var jsonCardLinks: [GenericCard.Link] = []
    private var waitingViews: [UIView] = []
    
    private var feedbackValue: FeedbackValue?
    
    private var chatMessageWrapperView: RoundedCornersView {
        get {
            let wrapperView = RoundedCornersView()
            wrapperView.translatesAutoresizingMaskIntoConstraints = false
            wrapperView.backgroundColor = UIColor.BoostAI.lightGray
            wrapperView.corners = isClient ? [.topLeft, .bottomRight, .bottomLeft] : [.topRight, .bottomLeft, .bottomRight]
            wrapperView.cornerRadius = messageViewCornerRadius
            
            let backgroundColor: UIColor
            if isClient {
                backgroundColor = customConfig?.chatPanel?.styling?.chatBubbles?.userBackgroundColor ?? backend.config?.chatPanel?.styling?.chatBubbles?.userBackgroundColor ?? ChatConfig.Defaults.Styling.ChatBubbles.userBackgroundColor
            } else {
                backgroundColor = customConfig?.chatPanel?.styling?.chatBubbles?.vaBackgroundColor ?? backend.config?.chatPanel?.styling?.chatBubbles?.vaBackgroundColor ?? ChatConfig.Defaults.Styling.ChatBubbles.vaBackgroundColor
            }
            
            wrapperView.backgroundColor = backgroundColor
            
            return wrapperView
        }
    }
    
    
    /// Is the current response from the client/user?
    open var isClient: Bool = false {
        didSet {
            avatarImageView.isHidden = isClient
            elementStackView.alignment = isClient ? .trailing : .leading
            
            if isClient {
                wrapperStackViewLeadingConstraint.isActive = false
                let leadingConstraint = wrapperStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: horizontalMargin)
                leadingConstraint.isActive = true
                
                wrapperStackViewTrailingConstraint.isActive = false
                let trailingConstraint = trailingAnchor.constraint(equalTo: wrapperStackView.trailingAnchor, constant: horizontalMargin)
                trailingConstraint.isActive = true
                
                wrapperStackViewLeadingConstraint = leadingConstraint
                wrapperStackViewTrailingConstraint = trailingConstraint
            }
        }
    }
    
    public init(backend: ChatBackend, customConfig: ChatConfig? = nil) {
        super.init(frame: .zero)
        
        self.backend = backend
        self.customConfig = customConfig
        
        setupView()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - Message handling
    
    
    /// Add a single element view to the list of element views
    /// - Parameter view: A view that represents a single message element (i.e. a text message or an image)
    public func addElementView(_ view: UIView, animated: Bool) {
        addElementViews([view], animated: animated)
    }
    
    /// Add multiples element view to the list of element views. Will animate each view in with a small delay between each view.
    /// - Parameter views: An array of views that each represents a single message element
    public func addElementViews(_ views: [UIView], animated: Bool) {
        for (index, view) in views.enumerated() {
            
            if animated {
                view.transform = CGAffineTransform(translationX: 25 * (isClient ? 1 : -1), y: 0)
                view.layer.opacity = 0
                
                let pace = customConfig?.chatPanel?.styling?.pace ?? backend.config?.chatPanel?.styling?.pace ?? .normal
                let paceFactor = TimingHelper.calculatePace(pace)
                let staggerDelay = TimingHelper.calculateStaggerDelay(pace: pace, idx: 1)
                let timeUntilReveal = TimingHelper.calcTimeToRead(pace: paceFactor)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + timeUntilReveal * TimeInterval(index)) { [weak self] in
                    guard let self = self else { return }
                    
                    for waitingView in self.waitingViews {
                        waitingView.removeFromSuperview()
                    }
                    
                    self.elementStackView.addArrangedSubview(view)
                    
                    if let stackView = view as? UIStackView {
                        stackView.widthAnchor.constraint(equalTo: self.elementStackView.widthAnchor).isActive = true
                    }
                    
                    let actionLinkView = view as? ActionLinkView
                    let innerLinkView = (view as? UIStackView)?.arrangedSubviews.first as? ActionLinkView
                    if let linkView = actionLinkView ?? innerLinkView {
                        linkView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: self.messageMaxWidthMultiplier).isActive = true
                    }
                    
                    UIView.animate(withDuration: self.transitionLength, delay: 0, options: [], animations: {
                        view.transform = .identity
                        view.layer.opacity = 1
                    }, completion: nil)
                    
                    var totalStaggeredDelay: TimeInterval = 0
                    
                    if let stackView = view as? UIStackView, stackView.axis == .vertical {
                        for (index, view) in stackView.arrangedSubviews.enumerated() {
                            view.transform = CGAffineTransform(translationX: 25 * (self.isClient ? 1 : -1), y: 0)
                            view.layer.opacity = 0
                            
                            let staggerDelay = TimingHelper.calculateStaggerDelay(pace: pace, idx: index)
                            totalStaggeredDelay = totalStaggeredDelay + staggerDelay
                            
                            UIView.animate(withDuration: self.transitionLength, delay: staggerDelay, options: [], animations: {
                                view.transform = .identity
                                view.layer.opacity = 1
                            })
                        }
                    }
                    
                    if index < views.count - 1 {
                        let waitingView = self.createWaitingView()
                        waitingView.transform = self.animationTransform
                        waitingView.layer.opacity = 0
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + staggerDelay) {
                            self.waitingViews.append(waitingView)
                            self.elementStackView.addArrangedSubview(waitingView)
                            
                            UIView.animate(withDuration: self.transitionLength) {
                                waitingView.transform = .identity
                                waitingView.layer.opacity = 1
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                self.delegate?.scrollToEnd(animated: true)
                            }
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.delegate?.scrollToEnd(animated: true)
                    }
                    
                    if index >= views.count - 1 {
                        let hideMessageFeedback = self.customConfig?.chatPanel?.styling?.messageFeedback?.hide ?? self.backend.config?.chatPanel?.styling?.messageFeedback?.hide ?? ChatConfig.Defaults.Styling.MessageFeedback.hide
                        
                        self.feedbackStackView.layer.opacity = 0
                        self.feedbackStackView.isHidden = !self.showFeedback || hideMessageFeedback || self.isClient
                        
                        UIView.animate(withDuration: self.transitionLength, delay: totalStaggeredDelay + staggerDelay) {
                            self.feedbackStackView.layer.opacity = 1
                        }
                    }
                }
            } else {
                elementStackView.addArrangedSubview(view)
                
                if let stackView = view as? UIStackView {
                    stackView.widthAnchor.constraint(equalTo: elementStackView.widthAnchor).isActive = true
                }
                
                let actionLinkView = view as? ActionLinkView
                let innerLinkView = (view as? UIStackView)?.arrangedSubviews.first as? ActionLinkView
                if let linkView = actionLinkView ?? innerLinkView {
                    linkView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: messageMaxWidthMultiplier).isActive = true
                }
                
                let hideMessageFeedback = customConfig?.chatPanel?.styling?.messageFeedback?.hide ?? backend.config?.chatPanel?.styling?.messageFeedback?.hide ?? ChatConfig.Defaults.Styling.MessageFeedback.hide
                
                feedbackStackView.isHidden = !showFeedback || hideMessageFeedback || isClient
                
                if animated {
                    feedbackStackView.layer.opacity = 0
                    UIView.animate(withDuration: transitionLength) {
                        self.feedbackStackView.layer.opacity = 1
                    }
                }
            }
        }
    }
    
    
    /// Configure the current response view with a response from the server (or possibly the client)
    /// - Parameters:
    ///   - response: A response from the API backend
    ///   - sender: Should be our parent, that is the view controller containing this response view
    open func configureWith(response: Response, conversation: ConversationResult? = nil, animateElements: Bool = true, sender: ChatResponseViewDelegate?) {
        delegate = sender
        self.response = response
        self.conversation = conversation
        isClient = response.source == .client
        
        if let avatarShape = backend.config?.chatPanel?.styling?.avatarShape, avatarShape == .rounded {
            avatarImageView.layer.cornerRadius = avatarSize / 2
            avatarImageView.clipsToBounds = true
        }
        
        if let avatarURLString = response.avatarUrl, let avatarURL = URL(string: avatarURLString) {
            let _ = ImageLoader.shared.loadImage(avatarURL) { [weak self] (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        self?.avatarImageView.image = image
                    case .failure(_):
                        break
                    }
                }
            }
        }
        
        var messageViews: [UIView?] = []
        
        for element in response.elements {
            // If we have a data source that gives us a view, append and continue
            if let messageView = dataSource?.messageViewFor(element: element) {
                messageViews.append(messageView)
                continue
            }
            
            switch element.type {
            case .html:
                guard let html = element.payload.html  else { return }
                let view = htmlMessageView(html)
                messageViews.append(view)
            case .text:
                guard let text = element.payload.text else { return }
                let view = textMessageView(text)
                messageViews.append(view)
            case .links:
                guard let links = element.payload.links else { return }
                
                // Action links with function "APPROVE" or "DENY" is a special display case
                // Should show as green/red yes/no buttons side by side
                if let function = links.first?.function, function == .approve || function == .deny {
                    showFeedback = false
                    let view = gdprActionLinksView(links: links)
                    messageViews.append(view)
                } else {
                    // Should we display action links "inline"?
                    if let buttonType = customConfig?.chatPanel?.styling?.buttons?.variant ?? backend.config?.chatPanel?.styling?.buttons?.variant, buttonType == .bullet {
                        messageViews.append(inlineActionLinkView(links: links))
                    } else {
                        let stackView = UIStackView()
                        stackView.translatesAutoresizingMaskIntoConstraints = false
                        stackView.axis = .vertical
                        stackView.spacing = elementStackView.spacing
                        
                        for link in links {
                            if let linkView = actionLinkView(link: link) {
                                stackView.addArrangedSubview(linkView)
                            }
                        }
                        
                        if stackView.arrangedSubviews.count > 0 {
                            messageViews.append(stackView)
                        }
                    }
                }
            case .image:
                guard let url = element.payload.url else { return }
                addImage(url: url)
            case .video:
                guard let url = element.payload.url, let source = element.payload.source else { return }
                
                switch source {
                case "youtube":
                    let view = youTubeVideoView(url: url)
                    messageViews.append(view)
                case "vimeo":
                    let view = vimeoVideoView(url: url)
                    messageViews.append(view)
                case "wistia":
                    let view = wistiaVideoView(url: url)
                    messageViews.append(view)
                default:
                    break
                }
            case .json:
                let view = jsonView(element.payload)
                messageViews.append(view)
                break
            case .unknown:
                break
            }
        }
        
        if let conversation = conversation, let _ = conversation.state.awaitingFiles {
            messageViews.append(fileUploadLinkView(text: "Upload image"))
        }
        
        addElementViews(messageViews.compactMap { $0 }, animated: animateElements)
    }
    
    
    /// Message view for a plain text element
    /// - Parameter text: Plain text
    /// - Returns: A chat bubble view containing the text
    open func textMessageView(_ text: String) -> UIView? {
        return attributedStringView(string: NSAttributedString(string: text), isHTML: false)
    }
    
    /// Message view for a html  element
    /// - Parameter html: A HTML string
    /// - Returns: A chat bubble view containing the html content
    open func htmlMessageView(_ html: String) -> UIView? {
        
        let bodyFont = customConfig?.chatPanel?.styling?.fonts?.bodyFont ?? ChatConfig.Defaults.Styling.Fonts.bodyFont
        let linkTextColor: UIColor
        if isClient {
            linkTextColor = customConfig?.chatPanel?.styling?.chatBubbles?.userTextColor ?? backend.config?.chatPanel?.styling?.chatBubbles?.userTextColor ?? ChatConfig.Defaults.Styling.ChatBubbles.userTextColor
        } else {
            linkTextColor = customConfig?.chatPanel?.styling?.chatBubbles?.vaTextColor ?? backend.config?.chatPanel?.styling?.chatBubbles?.vaTextColor ?? ChatConfig.Defaults.Styling.ChatBubbles.vaTextColor
        }
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: linkTextColor ]
        
        let input = """
            <html>
            <head>
                <style type="text/css">
                    body {
                        font-family: 'Open Sans', -apple-system, sans-serif;
                        font-size: \(bodyFont.pointSize)px;
                        margin: 0;
                        padding: 0;
                    }
        
                    img {
                        max-width: 100%;
                        height: auto;
                    }
        
                    p:last-child {
                        margin-bottom: 0;
                    }
                </style>
            </head>
            <body><div>\(html)</div></body>
            </html>
        """
        
        guard let data = input.data(using: String.Encoding.unicode) else { return nil }

        guard let text = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding : String.Encoding.utf8.rawValue], documentAttributes: nil) else {
            return nil
        }
        
        // Fix ul/ol/list intendation
        let mutableText = text.mutableCopy() as! NSMutableAttributedString
        text.enumerateAttribute(NSAttributedString.Key.paragraphStyle, in: NSRange(location: 0, length: text.length), options: .longestEffectiveRangeNotRequired) { (attribute, range, _) in
            if let paragraphStyle = attribute as? NSParagraphStyle, let textLists = paragraphStyle.value(forKey: "textLists") as? NSArray, textLists.count > 0  {
                
                let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                style.tabStops = [
                    NSTextTab(
                        textAlignment: .left,
                        location: 15,
                        options: [:]
                    )
                ]
                style.defaultTabInterval = 15
                style.firstLineHeadIndent = 0
                style.headIndent = 15
                style.lineSpacing = 0
                style.paragraphSpacing = 10
                style.paragraphSpacingBefore = 0
                
                mutableText.removeAttribute(NSAttributedString.Key.paragraphStyle, range: range)
                mutableText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
            }
        }
        
        text.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: text.length), options: [], using: {(value,range,stop) -> Void in
            if let attachement = value as? NSTextAttachment {
                guard let image = attachement.image(forBounds: attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location) else { return }
                
                let screenSize: CGRect = UIScreen.main.bounds
                let maxMessageWidth = screenSize.width * messageMaxWidthMultiplier - messageViewPadding.width * 2
                
                if image.size.width > maxMessageWidth {
                    if let newImage = resizeImage(image, scale: maxMessageWidth / image.size.width) {
                        let newAttribut = NSTextAttachment()
                        newAttribut.image = newImage
                        mutableText.addAttribute(NSAttributedString.Key.attachment, value: newAttribut, range: range)
                    }
                }
            }
        })
        
        return attributedStringView(string: mutableText, isHTML: true)
    }
    
    private func resizeImage(_ image: UIImage, scale: CGFloat) -> UIImage? {
        let newSize = CGSize(width: image.size.width*scale, height: image.size.height*scale)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContext(newSize)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Helper function for textMessageVew(_:) and htmlMessageView(_:). Wraps an attributed string in a chat bubble.
    /// - Parameter string: An NSAttributedString
    /// - Parameter isHTML: Is the attributed string generated from HTML? (It needs some special care to look correct if yes.)
    /// - Returns: A chat bubble view containing the string
    open func attributedStringView(string: NSAttributedString, isHTML: Bool) -> UIView {
        let textView = UITextView()
        
        textView.delegate = self
        textView.backgroundColor = .none
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.adjustsFontForContentSizeCategory = true
        textView.attributedText = string.trimmedAttributedString()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        
        if !isHTML {
            textView.font = customConfig?.chatPanel?.styling?.fonts?.bodyFont ?? ChatConfig.Defaults.Styling.Fonts.bodyFont
        }
        
        if isClient {
            textView.textColor = customConfig?.chatPanel?.styling?.chatBubbles?.userTextColor ?? backend.config?.chatPanel?.styling?.chatBubbles?.userTextColor ?? ChatConfig.Defaults.Styling.ChatBubbles.userTextColor
        } else {
            textView.textColor = backend.config?.chatPanel?.styling?.chatBubbles?.vaTextColor ?? backend.config?.chatPanel?.styling?.chatBubbles?.vaTextColor ?? ChatConfig.Defaults.Styling.ChatBubbles.vaTextColor
        }
        
        let textViewWrapper = chatMessageWrapperView
        textViewWrapper.addSubview(textView)
        
        let textViewWrapperConstraints = [
            textView.leadingAnchor.constraint(equalTo: textViewWrapper.leadingAnchor, constant: messageViewPadding.width),
            textView.topAnchor.constraint(equalTo: textViewWrapper.topAnchor, constant: messageViewPadding.height),
            textViewWrapper.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: messageViewPadding.width),
            textViewWrapper.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: messageViewPadding.height)
        ]
        
        NSLayoutConstraint.activate(textViewWrapperConstraints)
        
        return textViewWrapper
    }
    
    
    /// Message view for an action link
    /// - Parameter link: A Link object containing information about the link
    /// - Returns: An action link view
    open func actionLinkView(link: Link) -> UIView? {
        let linkView = actionLinkView(text: link.text, type: link.type)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapActionLink(sender:)))
        tapRecognizer.numberOfTouchesRequired = 1
        linkView?.tag = links.count
        links.append(link)
        linkView?.addGestureRecognizer(tapRecognizer)
        
        return linkView
    }
    
    open func inlineActionLinkView(links: [Link]) -> UIView? {
        var html = "<ul>"
        
        for link in links {
            html += "<li><a href=\"boostai://\(self.links.count)\">\(link.text)</a></li>"
            self.links.append(link)
        }
        
        html += "</ul>"
        
        return htmlMessageView(html)
    }
    
    /// Message view for an action link
    /// - Parameter text: The text of the acction link
    /// - Returns: An action link view
    open func fileUploadLinkView(text: String) -> UIView? {
        let linkView = actionLinkView(text: text, type: .action_link, isUploadButton: true)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapUploadFileLink(_:)))
        tapRecognizer.numberOfTouchesRequired = 1
        linkView?.addGestureRecognizer(tapRecognizer)
        
        return linkView
    }
    
    /// - Parameter text: The text of the action link
    /// - Parameter type: Link type
    /// - Returns: An action link view (you must handle tapping yourself by adding a tap gesture recognizer to it)
    open func actionLinkView(text: String, type: LinkType, isUploadButton: Bool = false) -> UIView? {
        let isMultiline = customConfig?.chatPanel?.styling?.buttons?.multiline ?? backend.config?.chatPanel?.styling?.buttons?.multiline ?? ChatConfig.Defaults.Styling.Buttons.multiline
        
        let linkView = ActionLinkView()
        linkView.translatesAutoresizingMaskIntoConstraints = false
        linkView.corners = .allCorners
        linkView.cornerRadius = actionLinkCornerRadius
        linkView.backgroundColor = UIColor.BoostAI.purple
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = customConfig?.chatPanel?.styling?.fonts?.bodyFont ?? ChatConfig.Defaults.Styling.Fonts.bodyFont
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.numberOfLines = isMultiline ? 0 : 1
        
        var iconName: String
        var iconWidth: CGFloat
            
        switch type {
        case .external_link:
            iconName = "external-link-icon"
            iconWidth = 14
        case .action_link:
            iconName = "arrow-right"
            iconWidth = 8
        }
        
        if isUploadButton {
            iconName = "upload-files"
            iconWidth = 20
            
            uploadButtons.append(linkView)
        }
        
        let iconImage = UIImage(named: iconName, in: Bundle(for: ChatResponseView.self), compatibleWith: nil)
        let iconImageView = UIImageView(image: iconImage)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: iconWidth).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        iconImageView.tintColor = .white
                
        let stackView = UIStackView(arrangedSubviews: [label, iconImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        
        linkView.addSubview(stackView)
        
        let constraints = [
            stackView.topAnchor.constraint(equalTo: linkView.topAnchor, constant: actionLinkPadding.height),
            stackView.leadingAnchor.constraint(equalTo: linkView.leadingAnchor, constant: actionLinkPadding.width),
            linkView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: actionLinkPadding.width),
            linkView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: actionLinkPadding.height)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        linkView.isAccessibilityElement = true
        linkView.accessibilityValue = text
        linkView.accessibilityTraits = .button
        
        let buttonTextColor = customConfig?.chatPanel?.styling?.buttons?.textColor ?? backend.config?.chatPanel?.styling?.buttons?.textColor ?? ChatConfig.Defaults.Styling.Buttons.textColor
        label.textColor = buttonTextColor
        iconImageView.tintColor = buttonTextColor
        linkView.backgroundColor = customConfig?.chatPanel?.styling?.buttons?.backgroundColor ?? backend.config?.chatPanel?.styling?.buttons?.backgroundColor ?? ChatConfig.Defaults.Styling.Buttons.backgroundColor
        
        return linkView
    }
    
    
    /// If the agent needs approval to handle the information the user provides, we should display Yes/No buttons  for approving/denying this
    /// - Parameter links: An array of Link's containing an "APPROVE" function and a "DENY" function
    /// - Returns: A stack view with a red and a green button side by side
    open func gdprActionLinksView(links: [Link]) -> UIView? {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        for link in links.reversed() {
            let linkView = RoundedCornersView()
            linkView.translatesAutoresizingMaskIntoConstraints = false
            linkView.corners = .allCorners
            linkView.cornerRadius = actionLinkCornerRadius
            linkView.backgroundColor = link.function == .deny ? denyButtonBackgroundColor : approveButtonBackgroundColor
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = link.text
            label.textAlignment = .center
            label.font = customConfig?.chatPanel?.styling?.fonts?.footnoteFont ?? ChatConfig.Defaults.Styling.Fonts.footnoteFont
            label.adjustsFontForContentSizeCategory = true
            label.textColor = link.function == .deny ? denyButtonTextColor : approveButtonTextColor
            linkView.addSubview(label)
            
            let constraints = [
                label.topAnchor.constraint(equalTo: linkView.topAnchor, constant: 7),
                label.leadingAnchor.constraint(equalTo: linkView.leadingAnchor, constant: 10),
                linkView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
                linkView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 7)
            ]
            
            NSLayoutConstraint.activate(constraints)
            
            stackView.addArrangedSubview(linkView)
            
            linkView.isAccessibilityElement = true
            linkView.accessibilityLabel = link.text
            linkView.accessibilityTraits = .button
            
            if let function = link.function {
                switch function  {
                case .approve:
                    approveGDPRButton = linkView
                case .deny:
                    denyGDPRButton = linkView
                }
            }
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGDPRLink(_:)))
            tapRecognizer.numberOfTouchesRequired = 1
            linkView.tag = self.links.count
            self.links.append(link)
            linkView.addGestureRecognizer(tapRecognizer)
        }
        
        return stackView
    }
    
    /// Add a message view that displays an image at a given URL
    /// - Parameter url: Image URL (presumed to be hosted on the internet, not in app)
    open func addImage(url: String) {
        guard let imageURL = URL(string: url) else { return }
        
        configureAsWaitingForRemoteResponse()
        
        imageLoadingToken = ImageLoader.shared.loadImage(imageURL) { [weak self] result in
            do {
                let image = try result.get()
                
                DispatchQueue.main.async {
                    self?.addImageView(image: image)
                }
            } catch {
                print(error)
            }
        }
    }
    
    /// Add an message view from an image (helper function for addImage(url:), but can be used stand alone)
    /// - Parameter url: Image URL (presumed to be hosted on the internet, not in app)
    open func addImageView(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let wrapperView = self.chatMessageWrapperView
        wrapperView.addSubview(imageView)
        
        let constraints = [
            imageView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ]
        
        let aspectRatio = image.size.height / image.size.width
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: aspectRatio).isActive = true
        
        NSLayoutConstraint.activate(constraints)
        
        self.addElementView(wrapperView, animated: true)
        
        self.delegate?.layoutIfNeeded()
        self.delegate?.scrollToEnd(animated: true)
        
        for view in waitingViews {
            view.removeFromSuperview()
        }
        
        waitingViews = []
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFullScreenImage(sender:)))
        tapRecognizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func showFullScreenImage(sender: UIGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView, let image = imageView.image else { return }
        
        let lightboxVC = ImageLightboxViewController(image: image)
        lightboxVC.modalPresentationStyle = .fullScreen
        lightboxVC.modalTransitionStyle = .crossDissolve
        delegate?.present(lightboxVC, animated: true)
    }
    
    /// Message view for a YouTube video
    /// - Parameter url: A URL for a single YouTube video, i.e. `https://www.youtube.com/watch?v=gcugRVtkBtU`
    /// - Returns: A view wrapping a YouTube embedded player
    open func youTubeVideoView(url: String) -> UIView? {
        guard let id = extractYouTubeID(url: url) else { return nil }
        let embedURL = "https://www.youtube.com/embed/\(id)"
        
        return videoEmbedView(url: embedURL)
    }
    
    /// Message view for a Vimeo video
    /// - Parameter url: A URL for a single Vimeo video, i.e. `https://vimeo.com/316511760`
    /// - Returns: A view wrapping a Vimeo embedded player
    open func vimeoVideoView(url: String) -> UIView? {
        guard let id = extractVimeoID(url: url) else { return nil }
        let embedURL = "https://player.vimeo.com/video/\(id)?title=0&byline=0&styling=portrait"
        
        return videoEmbedView(url: embedURL)
    }
    
    /// Message view for a Wistia video
    /// - Parameter url: A URL for a single Wistia video, i.e. `https://wistia.com/lbo2kwzc81`
    /// - Returns: A view wrapping a Wistia embedded player
    open func wistiaVideoView(url: String) -> UIView? {
        guard let id = extractWistiaURL(url: url) else { return nil }
        let embedURL = "https://fast.wistia.net/embed/iframe/\(id)?seo=false&videoFoam=true"
        
        return videoEmbedView(url: embedURL)
    }
    
    
    /// Message view wrapper for an embed URL. Helper function for `youTubeViewEmbed(url:)` etc.
    /// - Parameter url: The full embed URL
    /// - Returns: A message view containing the embed URL in an iframe inside a WKWebView
    open func videoEmbedView(url: String) -> UIView? {
        let html = """
                <!doctype html>
                <html>
                <head>
                    <style>
                        html,
                        body {
                            overflow: hidden;
                        }
                        
                        body {
                            margin: 0;
                            padding: 0;
                            width: 100vw;
                            height: 100vh;
                        }
            
                        iframe {
                            margin: 0;
                            padding: 0;
                            width: 100%;
                            height: 100%;
                            overflow: hidden;
                        }
                    </style>
                </head>
                <body>
                    <iframe src="\(url)" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" scrolling="no" playsinline webkitAllowFullScreen mozallowfullscreen allowfullscreen></iframe>
                </body>
                </html>
        """
            
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        
        webView.loadHTMLString(html, baseURL: nil)
        
        let wrapperView = self.chatMessageWrapperView
        wrapperView.addSubview(webView)
        
        let constraints = [
            webView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 10),
            webView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 10),
            wrapperView.trailingAnchor.constraint(equalTo: webView.trailingAnchor, constant: 10),
            wrapperView.bottomAnchor.constraint(equalTo: webView.bottomAnchor, constant: 10)
        ]
        
        let aspectRatio: CGFloat = 9/16
        webView.heightAnchor.constraint(equalTo: webView.widthAnchor, multiplier: aspectRatio).isActive = true
        
        let screenSize: CGRect = UIScreen.main.bounds
        let maxMessageWidth = screenSize.width * messageMaxWidthMultiplier
        wrapperView.widthAnchor.constraint(equalToConstant: maxMessageWidth).isActive = true
        
        NSLayoutConstraint.activate(constraints)
        
        return wrapperView
    }
    
    private func extractYouTubeID(url: String) -> String? {
        let pattern = #"(.*?)(^|\/|v=)([a-z0-9_-]{11})(.*)?"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
            let match = regex.firstMatch(in: url, options: [], range: NSRange(location: 0, length: url.count)) {
            if match.numberOfRanges >= 4 {
                let range = match.range(at: 3)
                
                if let swiftRange = Range(range, in: url) {
                    return String(url[swiftRange])
                }
            }
        }
        
        print("YouTube ID not found")
        return nil
    }
    
    private func extractVimeoID(url: String) -> String? {
        let pattern = #"(http|https)?:\/\/(www\.|player\.)?vimeo\.com\/(?:channels\/(?:\w+\/)?|groups\/([^\/]*)\/videos\/|video\/|)(\d+)(?:|\/\?)"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
            let match = regex.firstMatch(in: url, options: [], range: NSRange(location: 0, length: url.count)) {
            if match.numberOfRanges >= 5 {
                let range = match.range(at: 4)
                
                if let swiftRange = Range(range, in: url) {
                    return String(url[swiftRange])
                }
            }
        }
        
        print("Vimeo ID not found")
        return nil
    }
    
    private func extractWistiaURL(url: String) -> String? {
        let pattern = #"(http|https)?:?\/\/(www)?wistia.com\/([a-z0-9]+)/?"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
            let match = regex.firstMatch(in: url, options: [], range: NSRange(location: 0, length: url.count)) {
            if match.numberOfRanges >= 4 {
                let range = match.range(at: 3)
                
                if let swiftRange = Range(range, in: url) {
                    return String(url[swiftRange])
                }
            }
        }
        
        print("Vimeo ID not found")
        return nil
    }
    
    open func jsonView(_ payload: Payload) -> UIView? {
        let wrapperView = self.chatMessageWrapperView
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = customConfig?.chatPanel?.styling?.fonts?.headlineFont ?? ChatConfig.Defaults.Styling.Fonts.headlineFont
        titleLabel.numberOfLines = 0
        titleLabel.isHidden = true
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = customConfig?.chatPanel?.styling?.fonts?.bodyFont ?? ChatConfig.Defaults.Styling.Fonts.bodyFont
        textLabel.textColor = .darkText
        textLabel.numberOfLines = 0
        textLabel.isHidden = true
        
        let linkLabel = UILabel()
        linkLabel.translatesAutoresizingMaskIntoConstraints = false
        linkLabel.font = customConfig?.chatPanel?.styling?.fonts?.bodyFont ?? ChatConfig.Defaults.Styling.Fonts.bodyFont
        linkLabel.textColor = .darkGray
        linkLabel.numberOfLines = 0
        linkLabel.isHidden = true
        linkLabel.isUserInteractionEnabled = true
        
        let linkTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(genericCardLinkTapped(_:)))
        linkTapGestureRecognizer.numberOfTapsRequired = 1
        linkLabel.addGestureRecognizer(linkTapGestureRecognizer)
                
        let contentStackView = UIStackView(arrangedSubviews: [titleLabel, textLabel, linkLabel])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 10
        
        let stackView = UIStackView(arrangedSubviews: [imageView, contentStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 15
        stackView.alignment = .top
        
        wrapperView.addSubview(stackView)
        
        let constraints = [
            stackView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 15),
            stackView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 15),
            wrapperView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 15),
            wrapperView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 15)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        if let json = payload.json {
            let decoder = JSONDecoder()
            do {
                let content = try decoder.decode(GenericCard.self, from: json)
                
                if (content.body == nil && content.heading == nil) {
                    return nil
                }
                
                textLabel.text = content.body?.text
                textLabel.isHidden = textLabel.text?.count == 0
                
                titleLabel.text = content.heading?.text
                titleLabel.isHidden = titleLabel.text?.count == 0
                
                if let link = content.link {
                    let text = content.link?.text ?? link.url
                    
                    let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
                    let attributedString = NSAttributedString(string: text, attributes: underlineAttribute)
                    
                    linkLabel.attributedText = attributedString.trimmedAttributedString()
                    linkLabel.isHidden = false
                    
                    linkLabel.tag = jsonCardLinks.count
                    jsonCardLinks.append(link)
                }
                
                if let imagePosition = content.image?.position {
                    switch (imagePosition) {
                    case "right":
                        stackView.semanticContentAttribute = .forceRightToLeft
                    case "top":
                        stackView.axis = .vertical
                        stackView.alignment = .fill
                    default:
                        break
                    }
                }
                
                titleLabel.textColor = customConfig?.chatPanel?.styling?.primaryColor ?? backend.config?.chatPanel?.styling?.primaryColor ?? ChatConfig.Defaults.Styling.primaryColor
                
                if let imageUrlString = content.image?.url, let imageUrl = URL(string: imageUrlString) {
                    let _ = ImageLoader.shared.loadImage(imageUrl) { (result) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let image):
                                imageView.image = image
                                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: image.size.height / image.size.width).isActive = true
                                imageView.isHidden = false
                            case .failure(_):
                                break
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
        
        let screenSize: CGRect = UIScreen.main.bounds
        let maxMessageWidth = screenSize.width * messageMaxWidthMultiplier
        wrapperView.widthAnchor.constraint(equalToConstant: maxMessageWidth).isActive = true
        
        return wrapperView
    }
    
    @objc open func genericCardLinkTapped(_ sender: UIGestureRecognizer) {
        let index = sender.view?.tag ?? 0
        let link = jsonCardLinks[index]
        
        guard let url = URL(string: link.url) else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        delegate?.present(safariViewController, animated: true, completion: nil)
        BoostUIEvents.shared.publishEvent(event: BoostUIEvents.Event.externalLinkClicked, detail: url.absoluteString)
    }
    
    open func removeUploadButtons() {
        for button in uploadButtons {
            button.removeFromSuperview()
        }
        
        uploadButtons = []
    }
    
    // MARK: - View setup
    
    /// Setting up the response view. Override for custom implementation.
    open func setupView() {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        let imageViewConstraints = [
            imageView.widthAnchor.constraint(equalToConstant: avatarSize),
            imageView.heightAnchor.constraint(equalToConstant: avatarSize)
        ]
        
        let elementStackView = UIStackView()
        elementStackView.translatesAutoresizingMaskIntoConstraints = false
        elementStackView.axis = .vertical
        elementStackView.spacing = 10
        elementStackView.alignment = isClient ? .trailing : .leading
        
        let messageFeedbackOutlineColor = customConfig?.chatPanel?.styling?.messageFeedback?.outlineColor ?? backend.config?.chatPanel?.styling?.messageFeedback?.outlineColor ?? UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        
        let thumbsUpIcon = UIImage(named: "thumbs-up", in: Bundle(for: ChatResponseView.self), compatibleWith: nil)
        let thumbsUpButton = UIButton()
        thumbsUpButton.translatesAutoresizingMaskIntoConstraints = false
        thumbsUpButton.tintColor = messageFeedbackOutlineColor
        thumbsUpButton.setImage(thumbsUpIcon, for: .normal)
        thumbsUpButton.addTarget(self, action: #selector(userGavePositiveFeedback(_:)), for: .touchUpInside)
        thumbsUpButton.transform = CGAffineTransform(translationX: 0, y: -2)
        
        let thumbsDownIcon = UIImage(named: "thumbs-down", in: Bundle(for: ChatResponseView.self), compatibleWith: nil)
        let thumbsDownButton = UIButton()
        thumbsDownButton.translatesAutoresizingMaskIntoConstraints = false
        thumbsDownButton.tintColor = messageFeedbackOutlineColor
        thumbsDownButton.setImage(thumbsDownIcon, for: .normal)
        thumbsDownButton.addTarget(self, action: #selector(userGaveNegativeFeedback(_:)), for: .touchUpInside)
        thumbsDownButton.transform = CGAffineTransform(translationX: 0, y: 2)
        
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let feedbackStackView = UIStackView(arrangedSubviews: [spacerView, thumbsUpButton, thumbsDownButton])
        feedbackStackView.translatesAutoresizingMaskIntoConstraints = false
        feedbackStackView.axis = .horizontal
        feedbackStackView.spacing = 8
        feedbackStackView.alignment = .trailing
        feedbackStackView.isHidden = true
        
        let elementAndFeedbackStackView = UIStackView(arrangedSubviews: [elementStackView, feedbackStackView])
        elementAndFeedbackStackView.translatesAutoresizingMaskIntoConstraints = false
        elementAndFeedbackStackView.axis = .vertical
        elementAndFeedbackStackView.spacing = 10
        
        let wrapperStackView = UIStackView(arrangedSubviews: [imageView, elementAndFeedbackStackView])
        wrapperStackView.translatesAutoresizingMaskIntoConstraints = false
        wrapperStackView.spacing = 10
        wrapperStackView.alignment = .top
        
        addSubview(wrapperStackView)
        
        let wrapperStackViewConstraints = [
            wrapperStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            bottomAnchor.constraint(equalTo: wrapperStackView.bottomAnchor, constant: 0),
            elementAndFeedbackStackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: messageMaxWidthMultiplier)
        ]
        
        let leadingConstraint = wrapperStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalMargin)
        leadingConstraint.isActive = true
        
        let trailingConstraint = trailingAnchor.constraint(greaterThanOrEqualTo: wrapperStackView.trailingAnchor, constant: horizontalMargin)
        trailingConstraint.isActive = true
        
        NSLayoutConstraint.activate(imageViewConstraints)
        NSLayoutConstraint.activate(wrapperStackViewConstraints)
        
        avatarImageView = imageView
        self.elementStackView = elementStackView
        self.feedbackStackView = feedbackStackView
        self.wrapperStackView = wrapperStackView
        self.wrapperStackViewLeadingConstraint = leadingConstraint
        self.wrapperStackViewTrailingConstraint = trailingConstraint
        self.thumbsUpButton = thumbsUpButton
        self.thumbsDownButton = thumbsDownButton
    }
    
    /// Configure the view as waiting for agent response. Shows three dots indicating agent typing/thinking
    open func configureAsWaitingForRemoteResponse() {
        isClient = false
        
        if let avatarShape = backend.config?.chatPanel?.styling?.avatarShape, avatarShape == .rounded {
            avatarImageView.layer.cornerRadius = avatarSize / 2
            avatarImageView.clipsToBounds = true
        }
        
        let waitingView = createWaitingView()
        
        waitingViews.append(waitingView)
        elementStackView.addArrangedSubview(waitingView)
    }
    
    open func createWaitingView() -> UIView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 5
        
        let circleSize: CGFloat = 8
        let animationDuration: TimeInterval = 0.6
        
        for i in 0..<3 {
            let circle = UIView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.layer.cornerRadius = circleSize / 2
            circle.layer.opacity = 0.5
            
            let typingDotColor = customConfig?.chatPanel?.styling?.chatBubbles?.typingDotColor ?? backend.config?.chatPanel?.styling?.chatBubbles?.typingDotColor ?? customConfig?.chatPanel?.styling?.chatBubbles?.vaTextColor ?? backend.config?.chatPanel?.styling?.chatBubbles?.vaTextColor ?? ChatConfig.Defaults.Styling.ChatBubbles.vaTextColor
            
            circle.backgroundColor = typingDotColor
            circle.widthAnchor.constraint(equalToConstant: circleSize).isActive = true
            circle.heightAnchor.constraint(equalTo: circle.widthAnchor).isActive = true
            
            let anim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
            anim.beginTime = CACurrentMediaTime() + animationDuration / 3 * Double(i)
            anim.fromValue = 0.5
            anim.toValue = 0.2
            anim.duration = animationDuration
            anim.repeatCount = .infinity
            anim.autoreverses = true
            
            circle.layer.add(anim, forKey: nil)
            
            stackView.addArrangedSubview(circle)
        }
        
        let typingBackgroundColor = customConfig?.chatPanel?.styling?.chatBubbles?.typingBackgroundColor ?? backend.config?.chatPanel?.styling?.chatBubbles?.typingBackgroundColor ?? customConfig?.chatPanel?.styling?.chatBubbles?.vaBackgroundColor ?? backend.config?.chatPanel?.styling?.chatBubbles?.vaBackgroundColor ?? ChatConfig.Defaults.Styling.ChatBubbles.vaBackgroundColor
        
        let wrapperView = chatMessageWrapperView
        wrapperView.backgroundColor = typingBackgroundColor
        wrapperView.addSubview(stackView)
        
        let constraints = [
            stackView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: messageViewPadding.width),
            stackView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: messageViewPadding.height),
            wrapperView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: messageViewPadding.width),
            wrapperView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: messageViewPadding.height),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        return wrapperView
    }
    
    private var animationTransform: CGAffineTransform {
        get {
            return CGAffineTransform(translationX: 25 * (isClient ? 1 : -1), y: 0)
        }
    }
    
    private let transitionLength: TimeInterval = 0.25
    
    // MARK: - Actions
    
    /// Handle taps on action links
    @objc open func didTapActionLink(sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let link = links[view.tag]
        
        didTapActionLink(link)
    }
    
    open func didTapActionLink(_ link: Link) {
        switch link.type {
        case .action_link:
            backend.actionButton(id: link.id)
            BoostUIEvents.shared.publishEvent(event: BoostUIEvents.Event.actionLinkClicked, detail: link.id)
            
            let showLinkClickAsChatBubble = customConfig?.chatPanel?.settings?.showLinkClickAsChatBubble ?? backend.config?.chatPanel?.settings?.showLinkClickAsChatBubble ?? ChatConfig.Defaults.Settings.showLinkClickAsChatBubble

            if (showLinkClickAsChatBubble) {
                backend.userActionMessage(link.text)
            }
        case .external_link:
            guard let urlString = link.url, let url = URL(string: urlString) else { return }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
            // Notify backend about URL button click
            backend.urlButton(id: link.id)
            BoostUIEvents.shared.publishEvent(event: BoostUIEvents.Event.externalLinkClicked, detail: urlString)
        }
    }
    
    @objc open func didTapUploadFileLink(_ sender: UITapGestureRecognizer) {
        let alertController = UIAlertController()
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Upload image", comment: ""), style: .default, handler: { [weak self] (_) in
            let picker = UIImagePickerController()
            picker.delegate = self
            
            self?.delegate?.present(picker, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Upload file", comment: ""), style: .default, handler: { [weak self] (_) in
            let picker = UIDocumentPickerViewController(documentTypes: ["public.image", "public.text", "public.content"], in: .open)
            picker.delegate = self
            picker.allowsMultipleSelection = (self?.conversation?.state.awaitingFiles?.maxNumberOfFiles ?? 1) > 1
            
            self?.delegate?.present(picker, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        delegate?.present(alertController, animated: true, completion: nil)
    }
    
    /// Handle taps on GDPR approval/denial action links
    @objc func didTapGDPRLink(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let link = links[view.tag]
        
        backend.actionButton(id: link.id)
        BoostUIEvents.shared.publishEvent(event: BoostUIEvents.Event.actionLinkClicked, detail: link.id)
        
        if let function = link.function {
            switch function {
            case .approve:
                approveGDPRButton?.layer.opacity = 1
                denyGDPRButton?.layer.opacity = 0.25
            case .deny:
                denyGDPRButton?.layer.opacity = 1
                approveGDPRButton?.layer.opacity = 0.25
            }
        }
    }
    
    @objc func userGavePositiveFeedback(_ sender: UIButton) {
        setFeedbackValue(.positive, sender: sender)
        
    }
    
    @objc func userGaveNegativeFeedback(_ sender: UIButton) {
        setFeedbackValue(.negative, sender: sender)
    }
    
    private func setFeedbackValue(_ feedbackValue: FeedbackValue, sender: UIButton) {
        guard let id = response?.id else { return }
        
        let messageFeedbackOutlineColor = customConfig?.chatPanel?.styling?.messageFeedback?.outlineColor ?? backend.config?.chatPanel?.styling?.messageFeedback?.outlineColor ?? UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let messageFeedbackSelectedColor = customConfig?.chatPanel?.styling?.messageFeedback?.selectedColor ?? backend.config?.chatPanel?.styling?.messageFeedback?.selectedColor ?? messageFeedbackOutlineColor
        
        // If we get the same value that already is set, the user has i.e. clicked on a positive/negative button to "unmark" it as positive/negative
        // => reset visual state and send removePositive/removeNegative message to backend
        if let currentValue = self.feedbackValue, currentValue == feedbackValue {
            switch feedbackValue {
            case .positive:
                sender.setImage(UIImage(named: "thumbs-up", in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
                sender.tintColor = messageFeedbackOutlineColor
                backend.feedback(id: id, value: .removePositive)
            case .negative:
                sender.setImage(UIImage(named: "thumbs-down", in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
                sender.tintColor = messageFeedbackOutlineColor
                backend.feedback(id: id, value: .removeNegative)
            default:
                break
            }
            
            // Reset vertical positions
            UIView.animate(withDuration: 0.2) {
                self.thumbsUpButton.transform = CGAffineTransform(translationX: 0, y: -2)
                self.thumbsDownButton.transform = CGAffineTransform(translationX: 0, y: 2)
            }
            
            self.feedbackValue = nil
            return
        }
        
        // The icons for "filled"/active for current button and "unfilled"/default for sibling
        switch feedbackValue {
        case .positive:
            thumbsUpButton.setImage(UIImage(named: "thumbs-up-filled", in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
            thumbsUpButton.tintColor = messageFeedbackSelectedColor
            thumbsDownButton.setImage(UIImage(named: "thumbs-down", in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
            thumbsDownButton.tintColor = messageFeedbackOutlineColor
            
            // Move selected icon up vertically
            UIView.animate(withDuration: 0.2) {
                self.thumbsUpButton.transform = CGAffineTransform(translationX: 0, y: -4)
                self.thumbsDownButton.transform = CGAffineTransform(translationX: 0, y: 2)
            }
        case .negative:
            thumbsUpButton.setImage(UIImage(named: "thumbs-up", in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
            thumbsUpButton.tintColor = messageFeedbackOutlineColor
            thumbsDownButton.setImage(UIImage(named: "thumbs-down-filled", in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
            thumbsDownButton.tintColor = messageFeedbackSelectedColor
            
            // Move selected icon up vertically
            UIView.animate(withDuration: 0.2) {
                self.thumbsUpButton.transform = CGAffineTransform(translationX: 0, y: -2)
                self.thumbsDownButton.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        default:
            thumbsUpButton.setImage(UIImage(named: "thumbs-up", in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
            thumbsUpButton.tintColor = messageFeedbackOutlineColor
            thumbsDownButton.setImage(UIImage(named: "thumbs-down", in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
            thumbsDownButton.tintColor = messageFeedbackOutlineColor
            
            // Reset thumb button position
            UIView.animate(withDuration: 0.2) {
                self.thumbsUpButton.transform = CGAffineTransform(translationX: 0, y: -2)
                self.thumbsDownButton.transform = CGAffineTransform(translationX: 0, y: 2)
            }
        }
        
        if let id = response?.id {
            backend.feedback(id: id, value: feedbackValue)
            
            // Publish event
            switch feedbackValue {
            case .positive:
                BoostUIEvents.shared.publishEvent(event: BoostUIEvents.Event.positiveMessageFeedbackGiven, detail: nil)
            case .negative:
                BoostUIEvents.shared.publishEvent(event: BoostUIEvents.Event.negativeMessageFeedbackGiven, detail: nil)
            default:
                break
            }
        }
        
        self.feedbackValue = feedbackValue
    }
}

extension ChatResponseView: WKNavigationDelegate {
    
    /// Open a SafariViewController for links clicked inside video embeds (which are contained in a WKWebView)
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let supportedSchemes = ["http", "https"]

        guard navigationAction.navigationType == .linkActivated,
            let url = navigationAction.request.url,
            let scheme = url.scheme,
            supportedSchemes.contains(scheme)
        else {
            decisionHandler(.allow)
            return
        }

        guard let delegate = delegate else { return }
        
        let controller = SFSafariViewController(url: url)
        delegate.present(controller, animated: true, completion: nil)
        BoostUIEvents.shared.publishEvent(event: BoostUIEvents.Event.externalLinkClicked, detail: url.absoluteString)
        
        decisionHandler(.cancel)
    }
}

extension ChatResponseView: UINavigationControllerDelegate {
    
}

extension ChatResponseView: UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageURL = info[.imageURL] as? URL {
            delegate?.setIsUploadingFile()
            backend.uploadFilesToAPI(at: [imageURL])
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ChatResponseView: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        delegate?.setIsUploadingFile()
        backend.uploadFilesToAPI(at: urls)
    }
}

extension ChatResponseView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let scheme = URL.scheme, scheme == "boostai", let host = URL.host, let linkIndex = Int(host) {
            let link = links[linkIndex]
            didTapActionLink(link)
            return false
        }
        
        BoostUIEvents.shared.publishEvent(event: BoostUIEvents.Event.externalLinkClicked, detail: URL.absoluteString)
        return true
        
    }
}
