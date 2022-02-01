//
//  ConversationFeedbackViewController.swift
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

import UIKit

public protocol ConversationFeedbackDelegate {
    /// Hide the feedback view without closing the conversation
    func hideFeedback()
    
    /// Close the conversation (and hide chat view / reset conversation depending of full screen / non full screen mode)
    func closeConversation()
}

open class ConversationFeedbackViewController: UIViewController {
    
    /// Chatbot backend instance
    open var backend: ChatBackend!
    
    /// Menu delegate (normally the parent view controller)
    open var delegate: ConversationFeedbackDelegate?
    
    /// Custom ChatConfig for overriding colors etc.
    public var customConfig: ChatConfig?
    
    /// Horisontal padding around the feedback elements
    open var horizontalPadding: CGFloat = 20
    
    /// The outer wrapping stack view containing all of the sub elements
    open var feedbackStackView: UIStackView!
    
    /// The stack view containing user input elements (text view and submit buttonm)
    open var inputStackView: UIStackView!
    
    /// Input text view for user feedback
    open var inputTextView: UITextView!
    
    /// Input placeholder
    open var textViewPlaceholder: UILabel!
    
    /// The stack view containing response success message (in full screen mode)
    open var responseStackView: UIStackView!
    
    /// Close button in the response stack view
    open var closeButton: UIButton!
    
    /// Message shown when the user has given a feedback in full screen mode
    open var feedbackSuccessMessage: String = NSLocalizedString("Thanks for the feedback.\nWe sincerely appreciate your insight, it helps us build a better customer experience.", comment: "")
    
    /// The current feedback value
    open var feedbackValue: FeedbackValue?
    
    /// The possible states the feedback view controller can exist in (for non full screen mode, the view is hidden after successful text prompt – complete state is skipped)
    public enum FeedbackState {
        case initial
        case promptForText
        case complete
    }
    
    /// Current feedback view state
    open var feedbackState: FeedbackState = .initial {
        didSet {
            updateState()
        }
    }
    
