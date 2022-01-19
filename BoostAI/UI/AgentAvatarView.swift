//
//  BotIconView.swift
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

public class AgentAvatarView: UIView {
    
    /// Chatbot backend instance
    public var backend: ChatBackend!
    
    /// Custom ChatConfig for overriding colors etc.
    public var customConfig: ChatConfig?
    
    /// Image for the avatar
    public var avatarImage: UIImage? = UIImage(named: "agent", in: Bundle(for: AgentAvatarView.self), compatibleWith: nil)
    
    /// Avatar size
    public var avatarSize: CGFloat = 60
    
    /// The `UIImageView` containing the avatar image
    public var imageView: UIImageView!

    public init(backend: ChatBackend, customConfig: ChatConfig? = nil) {
        super.init(frame: .zero)
        
        self.backend = backend
        self.customConfig = customConfig
        
        setup()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    public func setup() {
        setupView()
        addTouchRecognizer()
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = NSLocalizedString("Chat", comment: "")
    }
    
    public func setupView() {
        let imageView = UIImageView(image: avatarImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        addSubview(imageView)
        
        let constraints = [
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.widthAnchor.constraint(equalToConstant: avatarSize),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        self.imageView = imageView
        
        backgroundColor = .clear
    }
    
    public func addTouchRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapIcon(sender:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc public func didTapIcon(sender: UITapGestureRecognizer) {
        let vc = ChatViewController(backend: backend, customConfig: customConfig)
        let navController = UINavigationController(rootViewController: vc)
        
        window?.rootViewController?.present(navController, animated: true, completion: nil)
        
    }

}
