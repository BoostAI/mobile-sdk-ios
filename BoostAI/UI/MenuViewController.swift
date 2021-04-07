//
//  MenuViewController.swift
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

public protocol ChatDialogMenuDelegate {
    func deleteConversation()
    func showMenu()
    func hideMenu()
    func showFeedback()
}

open class MenuViewController: UIViewController {
    
    /// Chatbot backend instance
    open var backend: ChatBackend!
    
    /// Menu delegate (normally the parent view controller)
    open var menuDelegate: ChatDialogMenuDelegate?
    
    /// Font used for body text
    public var bodyFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
    
    /// Font used for menu titles
    public var menuItemFont: UIFont = UIFont.preferredFont(forTextStyle: .title3)
    
    /// Font used for footnote sized strings (status messages, character count text etc.)
    public var footnoteFont: UIFont = UIFont.preferredFont(forTextStyle: .footnote)
    
    /// Primary color – setting this will override color from server config
    public var primaryColor: UIColor?
    
    /// Contrast color – setting this will override color from server config
    public var contrastColor: UIColor?
    
    public init(backend: ChatBackend) {
        super.init(nibName: nil, bundle: nil)
        
        self.backend = backend
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    open func setupView() {
        let downloadButton = UIButton(type: .system)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.titleLabel?.font = menuItemFont
        downloadButton.addTarget(self, action: #selector(downloadConversation(_:)), for: .touchUpInside)
        
        var deleteButton: UIButton?
        var privacyPolicyButton: UIButton?
        var feedbackButton: UIButton?
        
        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = .white
        backButton.setTitleColor(.darkText, for: .normal)
        backButton.layer.cornerRadius = 27
        backButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 50, bottom: 15, right: 50)
        backButton.titleLabel?.font = bodyFont
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [downloadButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 40
        stackView.alignment = .center
        
        if let config = backend.config, config.requestConversationFeedback, presentingViewController == nil {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = menuItemFont
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.addTarget(self, action: #selector(showFeedback(_:)), for: .touchUpInside)
            
            stackView.insertArrangedSubview(button, at: 0)
            
            feedbackButton = button
        }
        
        if backend.allowDeleteConversation {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = menuItemFont
            button.addTarget(self, action: #selector(deleteConversation(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            
            deleteButton = button
        }
        
        if backend.privacyPolicyUrl.count > 0 {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(.white, for: .normal)
            button.tintColor = .white
            button.titleLabel?.font = menuItemFont
            button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
            button.setImage(UIImage(named: "external-link-icon", in: Bundle(for: MenuViewController.self), compatibleWith: nil), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            button.addTarget(self, action: #selector(privacyPolicyLinkTapped(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            
            privacyPolicyButton = button
        }
        
        stackView.addArrangedSubview(backButton)
        
        let poweredByBoostLabel = UILabel()
        poweredByBoostLabel.translatesAutoresizingMaskIntoConstraints = false
        poweredByBoostLabel.font = footnoteFont
        poweredByBoostLabel.text = NSLocalizedString("Powered by", comment: "")
        poweredByBoostLabel.textColor = .white
        
        let poweredByBoostImageView = UIImageView(image: UIImage(named: "boost-ai-logo-outline", in: Bundle(for: MenuViewController.self), compatibleWith: nil))
        poweredByBoostImageView.widthAnchor.constraint(equalToConstant: 91).isActive = true
        poweredByBoostImageView.heightAnchor.constraint(equalToConstant: 27).isActive = true
        poweredByBoostImageView.tintColor = .white
        
        let poweredByBoostContainer = UIStackView(arrangedSubviews: [poweredByBoostLabel, poweredByBoostImageView])
        poweredByBoostContainer.translatesAutoresizingMaskIntoConstraints = false
        poweredByBoostContainer.axis = .vertical
        poweredByBoostContainer.alignment = .center
        poweredByBoostContainer.spacing = 5
        poweredByBoostContainer.isUserInteractionEnabled = true
        
        let poweredByBoostTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(poweredByBoostLinkTapped(sender:)))
        poweredByBoostTapRecognizer.numberOfTapsRequired = 1
        poweredByBoostContainer.addGestureRecognizer(poweredByBoostTapRecognizer)
        
        view.addSubview(stackView)
        view.addSubview(poweredByBoostContainer)
        
        if let config = backend.config, let messages = config.messages, let strings = messages.languages[backend.languageCode], let fallbackStrings = messages.languages["en-US"] {
            downloadButton.setTitle(strings.downloadConversation.count > 0 ? strings.downloadConversation : fallbackStrings.downloadConversation, for: .normal)
            deleteButton?.setTitle(strings.deleteConversation.count > 0 ? strings.deleteConversation : fallbackStrings.deleteConversation, for: .normal)
            privacyPolicyButton?.setTitle(strings.privacyPolicy.count > 0 ? strings.privacyPolicy : fallbackStrings.privacyPolicy, for: .normal)
            backButton.setTitle(strings.back.count > 0 ? strings.back : fallbackStrings.back, for: .normal)
            feedbackButton?.setTitle(strings.feedbackPrompt.count > 0 ? strings.feedbackPrompt : fallbackStrings.feedbackPrompt, for: .normal)
        }
        
        let contrastColor = self.contrastColor ?? UIColor(hex: backend.config?.contrastColor) ?? .white
        downloadButton.setTitleColor(contrastColor, for: .normal)
        deleteButton?.setTitleColor(contrastColor, for: .normal)
        privacyPolicyButton?.setTitleColor(contrastColor, for: .normal)
        privacyPolicyButton?.tintColor = contrastColor
        feedbackButton?.setTitleColor(contrastColor, for: .normal)
        backButton.backgroundColor = contrastColor
        poweredByBoostLabel.textColor = contrastColor
        poweredByBoostImageView.tintColor = contrastColor
        
        let primaryColor = self.primaryColor ?? UIColor(hex: backend.config?.primaryColor) ?? UIColor.BoostAI.purple
        view.backgroundColor = primaryColor
        backButton.setTitleColor(primaryColor, for: .normal)
        
        let padding: CGFloat = 20
        let constraints = [
            view.centerYAnchor.constraint(equalTo: stackView.centerYAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: padding),
            
            poweredByBoostContainer.topAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: padding),
            
            poweredByBoostContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            view.trailingAnchor.constraint(equalTo: poweredByBoostContainer.trailingAnchor, constant: padding),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: poweredByBoostContainer.bottomAnchor, constant: padding)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func showFeedback(_ sender: UIButton) {
        menuDelegate?.showFeedback()
    }
    
    @objc func downloadConversation(_ sender: UIButton) {
        // TODO: Get current user token and send this along
        backend.download() { [weak self] (apiMessage, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.displayError(error)
                    return
                }
                
                // Handle chat downlaod
                if let download = apiMessage?.download {
                    // Create filename based on current date and time
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
                    dateFormatter.calendar = Calendar(identifier: .gregorian)
                    let dateString = dateFormatter.string(from: Date())
                    let fileName = "Chat \(dateString).txt"
                    
                    do {
                        // Save chat dialog to a temporary file
                        let tempFolder = FileManager.default.temporaryDirectory
                        let tempFile = tempFolder.appendingPathComponent(fileName)
                        try download.write(to: tempFile, atomically: true, encoding: .utf8)
                        
                        // Display an activity sheet to let the user decide how to save/share the file
                        let activityViewController = UIActivityViewController(activityItems: [tempFile], applicationActivities: nil)
                        
                        if let presentingVC = self?.presentingViewController {
                            presentingVC.dismiss(animated: true) {
                                presentingVC.present(activityViewController, animated: true, completion: nil)
                            }
                        } else {
                            self?.present(activityViewController, animated: true, completion: nil)
                        }
                    } catch (let error) {
                        self?.displayError(error)
                    }
                }
            }
        }
    }

    @objc func deleteConversation(_ sender: UIButton) {
        menuDelegate?.deleteConversation()
    }
    
    @objc func privacyPolicyLinkTapped(_ sender: UIButton) {
        if let url = URL(string: backend.privacyPolicyUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        menuDelegate?.hideMenu()
    }
    
    @objc func poweredByBoostLinkTapped(sender: UITapGestureRecognizer) {
        let url = URL(string: "https://www.boost.ai")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    open func displayError(_ error: Error) {
        let alertController = UIAlertController(title: NSLocalizedString("An error occured", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        if let presentingVC = presentingViewController {
            presentingVC.dismiss(animated: true) {
                presentingVC.present(alertController, animated: true, completion: nil)
            }
        } else {
            present(alertController, animated: true, completion: nil)
        }
    }

}