    public init(backend: ChatBackend, customConfig: ChatConfig? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.backend = backend
        self.customConfig = customConfig
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    public func setupView() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = customConfig?.chatPanel?.styling?.fonts?.menuItemFont ?? ChatConfig.Defaults.Styling.Fonts.menuItemFont
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let thumbIconSize: CGFloat = 50
        
        let thumbsUpIcon = UIImage(named: "thumbs-up", in: Bundle(for: ConversationFeedbackViewController.self), compatibleWith: nil)
        let thumbsUpButton = UIButton()
        thumbsUpButton.translatesAutoresizingMaskIntoConstraints = false
        thumbsUpButton.tintColor = .white
        thumbsUpButton.setImage(thumbsUpIcon, for: .normal)
        thumbsUpButton.addTarget(self, action: #selector(userGavePositiveFeedback(_:)), for: .touchUpInside)
        thumbsUpButton.heightAnchor.constraint(equalToConstant: thumbIconSize).isActive = true
        thumbsUpButton.widthAnchor.constraint(equalToConstant: thumbIconSize).isActive = true
        thumbsUpButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        thumbsUpButton.contentHorizontalAlignment = .fill
        thumbsUpButton.contentVerticalAlignment = .fill
        
        let thumbsDownIcon = UIImage(named: "thumbs-down", in: Bundle(for: ConversationFeedbackViewController.self), compatibleWith: nil)
        let thumbsDownButton = UIButton()
        thumbsDownButton.translatesAutoresizingMaskIntoConstraints = false
        thumbsDownButton.tintColor = .white
        thumbsDownButton.setImage(thumbsDownIcon, for: .normal)
        thumbsDownButton.addTarget(self, action: #selector(userGaveNegativeFeedback(_:)), for: .touchUpInside)
        thumbsDownButton.transform = CGAffineTransform(translationX: 0, y: 15)
        thumbsDownButton.heightAnchor.constraint(equalToConstant: thumbIconSize).isActive = true
        thumbsDownButton.widthAnchor.constraint(equalToConstant: thumbIconSize).isActive = true
        thumbsDownButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        thumbsDownButton.contentHorizontalAlignment = .fill
        thumbsDownButton.contentVerticalAlignment = .fill
        
        let thumbsStackView = UIStackView(arrangedSubviews: [thumbsUpButton, thumbsDownButton])
        thumbsStackView.translatesAutoresizingMaskIntoConstraints = false
        thumbsStackView.axis = .horizontal
        thumbsStackView.spacing = 50
        thumbsStackView.alignment = .center
        
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.backgroundColor = .white
        closeButton.setTitleColor(.darkText, for: .normal)
        closeButton.layer.cornerRadius = 27
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 50, bottom: 15, right: 50)
        closeButton.titleLabel?.font = customConfig?.chatPanel?.styling?.fonts?.menuItemFont ?? ChatConfig.Defaults.Styling.Fonts.menuItemFont
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        
        let feedbackStackView = UIStackView(arrangedSubviews: [thumbsStackView, closeButton])
        feedbackStackView.translatesAutoresizingMaskIntoConstraints = false
        feedbackStackView.spacing = 45
        feedbackStackView.axis = .vertical
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.textColor = .darkText
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.font = customConfig?.chatPanel?.styling?.fonts?.bodyFont ?? ChatConfig.Defaults.Styling.Fonts.bodyFont
        textView.delegate = self
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        textView.layer.cornerRadius = 5
        
        let textViewPlaceholder = UILabel()
        textViewPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        textViewPlaceholder.text = NSLocalizedString("Ask your question here", comment: "")
        textViewPlaceholder.textColor = .lightGray
        textView.addSubview(textViewPlaceholder)
        
        textViewPlaceholder.topAnchor.constraint(equalTo: textView.topAnchor, constant: textView.textContainerInset.top).isActive = true
        textViewPlaceholder.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: textView.textContainerInset.left + 5).isActive = true
        
        let submitButton = UIButton(type: .custom)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setImage(UIImage(named: "submit-text-icon", in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
        submitButton.tintColor = .white
        submitButton.addTarget(self, action: #selector(submitFeedback), for: .touchUpInside)
        submitButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        let submitButtonSpacerView = UIView()
        submitButtonSpacerView.translatesAutoresizingMaskIntoConstraints = false
        submitButtonSpacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        submitButtonSpacerView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let submitStackView = UIStackView(arrangedSubviews: [submitButtonSpacerView, submitButton])
        submitStackView.translatesAutoresizingMaskIntoConstraints = false
        submitStackView.alignment = .trailing
        
        let inputStackView = UIStackView(arrangedSubviews: [textView, submitStackView])
        inputStackView.translatesAutoresizingMaskIntoConstraints = false
        inputStackView.spacing = 15
        inputStackView.axis = .vertical
        inputStackView.isHidden = true
        
        let responseLabel = UILabel()
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        responseLabel.textAlignment = .center
        responseLabel.font = customConfig?.chatPanel?.styling?.fonts?.bodyFont ?? ChatConfig.Defaults.Styling.Fonts.bodyFont
        responseLabel.textColor = .white
        responseLabel.numberOfLines = 0
        responseLabel.text = feedbackSuccessMessage
        
        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = .white
        backButton.setTitleColor(.darkText, for: .normal)
        backButton.layer.cornerRadius = 27
        backButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 50, bottom: 15, right: 50)
        backButton.titleLabel?.font = customConfig?.chatPanel?.styling?.fonts?.bodyFont ?? ChatConfig.Defaults.Styling.Fonts.bodyFont
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        
        let responseStackView = UIStackView(arrangedSubviews: [responseLabel, backButton])
        responseStackView.translatesAutoresizingMaskIntoConstraints = false
        responseStackView.axis = .vertical
        responseStackView.alignment = .center
        responseStackView.spacing = 30
        responseStackView.isHidden = true
        
        let stackView = UIStackView(arrangedSubviews: [label, feedbackStackView, inputStackView, responseStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.alignment = .center
        
        view.addSubview(stackView)
        
        let constraints = [
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: horizontalPadding),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -horizontalPadding * 2),
            
            responseLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -horizontalPadding * 2),
        ]
        
        responseLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        NSLayoutConstraint.activate(constraints)
        
        if let config = backend.config, let messages = config.messages, let strings = messages.languages[backend.languageCode], let fallbackStrings = messages.languages["en-US"] {
            label.text = strings.feedbackPrompt.count > 0 ? strings.feedbackPrompt : fallbackStrings.feedbackPrompt
            textViewPlaceholder.text = strings.feedbackPlaceholder.count > 0 ? strings.feedbackPlaceholder : fallbackStrings.feedbackPlaceholder
            closeButton.setTitle(strings.closeWindow.count > 0 ? strings.closeWindow : fallbackStrings.closeWindow, for: .normal)
            backButton.setTitle(strings.back.count > 0 ? strings.back : fallbackStrings.back, for: .normal)
            
            thumbsUpButton.accessibilityLabel = strings.feedbackThumbsUp.count > 0 ? strings.feedbackThumbsUp : fallbackStrings.feedbackThumbsUp
            thumbsDownButton.accessibilityLabel = strings.feedbackThumbsDown.count > 0 ? strings.feedbackThumbsDown : fallbackStrings.feedbackThumbsDown
        }
        
        let contrastColor = customConfig?.chatPanel?.styling?.contrastColor ?? backend.config?.chatPanel?.styling?.contrastColor ?? ChatConfig.Defaults.Styling.contrastColor
        label.textColor = contrastColor
        closeButton.backgroundColor = contrastColor
        thumbsUpButton.tintColor = contrastColor
        thumbsDownButton.tintColor = contrastColor
        submitButton.tintColor = contrastColor
        responseLabel.textColor = contrastColor
        backButton.backgroundColor = contrastColor
                    
        let primaryColor = customConfig?.chatPanel?.styling?.primaryColor ?? backend.config?.chatPanel?.styling?.primaryColor ?? ChatConfig.Defaults.Styling.primaryColor
        view.backgroundColor = primaryColor
        backButton.setTitleColor(primaryColor, for: .normal)
        closeButton.setTitleColor(primaryColor, for: .normal)
        
        self.feedbackStackView = feedbackStackView
        self.inputStackView = inputStackView
        self.inputTextView = textView
        self.textViewPlaceholder = textViewPlaceholder
        self.responseStackView = responseStackView
        self.closeButton = closeButton
    }
    
    public func updateState() {
        switch feedbackState {
        case .initial:
            feedbackStackView.isHidden = false
            closeButton.isHidden = false
            inputStackView.isHidden = true
            responseStackView.isHidden = true
        case .promptForText:
            feedbackStackView.isHidden = false
            closeButton.isHidden = true
            inputStackView.isHidden = false
            responseStackView.isHidden = true
            
            inputTextView.becomeFirstResponder()
        case .complete:
            if let _ = presentingViewController {
                delegate?.closeConversation()
                return
            }
            
            feedbackStackView.isHidden = true
            closeButton.isHidden = true
            inputStackView.isHidden = true
            responseStackView.isHidden = false
            inputTextView.resignFirstResponder()
        }
    }
    
    @objc func userGavePositiveFeedback(_ sender: UIButton) {
        setFeedbackValue(.positive, sender: sender)
    }
    
    @objc func userGaveNegativeFeedback(_ sender: UIButton) {
        setFeedbackValue(.negative, sender: sender)
    }
    
    private func setFeedbackValue(_ feedbackValue: FeedbackValue, sender: UIButton) {
        switch feedbackValue {
        case .positive:
            sender.setImage(UIImage(named: "thumbs-up", in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
        case .negative:
            sender.setImage(UIImage(named: "thumbs-down", in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
        default:
            break
        }
        
        // The icons for "filled"/active for current button and "unfilled"/default for sibling
        let filledName: String
        let otherName: String
        switch feedbackValue {
        case .positive:
            filledName = "thumbs-up-filled"
            otherName = "thumbs-down"
        case .negative:
            filledName = "thumbs-down-filled"
            otherName = "thumbs-up"
        default:
            filledName = ""
            otherName = ""
        }
        
        // Set "filled"/active icon for the currently selected icon
        sender.setImage(UIImage(named: filledName, in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
        
        // Find the sibling button and set the unfilled/default icon for this button
        if let stackView = sender.superview as? UIStackView {
            for view in stackView.arrangedSubviews {
                if view.isKind(of: UIButton.self) && view != sender, let button = view as? UIButton {
                    button.setImage(UIImage(named: otherName, in: Bundle(for: ChatResponseView.self), compatibleWith: nil), for: .normal)
                }
            }
        }
        
        let rating = feedbackValue == .positive ? 1 : -1
        let feedbackText = inputTextView.text
        backend.conversationFeedback(rating: rating, text: feedbackText)
        
        let event = rating > 0 ? BoostUIEvents.Event.positiveConversationFeedbackGiven : BoostUIEvents.Event.negativeConversationFeedbackGiven
        BoostUIEvents.shared.publishEvent(event: event)
        
        if (feedbackText?.count ?? 0 > 0) {
            BoostUIEvents.shared.publishEvent(event: BoostUIEvents.Event.conversationFeedbackTextGiven)
        }
        
        self.feedbackValue = feedbackValue
        feedbackState = .promptForText
    }
    
    @objc func submitFeedback(_ sender: UIButton) {
        guard let feedbackValue = feedbackValue else { return }
        
        let rating = feedbackValue == .positive ? 1 : -1
        let feedbackText = inputTextView.text
        backend.conversationFeedback(rating: rating, text: feedbackText)
        
        let event = rating > 0 ? BoostUIEvents.Event.positiveConversationFeedbackGiven : BoostUIEvents.Event.negativeConversationFeedbackGiven
        BoostUIEvents.shared.publishEvent(event: event)
        
        if (feedbackText?.count ?? 0 > 0) {
            BoostUIEvents.shared.publishEvent(event: BoostUIEvents.Event.conversationFeedbackTextGiven)
        }
        
        feedbackState = .complete
    }
    
    @objc func closeButtonTapped(_ sender: UIButton) {
        delegate?.closeConversation()
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        delegate?.closeConversation()
    }
}

extension ConversationFeedbackViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        textViewPlaceholder.isHidden = textView.text.count > 0
    }
}
